"""Auth routes: passwordless magic link, verify, refresh, logout, me."""
import uuid
import jwt

from fastapi import APIRouter, Depends, Request
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import CurrentUser, get_current_user, get_db
from app.core.config import settings
from app.core.errors import APIError
from app.core.security import decode_supabase_access_token
from app.models import User
from app.schemas.auth import (
    LogoutRequest,
    MagicLinkRequest,
    MagicLinkResponse,
    MeResponse,
    RefreshRequest,
    TokenPair,
    UserPublic,
    VerifyRequest,
    VerifyResponse,
)
from app.services import auth_service

router = APIRouter(prefix="/auth", tags=["auth"])


def _require_local_auth() -> None:
    """Magic-link JWTs are a local dev convenience. Public deployments use Supabase."""
    if not settings.is_dev:
        raise APIError(404, "NOT_FOUND", "El acceso local no está disponible. Use el inicio de sesión de Supabase.")


@router.post("/supabase/session", response_model=MeResponse)
async def sync_supabase_session(
    request: Request,
    db: AsyncSession = Depends(get_db),
):
    auth = request.headers.get("Authorization", "")
    if not auth.lower().startswith("bearer "):
        raise APIError(401, "UNAUTHENTICATED", "Falta el token de Supabase.")
    token = auth.split(" ", 1)[1].strip()
    try:
        payload = await decode_supabase_access_token(token)
    except (jwt.ExpiredSignatureError, jwt.InvalidTokenError):
        raise APIError(401, "UNAUTHENTICATED", "El token de Supabase no es válido.")

    email = payload.get("email")
    if not email:
        raise APIError(401, "UNAUTHENTICATED", "El usuario no tiene correo.")
    try:
        supabase_user_id = uuid.UUID(payload["sub"])
    except (KeyError, TypeError, ValueError):
        raise APIError(401, "UNAUTHENTICATED", "El token no contiene un usuario válido.")

    email = str(email).strip().lower()
    user = await db.scalar(select(User).where(User.email == email))
    if user is None:
        metadata = payload.get("user_metadata") or {}
        locale = str(metadata.get("locale", "es"))[:2]
        user = User(
            id=supabase_user_id,
            email=email,
            role="client",
            status="active",
            locale=locale,
            supabase_user_id=supabase_user_id,
        )
        db.add(user)
        await db.flush()
    elif user.supabase_user_id is None:
        user.supabase_user_id = supabase_user_id

    return MeResponse.model_validate(user)


@router.post("/magic-link", status_code=202, response_model=MagicLinkResponse)
async def magic_link(payload: MagicLinkRequest, db: AsyncSession = Depends(get_db)):
    _require_local_auth()
    await auth_service.request_magic_link(db, payload.email, payload.locale or "es")
    # Always return the same body to avoid user enumeration.
    return MagicLinkResponse(status="sent", message="Si el correo existe, enviaremos un enlace de acceso.")


@router.post("/verify", response_model=VerifyResponse)
async def verify(payload: VerifyRequest, db: AsyncSession = Depends(get_db)):
    _require_local_auth()
    user, tokens = await auth_service.verify_magic_link(db, payload.token)
    return VerifyResponse(user=UserPublic.model_validate(user), **tokens)


@router.post("/refresh", response_model=TokenPair)
async def refresh(payload: RefreshRequest, db: AsyncSession = Depends(get_db)):
    _require_local_auth()
    tokens = await auth_service.rotate_refresh_token(db, payload.refresh_token)
    return TokenPair(**tokens)


@router.post("/logout", status_code=204)
async def logout(
    payload: LogoutRequest,
    current: CurrentUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await auth_service.revoke_tokens(
        db, current.user, refresh_token=payload.refresh_token, all_tokens=payload.all
    )
    return None


@router.get("/me", response_model=MeResponse)
async def me(current: CurrentUser = Depends(get_current_user)):
    return MeResponse.model_validate(current.user)
