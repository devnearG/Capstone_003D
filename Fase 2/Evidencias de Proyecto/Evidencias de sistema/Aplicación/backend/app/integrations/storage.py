"""Document storage: Supabase Storage, or local filesystem (dev fallback)."""
import os
import uuid

import httpx

from app.core.config import settings


def _use_supabase() -> bool:
    return bool(settings.supabase_url and settings.supabase_service_role_key)


def uses_remote_storage() -> bool:
    """True when objects live behind signed URLs (Supabase Storage)."""
    return _use_supabase()


def _supabase_headers() -> dict:
    return {
        "Authorization": f"Bearer {settings.supabase_service_role_key}",
        "apikey": settings.supabase_service_role_key,
    }


async def _supabase_upload(key: str, data: bytes, content_type: str) -> None:
    url = (
        f"{settings.supabase_url.rstrip('/')}/storage/v1/object/"
        f"{settings.supabase_storage_bucket}/{key}"
    )
    async with httpx.AsyncClient(timeout=60) as client:
        resp = await client.post(
            url,
            content=data,
            headers={
                **_supabase_headers(),
                "Content-Type": content_type or "application/octet-stream",
                "x-upsert": "true",
            },
        )
        resp.raise_for_status()


async def upload_bytes(data: bytes, filename: str, content_type: str) -> str:
    """Returns a storage_key referencing the stored object."""
    key = f"{uuid.uuid4().hex}/{filename}"
    if _use_supabase():
        await _supabase_upload(key, data, content_type)
        return key
    base = os.path.join(settings.local_storage_dir, os.path.dirname(key))
    os.makedirs(base, exist_ok=True)
    with open(os.path.join(settings.local_storage_dir, key), "wb") as fh:
        fh.write(data)
    return key


async def signed_url(storage_key: str, minutes: int = 30) -> str:
    if _use_supabase():
        url = (
            f"{settings.supabase_url.rstrip('/')}/storage/v1/object/sign/"
            f"{settings.supabase_storage_bucket}/{storage_key}"
        )
        async with httpx.AsyncClient(timeout=30) as client:
            resp = await client.post(
                url,
                json={"expiresIn": minutes * 60},
                headers=_supabase_headers(),
            )
            resp.raise_for_status()
            signed = resp.json().get("signedURL") or ""
        return f"{settings.supabase_url.rstrip('/')}/storage/v1{signed}"
    return f"/local-files/{storage_key}"
