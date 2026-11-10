"""
IMOX Enterprise API (FastAPI)
Orquestração de Dados para Operação Morar (Incorporação), B2B/B2C, Agro e Cartório.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import cartorio
from app.core.config import get_settings
from app.models.schemas import HealthResponse

settings = get_settings()

app = FastAPI(
    title="IMOX Enterprise API",
    description="Backend FastAPI para Inteligência Imobiliária, Incorporação (Morar), Agro e Compliance Registral (Cartório)",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Vertical 03 - Cartório & ONR/SAEC
app.include_router(cartorio.router)
app.include_router(cartorio.webhook_router)


@app.get("/health", response_model=HealthResponse, tags=["System"])
async def health_check() -> HealthResponse:
    return HealthResponse(
        status="ok",
        service="imox-fastapi-backend",
        version="2.0.0",
        modules=["b2b_b2c_profiles", "morar_developments", "agro_rural", "cartorio_rgi"],
    )
