"""
Cliente Supabase assíncrono com service_role (bypass de RLS) e validação do JWT do usuário.
"""

from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from supabase import AsyncClient, acreate_client

from app.core.config import get_settings

_admin_client: Optional[AsyncClient] = None
_bearer = HTTPBearer(auto_error=False)


async def get_supabase_admin() -> AsyncClient:
    """Cliente singleton com service_role. Uso exclusivo do backend."""
    global _admin_client
    if _admin_client is None:
        settings = get_settings()
        if not settings.supabase_service_role_key:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="SUPABASE_SERVICE_ROLE_KEY não configurada no backend.",
            )
        _admin_client = await acreate_client(settings.supabase_url, settings.supabase_service_role_key)
    return _admin_client


class AuthenticatedUser:
    def __init__(self, user_id: str, email: Optional[str], access_token: str):
        self.id = user_id
        self.email = email
        self.access_token = access_token


async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(_bearer),
) -> AuthenticatedUser:
    """
    Valida o access_token da sessão Supabase enviado pelo Nuxt (Authorization: Bearer <jwt>).
    O user_id nunca é aceito do corpo da requisição.
    """
    if credentials is None or credentials.scheme.lower() != "bearer" or not credentials.credentials:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token de acesso ausente.")

    client = await get_supabase_admin()
    try:
        response = await client.auth.get_user(credentials.credentials)
    except Exception:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token de acesso inválido ou expirado.")

    if response is None or response.user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token de acesso inválido ou expirado.")

    return AuthenticatedUser(
        user_id=str(response.user.id),
        email=response.user.email,
        access_token=credentials.credentials,
    )
