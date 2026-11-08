"""
IMOX Enterprise API (FastAPI)
Orquestração de Dados para Operação Morar (Incorporação), B2B/B2C, Agro e Cartório.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.models.schemas import HealthResponse

app = FastAPI(
    title="IMOX Enterprise API",
    description="Backend FastAPI para Inteligência Imobiliária, Incorporação (Morar), Agro e Compliance Registral (Cartório)",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health", response_model=HealthResponse, tags=["System"])
async def health_check() -> HealthResponse:
    return HealthResponse(
        status="ok",
        service="imox-fastapi-backend",
        version="2.0.0",
        modules=["b2b_b2c_profiles", "morar_developments", "agro_rural", "cartorio_rgi"],
    )
