"""
Motor de Integração com o ONR (Operador Nacional do Registro) / SAEC.

- solicitar_matricula: envia o pedido de certidão/matrícula ao ONR via HTTP POST.
- processar_retorno_webhook: trata a devolução assíncrona do cartório, baixa o PDF,
  grava no bucket privado 'documentos_oficiais' e conclui o pedido em cartorio_orders.

Modo mock (ONR_MOCK_MODE=true, padrão): o mesmo código httpx é executado contra um
httpx.MockTransport que simula as respostas do SAEC. Ao homologar com o ONR, basta
ONR_MOCK_MODE=false + ONR_API_BASE_URL/ONR_API_KEY reais. Os nomes de campos dos payloads
são provisórios e devem ser alinhados ao manual técnico oficial do ONR/SAEC.
"""

from __future__ import annotations

import json
import logging
import secrets
from datetime import datetime, timezone
from typing import Any, Dict, Optional
from urllib.parse import urlparse
from uuid import UUID

import httpx
from supabase import AsyncClient

from app.core.config import Settings, get_settings
from app.models.schemas import (
    CartorioOrderStatusEnum,
    ONRSolicitacaoResult,
    ONRWebhookAck,
    ONRWebhookPayload,
    ONRWebhookStatusEnum,
)

logger = logging.getLogger("imox.onr")

ORDERS_TABLE = "cartorio_orders"
MAX_PDF_BYTES = 20 * 1024 * 1024  # alinhado ao file_size_limit do bucket
ONR_PEDIDOS_PATH = "/v1/certidoes/pedidos"
MOCK_DOCUMENTOS_PATH = "/mock/documentos/"


class ONRIntegrationError(Exception):
    """Falha de comunicação ou de regra de negócio com o ONR."""


class ONROrderNotFoundError(Exception):
    """transaction_id recebido não corresponde a nenhum pedido."""


def _gerar_pdf_simulado(transaction_id: str) -> bytes:
    """Gera um PDF mínimo e válido para o modo mock."""
    texto = f"IMOX - Documento simulado ONR/SAEC - transacao {transaction_id}"
    stream = f"BT /F1 12 Tf 72 720 Td ({texto}) Tj ET".encode("latin-1")
    objetos = [
        b"<< /Type /Catalog /Pages 2 0 R >>",
        b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
        b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] "
        b"/Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>",
        b"<< /Length " + str(len(stream)).encode() + b" >>\nstream\n" + stream + b"\nendstream",
        b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
    ]
    pdf = bytearray(b"%PDF-1.4\n")
    offsets = []
    for i, obj in enumerate(objetos, start=1):
        offsets.append(len(pdf))
        pdf += f"{i} 0 obj\n".encode() + obj + b"\nendobj\n"
    xref_pos = len(pdf)
    pdf += f"xref\n0 {len(objetos) + 1}\n0000000000 65535 f \n".encode()
    for off in offsets:
        pdf += f"{off:010d} 00000 n \n".encode()
    pdf += f"trailer\n<< /Size {len(objetos) + 1} /Root 1 0 R >>\nstartxref\n{xref_pos}\n%%EOF\n".encode()
    return bytes(pdf)


async def _mock_onr_handler(request: httpx.Request) -> httpx.Response:
    """Simula o servidor ONR/SAEC (usado apenas com ONR_MOCK_MODE=true)."""
    path = request.url.path

    if request.method == "POST" and path == ONR_PEDIDOS_PATH:
        body = json.loads(request.content or b"{}")
        if not body.get("matricula") or not body.get("id_transacao"):
            return httpx.Response(422, json={"erro": "matricula e id_transacao são obrigatórios"})
        return httpx.Response(
            202,
            json={
                "protocolo": f"ONR-MOCK-{secrets.token_hex(4).upper()}",
                "status": "RECEBIDO",
                "id_transacao": body["id_transacao"],
            },
        )

    if request.method == "GET" and path.startswith(MOCK_DOCUMENTOS_PATH):
        transaction_id = path[len(MOCK_DOCUMENTOS_PATH):].removesuffix(".pdf")
        return httpx.Response(
            200,
            content=_gerar_pdf_simulado(transaction_id),
            headers={"content-type": "application/pdf"},
        )

    return httpx.Response(404, json={"erro": "rota mock não encontrada"})


class ONRIntegrationService:
    def __init__(self, supabase: Optional[AsyncClient] = None, settings: Optional[Settings] = None):
        self.settings = settings or get_settings()
        self.supabase = supabase

    # ------------------------------------------------------------------------------------
    # HTTP
    # ------------------------------------------------------------------------------------
    def _http_client(self) -> httpx.AsyncClient:
        kwargs: Dict[str, Any] = {
            "base_url": self.settings.onr_api_base_url,
            "timeout": self.settings.onr_timeout_seconds,
            "follow_redirects": False,  # evita SSRF via redirecionamento
        }
        if self.settings.onr_mock_mode:
            kwargs["transport"] = httpx.MockTransport(_mock_onr_handler)
        return httpx.AsyncClient(**kwargs)

    def _headers(self, transaction_id: str) -> Dict[str, str]:
        headers = {"Content-Type": "application/json", "Idempotency-Key": transaction_id}
        if self.settings.onr_api_key:
            headers["Authorization"] = f"Bearer {self.settings.onr_api_key}"
        return headers

    def mock_document_url(self, transaction_id: UUID | str) -> str:
        return f"{self.settings.onr_api_base_url.rstrip('/')}{MOCK_DOCUMENTOS_PATH}{transaction_id}.pdf"

    # ------------------------------------------------------------------------------------
    # 1. Envio do pedido
    # ------------------------------------------------------------------------------------
    async def solicitar_matricula(
        self,
        matricula: str,
        rgi: str,
        transaction_id: UUID | str,
        cartorio_cns: Optional[str] = None,
        tipo_certidao: str = "matricula_inteiro_teor",
    ) -> ONRSolicitacaoResult:
        if not self.settings.onr_mock_mode and not self.settings.onr_api_key:
            raise ONRIntegrationError("ONR_API_KEY não configurada para o modo real.")

        tid = str(transaction_id)
        payload = {
            "id_transacao": tid,
            "tipo_servico": "CERTIDAO_MATRICULA",
            "tipo_certidao": tipo_certidao,
            "matricula": matricula,
            "serventia": {"rgi": rgi, "cns": cartorio_cns},
            "formato_entrega": "PDF",
            "url_retorno": f"{self.settings.public_api_base_url.rstrip('/')}/api/webhooks/onr",
        }

        try:
            async with self._http_client() as client:
                response = await client.post(ONR_PEDIDOS_PATH, json=payload, headers=self._headers(tid))
        except httpx.HTTPError as exc:
            logger.error("Falha de comunicação com o ONR (transação %s): %s", tid, exc)
            raise ONRIntegrationError("Falha de comunicação com o ONR.") from exc

        if response.status_code not in (200, 201, 202):
            logger.error("ONR recusou o pedido %s: HTTP %s", tid, response.status_code)
            raise ONRIntegrationError(f"ONR recusou o pedido (HTTP {response.status_code}).")

        data = response.json()
        protocolo = data.get("protocolo")
        if not protocolo:
            raise ONRIntegrationError("Resposta do ONR sem protocolo.")

        return ONRSolicitacaoResult(
            protocolo=protocolo,
            status=str(data.get("status", "RECEBIDO")),
            mock=self.settings.onr_mock_mode,
        )

    # ------------------------------------------------------------------------------------
    # 2. Retorno assíncrono (webhook)
    # ------------------------------------------------------------------------------------
    def _validar_url_documento(self, url: str) -> None:
        parsed = urlparse(url)
        host = (parsed.hostname or "").lower()
        allowed = set(self.settings.onr_allowed_hosts_list)
        base_host = (urlparse(self.settings.onr_api_base_url).hostname or "").lower()
        if base_host:
            allowed.add(base_host)

        if not self.settings.onr_mock_mode and parsed.scheme != "https":
            raise ONRIntegrationError("pdf_url deve usar HTTPS.")
        if parsed.scheme not in ("https", "http") or host not in allowed:
            raise ONRIntegrationError(f"Host do documento não autorizado: {host or '<vazio>'}")

    async def _baixar_pdf(self, url: str) -> bytes:
        self._validar_url_documento(url)
        try:
            async with self._http_client() as client:
                async with client.stream("GET", url) as response:
                    if response.status_code != 200:
                        raise ONRIntegrationError(f"Download do PDF falhou (HTTP {response.status_code}).")
                    conteudo = bytearray()
                    async for chunk in response.aiter_bytes():
                        conteudo += chunk
                        if len(conteudo) > MAX_PDF_BYTES:
                            raise ONRIntegrationError("PDF excede o limite de 20 MB.")
        except httpx.HTTPError as exc:
            raise ONRIntegrationError("Falha ao baixar o PDF do ONR.") from exc

        if not conteudo.startswith(b"%PDF-"):
            raise ONRIntegrationError("Arquivo recebido não é um PDF válido.")
        return bytes(conteudo)

    async def _atualizar_pedido(self, order_id: str, campos: Dict[str, Any]) -> None:
        await self.supabase.table(ORDERS_TABLE).update(campos).eq("id", order_id).execute()

    async def processar_retorno_webhook(self, payload: ONRWebhookPayload) -> ONRWebhookAck:
        if self.supabase is None:
            raise RuntimeError("Cliente Supabase não configurado no ONRIntegrationService.")

        result = (
            await self.supabase.table(ORDERS_TABLE)
            .select("id, user_id, status, documento_path, protocolo_onr")
            .eq("transaction_id", str(payload.transaction_id))
            .limit(1)
            .execute()
        )
        if not result.data:
            raise ONROrderNotFoundError(str(payload.transaction_id))

        order = result.data[0]
        order_id = order["id"]
        auditoria = payload.model_dump(mode="json")

        # Idempotência: reentregas do ONR não reprocessam pedidos já concluídos
        if order["status"] == CartorioOrderStatusEnum.concluido.value:
            return ONRWebhookAck(
                order_id=order_id,
                status=CartorioOrderStatusEnum.concluido,
                documento_path=order.get("documento_path"),
            )

        if payload.status == ONRWebhookStatusEnum.erro:
            await self._atualizar_pedido(
                order_id,
                {
                    "status": CartorioOrderStatusEnum.erro.value,
                    "error_message": payload.mensagem or "Cartório retornou erro sem mensagem.",
                    "protocolo_onr": payload.protocolo or order.get("protocolo_onr"),
                    "onr_payload": auditoria,
                },
            )
            return ONRWebhookAck(order_id=order_id, status=CartorioOrderStatusEnum.erro)

        try:
            if not payload.pdf_url:
                raise ONRIntegrationError("Retorno CONCLUIDO sem pdf_url.")
            pdf = await self._baixar_pdf(payload.pdf_url)
            documento_path = f"{order['user_id']}/{order_id}.pdf"
            await self.supabase.storage.from_(self.settings.storage_bucket_documentos).upload(
                documento_path,
                pdf,
                {"content-type": "application/pdf", "upsert": "true"},
            )
        except ONRIntegrationError as exc:
            await self._atualizar_pedido(
                order_id,
                {"status": CartorioOrderStatusEnum.erro.value, "error_message": str(exc), "onr_payload": auditoria},
            )
            raise
        except Exception as exc:  # falha de storage
            logger.exception("Falha ao gravar PDF do pedido %s no storage", order_id)
            await self._atualizar_pedido(
                order_id,
                {
                    "status": CartorioOrderStatusEnum.erro.value,
                    "error_message": "Falha ao armazenar o documento.",
                    "onr_payload": auditoria,
                },
            )
            raise ONRIntegrationError("Falha ao armazenar o documento.") from exc

        await self._atualizar_pedido(
            order_id,
            {
                "status": CartorioOrderStatusEnum.concluido.value,
                "documento_path": documento_path,
                "protocolo_onr": payload.protocolo or order.get("protocolo_onr"),
                "completed_at": datetime.now(timezone.utc).isoformat(),
                "error_message": None,
                "onr_payload": auditoria,
            },
        )
        return ONRWebhookAck(
            order_id=order_id,
            status=CartorioOrderStatusEnum.concluido,
            documento_path=documento_path,
        )
