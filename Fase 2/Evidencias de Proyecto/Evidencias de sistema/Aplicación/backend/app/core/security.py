"""JWT access tokens + opaque hashed tokens (magic link, refresh, delegation)."""
import asyncio
import hashlib
import secrets
from datetime import datetime, timedelta, timezone
from functools import lru_cache
from typing import Optional

import jwt
from jwt import PyJWKClient

from app.core.config import settings


def now_utc() -> datetime:
    return datetime.now(timezone.utc)


def as_utc(dt: datetime) -> datetime:
    """Coerce a possibly-naive datetime (SQLite drops tzinfo) to aware UTC."""
    if dt.tzinfo is None:
        return dt.replace(tzinfo=timezone.utc)
    return dt


# ---- opaque tokens (stored only as hash) ----
def generate_opaque_token(nbytes: int = 32) -> str:
    return secrets.token_urlsafe(nbytes)


def hash_token(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


# ---- JWT access tokens ----
def create_access_token(subject: str, extra: Optional[dict] = None) -> str:
    payload = {
        "sub": subject,
        "type": "access",
        "iat": int(now_utc().timestamp()),
        "exp": int((now_utc() + timedelta(minutes=settings.access_token_ttl_min)).timestamp()),
    }
    if extra:
        payload.update(extra)
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)


def decode_access_token(token: str) -> dict:
    """Raises jwt.ExpiredSignatureError / jwt.InvalidTokenError on failure."""
    return jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])


@lru_cache(maxsize=4)
def _jwks_client(jwks_url: str) -> PyJWKClient:
    return PyJWKClient(jwks_url)


async def decode_supabase_access_token(token: str) -> dict:
    """Validate a Supabase access token.

    Dispatches on the JWT ``alg`` header: legacy HS256 tokens use
    ``supabase_jwt_secret`` when configured; asymmetric tokens (RS256/ES256,
    the current Supabase default) are verified against the project's JWKS.
    This keeps working even if the legacy secret is set by mistake.
    """
    try:
        alg = jwt.get_unverified_header(token).get("alg")
    except jwt.InvalidTokenError:
        alg = None
    if alg == "HS256" and settings.supabase_jwt_secret:
        return jwt.decode(
            token,
            settings.supabase_jwt_secret,
            algorithms=["HS256"],
            audience="authenticated",
        )
    if not settings.supabase_url:
        raise jwt.InvalidTokenError("Supabase URL is not configured")

    jwks_url = f"{settings.supabase_url.rstrip('/')}/auth/v1/.well-known/jwks.json"
    # PyJWKClient does a blocking HTTP fetch on cache miss; keep it off the loop.
    # JWKS/key errors (PyJWKClientError, missing crypto backend) are not
    # InvalidTokenError subclasses — normalize them so callers return 401.
    try:
        signing_key = await asyncio.to_thread(
            _jwks_client(jwks_url).get_signing_key_from_jwt, token
        )
    except jwt.PyJWTError as exc:
        raise jwt.InvalidTokenError(str(exc)) from exc
    return jwt.decode(
        token,
        signing_key.key,
        algorithms=["RS256", "ES256"],
        audience="authenticated",
    )


def access_token_expires_in() -> int:
    return settings.access_token_ttl_min * 60
