"""
Configuração central do backend (lida de backend/.env via pydantic-settings).
"""

from functools import lru_cache
from typing import List

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    environment: str = "development"
    cors_origins: str = "http://localhost:3000,http://127.0.0.1:3000"

    # Supabase (service_role é exclusiva do backend; nunca expor ao frontend)
    supabase_url: str = "https://kbnyesbkmablickwcwfw.supabase.co"
    supabase_anon_key: str = ""
    supabase_service_role_key: str = ""
    storage_bucket_documentos: str = "documentos_oficiais"

    # Integração ONR / SAEC
    onr_mock_mode: bool = True
    onr_api_base_url: str = "https://api-homologacao.onr.example"
    onr_api_key: str = ""
    onr_webhook_secret: str = ""
    onr_timeout_seconds: float = 30.0
    # Hosts autorizados para download do PDF devolvido pelo webhook (proteção contra SSRF)
    onr_allowed_document_hosts: str = ""
    # URL pública que o ONR chamará de volta
    public_api_base_url: str = "http://localhost:8000"

    @property
    def cors_origins_list(self) -> List[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    @property
    def onr_allowed_hosts_list(self) -> List[str]:
        return [h.strip().lower() for h in self.onr_allowed_document_hosts.split(",") if h.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
