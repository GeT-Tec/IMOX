"""
Pydantic Schemas alinhados com a migration 20261108_imox_enterprise_schema.sql
"""

from datetime import date, datetime
from enum import Enum
from typing import List, Optional
from uuid import UUID
from pydantic import BaseModel, Field


class UserRoleEnum(str, Enum):
    customer = "customer"
    broker = "broker"
    cartorio = "cartorio"
    builder = "builder"


class DevelopmentStatusEnum(str, Enum):
    pre_launch = "pre_launch"
    launch = "launch"
    under_construction = "under_construction"
    ready = "ready"


class PropertyStatusEnum(str, Enum):
    for_sale = "for_sale"
    sold = "sold"
    precon = "precon"
    rental = "rental"


class PropertyTypeEnum(str, Enum):
    condo = "condo"
    townhouse = "townhouse"
    detached = "detached"
    apartment = "apartment"
    house = "house"
    rural = "rural"
    land = "land"
    commercial = "commercial"


class HealthResponse(BaseModel):
    status: str
    service: str
    version: str
    modules: List[str]


class UserProfileSchema(BaseModel):
    id: UUID
    role: UserRoleEnum = UserRoleEnum.customer
    full_name: str
    document_number: Optional[str] = None
    company_name: Optional[str] = None
    creci: Optional[str] = None
    cns_cartorio: Optional[str] = None
    phone: Optional[str] = None
    avatar_url: Optional[str] = None
    broker_id: Optional[UUID] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class DevelopmentSchema(BaseModel):
    id: UUID
    builder_id: Optional[UUID] = None
    name: str
    builder_name: str = "Morar Construtora"
    description: Optional[str] = None
    status: DevelopmentStatusEnum = DevelopmentStatusEnum.launch
    address: str
    neighborhood: Optional[str] = None
    city: str
    state: str
    zipcode: Optional[str] = None
    total_units: int = 0
    available_units: int = 0
    delivery_date: Optional[date] = None
    incorporation_registry: Optional[str] = None
    amenities: List[str] = Field(default_factory=list)
    images: List[str] = Field(default_factory=list)
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class PropertyEnterpriseSchema(BaseModel):
    id: UUID
    source_id: str
    broker_id: Optional[UUID] = None
    development_id: Optional[UUID] = None
    unit_identifier: Optional[str] = None
    address: str
    street: Optional[str] = None
    neighborhood: Optional[str] = None
    city: str
    state: str
    zipcode: Optional[str] = None
    price: float
    condo_fee: Optional[float] = None
    tax_fee: Optional[float] = None
    area_sqm: float
    listing_date: date
    status: PropertyStatusEnum = PropertyStatusEnum.for_sale
    property_type: PropertyTypeEnum
    bedrooms: int = 0
    bathrooms: int = 0
    parking: int = 0
    images: List[str] = Field(default_factory=list)
    features: List[str] = Field(default_factory=list)
    source_url: str
    view_count: Optional[int] = 0
    condominium_name: Optional[str] = None
    # Módulo Agro
    numero_car: Optional[str] = None
    area_total_ha: Optional[float] = None
    area_reserva_ha: Optional[float] = None
    recursos_hidricos: List[str] = Field(default_factory=list)
    # Módulo Cartório
    matricula: Optional[str] = None
    rgi: Optional[str] = None
    status_juridico: str = "regular"
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


# ========================================================================================
# Vertical 03 - Cartório & Integração ONR/SAEC
# Alinhado com a migration 20261110194000_cartorio_orders_storage.sql
# ========================================================================================


class CartorioOrderStatusEnum(str, Enum):
    solicitado = "solicitado"
    processando = "processando"
    concluido = "concluido"
    erro = "erro"


class SolicitacaoMatriculaRequest(BaseModel):
    """Payload enviado pelo Nuxt ao solicitar uma matrícula/certidão."""

    matricula: str = Field(..., min_length=1, max_length=100, description="Número da matrícula do imóvel")
    rgi: str = Field(..., min_length=1, max_length=255, description="Serventia / Registro de Imóveis de destino")
    cartorio_cns: Optional[str] = Field(default=None, max_length=50, description="Código Nacional de Serventia")
    tipo_certidao: str = Field(default="matricula_inteiro_teor", max_length=100)
    property_id: Optional[UUID] = None


class SolicitacaoMatriculaResponse(BaseModel):
    order_id: UUID
    transaction_id: UUID
    status: CartorioOrderStatusEnum
    protocolo_onr: Optional[str] = None


class ONRSolicitacaoResult(BaseModel):
    """Resposta normalizada do ONR/SAEC ao receber o pedido."""

    protocolo: str
    status: str
    mock: bool = False


class ONRWebhookStatusEnum(str, Enum):
    concluido = "CONCLUIDO"
    erro = "ERRO"


class ONRWebhookPayload(BaseModel):
    """
    Retorno assíncrono do cartório via ONR/SAEC.
    Contrato provisório: ajustar aos nomes oficiais na homologação com o ONR.
    """

    transaction_id: UUID
    protocolo: Optional[str] = None
    status: ONRWebhookStatusEnum
    pdf_url: Optional[str] = None
    mensagem: Optional[str] = None


class ONRWebhookAck(BaseModel):
    received: bool = True
    order_id: UUID
    status: CartorioOrderStatusEnum
    documento_path: Optional[str] = None
