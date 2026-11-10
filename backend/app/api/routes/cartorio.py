"""
Rotas da Vertical 03 - Cartório & Integração ONR/SAEC.

- router          -> /api/cartorio/*  (chamado pelo Nuxt; exige JWT do usuário Supabase)
- webhook_router  -> /api/webhooks/*  (chamado servidor-a-servidor pelo ONR; sem JWT de
                     usuário, autenticado pelo cabeçalho X-ONR-Webhook-Secret)
"""

import hmac
import logging
from typing import Optional

from fastapi import APIRouter, Depends, Header, HTTPException, status
from supabase import AsyncClient

from app.core.config import get_settings
from app.core.supabase_client import AuthenticatedUser, get_current_user, get_supabase_admin
from app.models.schemas import (
    CartorioOrderStatusEnum,
    ONRWebhookAck,
    ONRWebhookPayload,
    SolicitacaoMatriculaRequest,
    SolicitacaoMatriculaResponse,
)
from app.services.onr_service import (
    ORDERS_TABLE,
    ONRIntegrationError,
    ONRIntegrationService,
    ONROrderNotFoundError,
)

logger = logging.getLogger("imox.cartorio")

router = APIRouter(prefix="/api/cartorio", tags=["Cartório"])
webhook_router = APIRouter(prefix="/api/webhooks", tags=["Webhooks"])


# ----------------------------------------------------------------------------------------
# POST /api/cartorio/solicitar
# ----------------------------------------------------------------------------------------
@router.post(
    "/solicitar",
    response_model=SolicitacaoMatriculaResponse,
    status_code=status.HTTP_202_ACCEPTED,
    summary="Solicita matrícula/certidão ao ONR",
)
async def solicitar_matricula(
    body: SolicitacaoMatriculaRequest,
    user: AuthenticatedUser = Depends(get_current_user),
    supabase: AsyncClient = Depends(get_supabase_admin),
) -> SolicitacaoMatriculaResponse:
    # 1. Registra o pedido já como "processando" (o dono vem do JWT, nunca do corpo)
    insert = (
        await supabase.table(ORDERS_TABLE)
        .insert(
            {
                "user_id": user.id,
                "property_id": str(body.property_id) if body.property_id else None,
                "matricula": body.matricula.strip(),
                "rgi": body.rgi.strip(),
                "cartorio_cns": body.cartorio_cns.strip() if body.cartorio_cns else None,
                "tipo_certidao": body.tipo_certidao,
                "status": CartorioOrderStatusEnum.processando.value,
            }
        )
        .execute()
    )
    if not insert.data:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Falha ao registrar o pedido.")

    order = insert.data[0]
    order_id = order["id"]
    transaction_id = order["transaction_id"]

    # 2. Dispara o pedido ao ONR
    service = ONRIntegrationService(supabase)
    try:
        resultado = await service.solicitar_matricula(
            matricula=order["matricula"],
            rgi=order["rgi"],
            transaction_id=transaction_id,
            cartorio_cns=order.get("cartorio_cns"),
            tipo_certidao=order["tipo_certidao"],
        )
    except ONRIntegrationError as exc:
        await supabase.table(ORDERS_TABLE).update(
            {"status": CartorioOrderStatusEnum.erro.value, "error_message": str(exc)}
        ).eq("id", order_id).execute()
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="O ONR não aceitou o pedido no momento. Tente novamente.",
        )

    # 3. Guarda o protocolo devolvido pelo ONR
    await supabase.table(ORDERS_TABLE).update({"protocolo_onr": resultado.protocolo}).eq("id", order_id).execute()

    return SolicitacaoMatriculaResponse(
        order_id=order_id,
        transaction_id=transaction_id,
        status=CartorioOrderStatusEnum.processando,
        protocolo_onr=resultado.protocolo,
    )


# ----------------------------------------------------------------------------------------
# POST /api/webhooks/onr  (rota pública, isolada do fluxo de usuário)
# ----------------------------------------------------------------------------------------
async def verificar_segredo_onr(
    x_onr_webhook_secret: Optional[str] = Header(default=None, alias="X-ONR-Webhook-Secret"),
) -> None:
    esperado = get_settings().onr_webhook_secret
    if not esperado:
        # Fail-closed: sem segredo configurado, o webhook não aceita nenhuma chamada
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Webhook ONR não configurado.")
    if not x_onr_webhook_secret or not hmac.compare_digest(x_onr_webhook_secret, esperado):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Assinatura do webhook inválida.")


@webhook_router.post(
    "/onr",
    response_model=ONRWebhookAck,
    summary="Retorno assíncrono do ONR (PDF da matrícula)",
    dependencies=[Depends(verificar_segredo_onr)],
)
async def webhook_onr(
    payload: ONRWebhookPayload,
    supabase: AsyncClient = Depends(get_supabase_admin),
) -> ONRWebhookAck:
    service = ONRIntegrationService(supabase)
    try:
        return await service.processar_retorno_webhook(payload)
    except ONROrderNotFoundError:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Pedido não encontrado.")
    except ONRIntegrationError as exc:
        logger.error("Falha ao processar retorno ONR %s: %s", payload.transaction_id, exc)
        # 502 sinaliza ao ONR que a entrega pode ser reenviada
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail="Falha ao processar o documento.")
