"""
IMOX / ImobiLit — Fase 2: Stress-Test Definitivo do Motor de Permissões (RBAC Master)

Valida contra o Supabase Cloud real (PostgREST + RLS + Triggers + RPC) e FastAPI:
- Os 5 perfis do ecossistema: admin, b2b_partner, broker, pf_owner, customer (+ anon).
- Bloqueio total de auto-escalação para admin (via RPC e via PATCH direto em user_profiles).
- Bloqueio total de auto-aprovação/rejeição de imóveis e cobertura de compliance (properties).
- Isolamento de cartorio_orders (escrita exclusiva do backend via FastAPI, leitura dono/admin).

Uso:
    cd backend
    $env:PYTHONPATH="."; $env:PYTHONIOENCODING="utf-8"
    .\\.venv\\Scripts\\python.exe scripts/test_rbac.py
"""

from __future__ import annotations

import asyncio
import os
import secrets
import sys
import uuid
from dataclasses import dataclass
from typing import Any, Dict, List

import httpx

# Garante execução a partir de backend/ mesmo se PYTHONPATH não for exportado
BACKEND_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BACKEND_DIR not in sys.path:
    sys.path.insert(0, BACKEND_DIR)

from app.core.config import get_settings  # noqa: E402
from app.core.supabase_client import get_supabase_admin  # noqa: E402
from app.main import app  # noqa: E402

ALL_ROLES = ("admin", "b2b_partner", "broker", "pf_owner", "customer")
NON_ADMIN_ROLES = ("b2b_partner", "broker", "pf_owner", "customer")


@dataclass
class EphemeralUser:
    role: str
    id: str
    email: str
    password: str
    token: str


class RBACStressRunner:
    def __init__(self) -> None:
        self.settings = get_settings()
        if not self.settings.supabase_url or not self.settings.supabase_anon_key or not self.settings.supabase_service_role_key:
            raise RuntimeError("backend/.env precisa conter SUPABASE_URL, SUPABASE_ANON_KEY e SUPABASE_SERVICE_ROLE_KEY.")

        self.rest_base = f"{self.settings.supabase_url.rstrip('/')}/rest/v1"
        self.auth_base = f"{self.settings.supabase_url.rstrip('/')}/auth/v1"
        self.users: Dict[str, EphemeralUser] = {}
        self.created_property_ids: List[str] = []
        self.created_order_ids: List[str] = []
        self.passed = 0
        self.failed = 0

    def _headers(self, bearer_token: str | None = None, prefer_return: bool = False) -> Dict[str, str]:
        token = bearer_token or self.settings.supabase_anon_key
        headers = {
            "apikey": self.settings.supabase_anon_key,
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        }
        if prefer_return:
            headers["Prefer"] = "return=representation"
        return headers

    def record(self, name: str, ok: bool, detail: str = "") -> None:
        tag = "PASS" if ok else "FAIL"
        if ok:
            self.passed += 1
        else:
            self.failed += 1
        suffix = f" | {detail}" if detail else ""
        print(f"[{tag}] {name}{suffix}")

    async def setup_users(self, http: httpx.AsyncClient) -> None:
        admin_sb = await get_supabase_admin()
        run_tag = uuid.uuid4().hex[:8]
        print(f"=== Provisionando 5 usuários efêmeros de stress-test (tag={run_tag}) ===")

        for role in ALL_ROLES:
            email = f"rbac_{role}_{run_tag}@imox-test.local"
            password = f"Rbac!{secrets.token_hex(8)}9A"
            # Mesmo tentando forçar role='admin' no user_metadata, handle_new_user() deve bloquear
            meta_role = "admin" if role == "admin" else role
            created = await admin_sb.auth.admin.create_user(
                {
                    "email": email,
                    "password": password,
                    "email_confirm": True,
                    "user_metadata": {
                        "full_name": f"RBAC Test {role}",
                        "role": meta_role,
                    },
                }
            )
            uid = str(created.user.id)

            # Verifica que o trigger handle_new_user() não permitiu auto-cadastro como admin
            if role == "admin":
                prof_before = (
                    await admin_sb.table("user_profiles").select("role").eq("id", uid).single().execute()
                )
                blocked_signup_admin = prof_before.data["role"] != "admin"
                self.record(
                    "00. Trigger handle_new_user bloqueia role='admin' no signup metadata",
                    blocked_signup_admin,
                    f"role_inicial={prof_before.data['role']}",
                )

            # Ajusta a role exata para o cenário de teste usando service_role
            await admin_sb.table("user_profiles").update({"role": role}).eq("id", uid).execute()

            # Faz login real via GoTrue para obter JWT autêntico do usuário
            login_resp = await http.post(
                f"{self.auth_base}/token?grant_type=password",
                headers=self._headers(),
                json={"email": email, "password": password},
            )
            if login_resp.status_code != 200:
                raise RuntimeError(f"Falha ao autenticar usuário {role}: HTTP {login_resp.status_code} {login_resp.text}")

            token = login_resp.json()["access_token"]
            self.users[role] = EphemeralUser(role=role, id=uid, email=email, password=password, token=token)

        print(f"=== 5 perfis autenticados com JWT real: {', '.join(self.users.keys())} ===\n")

    async def cleanup(self) -> None:
        print("\n=== Limpeza de artefatos efêmeros ===")
        admin_sb = await get_supabase_admin()
        for oid in self.created_order_ids:
            try:
                await admin_sb.table("cartorio_orders").delete().eq("id", oid).execute()
            except Exception as exc:
                print(f"[WARN] Falha ao remover order {oid}: {exc}")
        for pid in self.created_property_ids:
            try:
                await admin_sb.table("properties").delete().eq("id", pid).execute()
            except Exception as exc:
                print(f"[WARN] Falha ao remover property {pid}: {exc}")
        for role, u in self.users.items():
            try:
                await admin_sb.auth.admin.delete_user(u.id)
            except Exception as exc:
                print(f"[WARN] Falha ao remover user {role} ({u.id}): {exc}")
        print("=== Limpeza concluída ===")

    async def run_all(self) -> int:
        async with httpx.AsyncClient(timeout=30.0) as http:
            try:
                await self.setup_users(http)
                admin_sb = await get_supabase_admin()

                # ------------------------------------------------------------------
                # 1. Bloqueio de auto-elevação via RPC admin_change_user_role
                # ------------------------------------------------------------------
                for role in NON_ADMIN_ROLES:
                    u = self.users[role]
                    r = await http.post(
                        f"{self.rest_base}/rpc/admin_change_user_role",
                        headers=self._headers(u.token),
                        json={"target_user_id": u.id, "new_role": "admin"},
                    )
                    prof = await admin_sb.table("user_profiles").select("role").eq("id", u.id).single().execute()
                    ok = r.status_code in (400, 401, 403) and prof.data["role"] == role
                    self.record(
                        f"01. [{role}] bloqueado em RPC admin_change_user_role -> admin",
                        ok,
                        f"HTTP {r.status_code} | role_db={prof.data['role']} | msg={r.text[:90]}",
                    )

                r_anon_rpc = await http.post(
                    f"{self.rest_base}/rpc/admin_change_user_role",
                    headers=self._headers(),
                    json={"target_user_id": self.users["customer"].id, "new_role": "admin"},
                )
                self.record(
                    "01b. [anon] bloqueado em RPC admin_change_user_role",
                    r_anon_rpc.status_code in (401, 403),
                    f"HTTP {r_anon_rpc.status_code}",
                )

                # ------------------------------------------------------------------
                # 2. Bloqueio de auto-elevação via PATCH direto em user_profiles
                # ------------------------------------------------------------------
                for role in NON_ADMIN_ROLES:
                    u = self.users[role]
                    r = await http.patch(
                        f"{self.rest_base}/user_profiles?id=eq.{u.id}",
                        headers=self._headers(u.token, prefer_return=True),
                        json={"role": "admin"},
                    )
                    prof = await admin_sb.table("user_profiles").select("role").eq("id", u.id).single().execute()
                    ok = r.status_code in (400, 401, 403) and prof.data["role"] == role
                    self.record(
                        f"02. [{role}] bloqueado em PATCH direto user_profiles.role -> admin",
                        ok,
                        f"HTTP {r.status_code} | role_db={prof.data['role']} | msg={r.text[:90]}",
                    )

                r_anon_prof = await http.get(f"{self.rest_base}/user_profiles", headers=self._headers())
                self.record(
                    "02b. [anon] bloqueado de ler user_profiles",
                    r_anon_prof.status_code in (401, 403),
                    f"HTTP {r_anon_prof.status_code}",
                )

                # ------------------------------------------------------------------
                # 3. Edição legítima do próprio nome + isolamento entre perfis
                # ------------------------------------------------------------------
                broker = self.users["broker"]
                customer = self.users["customer"]
                r_own_name = await http.patch(
                    f"{self.rest_base}/user_profiles?id=eq.{broker.id}",
                    headers=self._headers(broker.token, prefer_return=True),
                    json={"full_name": "Corretor Validado RBAC"},
                )
                ok_own_name = (
                    r_own_name.status_code == 200
                    and len(r_own_name.json()) == 1
                    and r_own_name.json()[0]["full_name"] == "Corretor Validado RBAC"
                    and r_own_name.json()[0]["role"] == "broker"
                )
                self.record(
                    "03a. [broker] pode atualizar seu próprio full_name sem alterar role",
                    ok_own_name,
                    f"HTTP {r_own_name.status_code}",
                )

                r_cross_read = await http.get(
                    f"{self.rest_base}/user_profiles?id=eq.{customer.id}",
                    headers=self._headers(broker.token),
                )
                r_cross_patch = await http.patch(
                    f"{self.rest_base}/user_profiles?id=eq.{customer.id}",
                    headers=self._headers(broker.token, prefer_return=True),
                    json={"full_name": "Alterado Indevidamente"},
                )
                self.record(
                    "03b. [broker] isolado de ler ou alterar perfil de outro usuário",
                    r_cross_read.status_code == 200
                    and r_cross_read.json() == []
                    and r_cross_patch.status_code == 200
                    and r_cross_patch.json() == [],
                    f"read_rows={len(r_cross_read.json())} patch_rows={len(r_cross_patch.json())}",
                )

                # ------------------------------------------------------------------
                # 4. Bloqueio de inserção de imóvel já como 'approved' por não-admin
                # ------------------------------------------------------------------
                r_fake_approved = await http.post(
                    f"{self.rest_base}/properties",
                    headers=self._headers(broker.token, prefer_return=True),
                    json={
                        "source_id": f"rbac-illegal-{uuid.uuid4().hex[:10]}",
                        "address": "Rua Ilegal 999",
                        "city": "Vitória",
                        "state": "ES",
                        "price": 500000,
                        "area_sqm": 100,
                        "listing_date": "2026-11-16",
                        "property_type": "apartment",
                        "source_url": "https://imobilit.local/test",
                        "approval_status": "approved",
                    },
                )
                self.record(
                    "04. [broker] bloqueado ao tentar inserir imóvel já como 'approved'",
                    r_fake_approved.status_code in (400, 403),
                    f"HTTP {r_fake_approved.status_code} | msg={r_fake_approved.text[:90]}",
                )

                # ------------------------------------------------------------------
                # 5. Inserção legítima pelos 4 perfis não-admin -> nasce 'pending'
                # ------------------------------------------------------------------
                prop_ids_by_role: Dict[str, str] = {}
                for role in NON_ADMIN_ROLES:
                    u = self.users[role]
                    r_ins = await http.post(
                        f"{self.rest_base}/properties",
                        headers=self._headers(u.token, prefer_return=True),
                        json={
                            "source_id": f"rbac-ok-{role}-{uuid.uuid4().hex[:8]}",
                            "address": f"Av. Compliance {role} 100",
                            "city": "Vitória",
                            "state": "ES",
                            "price": 750000,
                            "area_sqm": 120,
                            "listing_date": "2026-11-16",
                            "property_type": "apartment",
                            "source_url": "https://imobilit.local/test",
                        },
                    )
                    rows = r_ins.json() if r_ins.status_code == 201 else []
                    ok = (
                        r_ins.status_code == 201
                        and len(rows) == 1
                        and rows[0]["approval_status"] == "pending"
                        and rows[0]["owner_id"] == u.id
                    )
                    if rows:
                        prop_ids_by_role[role] = rows[0]["id"]
                        self.created_property_ids.append(rows[0]["id"])
                    self.record(
                        f"05. [{role}] insere imóvel próprio -> nasce 'pending' com owner_id do JWT",
                        ok,
                        f"HTTP {r_ins.status_code} | status={rows[0]['approval_status'] if rows else 'ERR'}",
                    )

                broker_prop_id = prop_ids_by_role["broker"]

                # ------------------------------------------------------------------
                # 6. Bloqueio de auto-aprovação, rejeição e troca de owner pelo broker
                # ------------------------------------------------------------------
                r_self_approve = await http.patch(
                    f"{self.rest_base}/properties?id=eq.{broker_prop_id}",
                    headers=self._headers(broker.token, prefer_return=True),
                    json={"approval_status": "approved"},
                )
                r_self_reject = await http.patch(
                    f"{self.rest_base}/properties?id=eq.{broker_prop_id}",
                    headers=self._headers(broker.token, prefer_return=True),
                    json={"approval_status": "rejected"},
                )
                r_hijack_owner = await http.patch(
                    f"{self.rest_base}/properties?id=eq.{broker_prop_id}",
                    headers=self._headers(broker.token, prefer_return=True),
                    json={"owner_id": customer.id},
                )
                prop_check = (
                    await admin_sb.table("properties").select("approval_status, owner_id").eq("id", broker_prop_id).single().execute()
                )
                ok_block_prop = (
                    r_self_approve.status_code in (400, 403)
                    and r_self_reject.status_code in (400, 403)
                    and r_hijack_owner.status_code in (400, 403)
                    and prop_check.data["approval_status"] == "pending"
                    and prop_check.data["owner_id"] == broker.id
                )
                self.record(
                    "06. [broker] bloqueado de aprovar, rejeitar ou trocar titularidade do imóvel",
                    ok_block_prop,
                    f"approve={r_self_approve.status_code} reject={r_self_reject.status_code} owner={r_hijack_owner.status_code}",
                )

                # ------------------------------------------------------------------
                # 7. Visibilidade da vitrine pública (anon) vs dono vs admin
                # ------------------------------------------------------------------
                r_anon_pending = await http.get(
                    f"{self.rest_base}/properties?id=eq.{broker_prop_id}",
                    headers=self._headers(),
                )
                r_cust_pending = await http.get(
                    f"{self.rest_base}/properties?id=eq.{broker_prop_id}",
                    headers=self._headers(customer.token),
                )
                r_owner_pending = await http.get(
                    f"{self.rest_base}/properties?id=eq.{broker_prop_id}",
                    headers=self._headers(broker.token),
                )
                admin_user = self.users["admin"]
                r_admin_pending = await http.get(
                    f"{self.rest_base}/properties?id=eq.{broker_prop_id}",
                    headers=self._headers(admin_user.token),
                )
                ok_vis = (
                    r_anon_pending.json() == []
                    and r_cust_pending.json() == []
                    and len(r_owner_pending.json()) == 1
                    and len(r_admin_pending.json()) == 1
                )
                self.record(
                    "07. Imóvel 'pending' oculto de anon/outros usuários e visível ao dono/admin",
                    ok_vis,
                    f"anon={len(r_anon_pending.json())} cust={len(r_cust_pending.json())} owner={len(r_owner_pending.json())} admin={len(r_admin_pending.json())}",
                )

                # ------------------------------------------------------------------
                # 8. Aprovação exclusiva pelo admin -> libera na vitrine pública (anon)
                # ------------------------------------------------------------------
                r_admin_approve = await http.patch(
                    f"{self.rest_base}/properties?id=eq.{broker_prop_id}",
                    headers=self._headers(admin_user.token, prefer_return=True),
                    json={"approval_status": "approved"},
                )
                r_anon_approved = await http.get(
                    f"{self.rest_base}/properties?id=eq.{broker_prop_id}",
                    headers=self._headers(),
                )
                ok_approve = (
                    r_admin_approve.status_code == 200
                    and len(r_admin_approve.json()) == 1
                    and r_admin_approve.json()[0]["approval_status"] == "approved"
                    and len(r_anon_approved.json()) == 1
                )
                self.record(
                    "08. [admin] aprova imóvel -> torna-se visível na vitrine pública (anon)",
                    ok_approve,
                    f"patch_http={r_admin_approve.status_code} anon_rows={len(r_anon_approved.json())}",
                )

                # ------------------------------------------------------------------
                # 9. Edição de imóvel aprovado pelo broker rebaixa para 'pending'
                # ------------------------------------------------------------------
                r_edit_price = await http.patch(
                    f"{self.rest_base}/properties?id=eq.{broker_prop_id}",
                    headers=self._headers(broker.token, prefer_return=True),
                    json={"price": 820000},
                )
                r_anon_after_edit = await http.get(
                    f"{self.rest_base}/properties?id=eq.{broker_prop_id}",
                    headers=self._headers(),
                )
                r_broker_del = await http.delete(
                    f"{self.rest_base}/properties?id=eq.{broker_prop_id}",
                    headers=self._headers(broker.token),
                )
                ok_recheck = (
                    r_edit_price.status_code == 200
                    and r_edit_price.json()[0]["approval_status"] == "pending"
                    and r_anon_after_edit.json() == []
                    and r_broker_del.status_code in (401, 403)
                )
                self.record(
                    "09. [broker] edita preço -> trava rebaixa para 'pending' e DELETE direto bloqueado",
                    ok_recheck,
                    f"new_status={r_edit_price.json()[0]['approval_status']} anon={len(r_anon_after_edit.json())} del_http={r_broker_del.status_code}",
                )

                # ------------------------------------------------------------------
                # 10. Elevação legítima de perfil via RPC admin_change_user_role (admin)
                # ------------------------------------------------------------------
                r_promote = await http.post(
                    f"{self.rest_base}/rpc/admin_change_user_role",
                    headers=self._headers(admin_user.token),
                    json={"target_user_id": customer.id, "new_role": "broker"},
                )
                prof_after = await admin_sb.table("user_profiles").select("role").eq("id", customer.id).single().execute()
                self.record(
                    "10. [admin] altera perfil de customer -> broker via RPC admin_change_user_role",
                    r_promote.status_code in (200, 204) and prof_after.data["role"] == "broker",
                    f"HTTP {r_promote.status_code} | role_db={prof_after.data['role']}",
                )
                # Restaura customer para o teste de isolamento de pedidos seguinte
                await admin_sb.table("user_profiles").update({"role": "customer"}).eq("id", customer.id).execute()

                # ------------------------------------------------------------------
                # 11. Bloqueio de escrita direta em cartorio_orders via PostgREST
                # ------------------------------------------------------------------
                r_co_anon = await http.get(f"{self.rest_base}/cartorio_orders", headers=self._headers())
                r_co_ins = await http.post(
                    f"{self.rest_base}/cartorio_orders",
                    headers=self._headers(broker.token),
                    json={"user_id": broker.id, "matricula": "99999", "rgi": "1º RI", "status": "concluido"},
                )
                self.record(
                    "11. [anon/broker] bloqueados de ler como anon ou inserir em cartorio_orders",
                    r_co_anon.status_code in (401, 403) and r_co_ins.status_code in (401, 403),
                    f"anon_get={r_co_anon.status_code} broker_post={r_co_ins.status_code}",
                )

                # ------------------------------------------------------------------
                # 12. Pedido real via FastAPI + isolamento de leitura/escrita em cartorio_orders
                # ------------------------------------------------------------------
                async with httpx.AsyncClient(transport=httpx.ASGITransport(app=app), base_url="http://testserver") as api:
                    r_no_jwt = await api.post(
                        "/api/cartorio/solicitar",
                        json={"matricula": "55555", "rgi": "1º RI Vitória"},
                    )
                    r_api_ok = await api.post(
                        "/api/cartorio/solicitar",
                        headers={"Authorization": f"Bearer {broker.token}"},
                        json={
                            "matricula": "55555",
                            "rgi": "1º Ofício de Registro de Imóveis de Vitória/ES",
                            "cartorio_cns": "02.123-4",
                            "tipo_certidao": "matricula_inteiro_teor",
                        },
                    )
                order_id = r_api_ok.json().get("order_id") if r_api_ok.status_code == 202 else None
                if order_id:
                    self.created_order_ids.append(order_id)

                r_co_owner = await http.get(
                    f"{self.rest_base}/cartorio_orders?id=eq.{order_id}",
                    headers=self._headers(broker.token),
                )
                r_co_other = await http.get(
                    f"{self.rest_base}/cartorio_orders?id=eq.{order_id}",
                    headers=self._headers(customer.token),
                )
                r_co_admin = await http.get(
                    f"{self.rest_base}/cartorio_orders?id=eq.{order_id}",
                    headers=self._headers(admin_user.token),
                )
                r_co_forge = await http.patch(
                    f"{self.rest_base}/cartorio_orders?id=eq.{order_id}",
                    headers=self._headers(broker.token),
                    json={"status": "concluido"},
                )
                ok_orders = (
                    r_no_jwt.status_code == 401
                    and r_api_ok.status_code == 202
                    and order_id is not None
                    and len(r_co_owner.json()) == 1
                    and r_co_other.json() == []
                    and len(r_co_admin.json()) == 1
                    and r_co_forge.status_code in (401, 403)
                )
                self.record(
                    "12. FastAPI /api/cartorio/solicitar + isolamento dono/admin/outros e bloqueio de PATCH",
                    ok_orders,
                    f"no_jwt={r_no_jwt.status_code} api={r_api_ok.status_code} owner={len(r_co_owner.json())} other={len(r_co_other.json())} admin={len(r_co_admin.json())} forge={r_co_forge.status_code}",
                )

            finally:
                await self.cleanup()

        print(f"\n=== RESUMO FINAL RBAC: {self.passed} PASSED | {self.failed} FAILED ===")
        return 0 if self.failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(asyncio.run(RBACStressRunner().run_all()))
