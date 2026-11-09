-- ========================================================================================
-- ImobiLit (LIT Capital) - RBAC 5 Pontas, Compliance de Anúncios e Conta Master Full
-- Arquivo: 20261108_rbac_marketplace_compliance.sql
-- ========================================================================================

-- PASSO 1: Expansão do RBAC (5 níveis exatos em user_role_enum)
-- 1. admin (Master Full da LIT Capital)
-- 2. b2b_partner (Imobiliárias e CNPJs parceiros)
-- 3. broker (Corretor Autônomo com CRECI)
-- 4. pf_owner (Pessoa Física Anunciante)
-- 5. customer (Usuário comum apenas buscando comprar/alugar)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_enum e
        JOIN pg_type t ON t.oid = e.enumtypid
        WHERE t.typname = 'user_role_enum' AND e.enumlabel = 'cartorio'
    ) THEN
        ALTER TYPE public.user_role_enum RENAME VALUE 'cartorio' TO 'admin';
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_enum e
        JOIN pg_type t ON t.oid = e.enumtypid
        WHERE t.typname = 'user_role_enum' AND e.enumlabel = 'builder'
    ) THEN
        ALTER TYPE public.user_role_enum RENAME VALUE 'builder' TO 'b2b_partner';
    END IF;
END
$$;

ALTER TYPE public.user_role_enum ADD VALUE IF NOT EXISTS 'pf_owner';
ALTER TYPE public.user_role_enum ADD VALUE IF NOT EXISTS 'admin';
ALTER TYPE public.user_role_enum ADD VALUE IF NOT EXISTS 'b2b_partner';

-- Helper seguro anti-recursão RLS para validar se o usuário autenticado é admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.user_profiles
        WHERE id = auth.uid()
          AND role = 'admin'::public.user_role_enum
    );
$$;

REVOKE EXECUTE ON FUNCTION public.is_admin() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

-- PASSO 2: Trava de Compliance nos Anúncios (properties)
ALTER TABLE public.properties
    ADD COLUMN IF NOT EXISTS owner_id UUID REFERENCES auth.users(id) ON DELETE SET NULL DEFAULT auth.uid(),
    ADD COLUMN IF NOT EXISTS approval_status VARCHAR(20) NOT NULL DEFAULT 'pending';

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'chk_properties_approval_status'
    ) THEN
        ALTER TABLE public.properties
            ADD CONSTRAINT chk_properties_approval_status
            CHECK (approval_status IN ('pending', 'approved', 'rejected'));
    END IF;
END
$$;

CREATE INDEX IF NOT EXISTS idx_properties_owner_id ON public.properties(owner_id);
CREATE INDEX IF NOT EXISTS idx_properties_approval_status ON public.properties(approval_status);

-- Trigger que retorna approval_status para 'pending' em toda inserção ou edição pelo dono do anúncio
CREATE OR REPLACE FUNCTION public.enforce_property_compliance_status()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_is_admin BOOLEAN := FALSE;
BEGIN
    IF auth.uid() IS NOT NULL THEN
        SELECT EXISTS (
            SELECT 1 FROM public.user_profiles up
            WHERE up.id = auth.uid() AND up.role = 'admin'
        ) INTO v_is_admin;
    END IF;

    IF TG_OP = 'INSERT' THEN
        IF NEW.owner_id IS NULL AND auth.uid() IS NOT NULL THEN
            NEW.owner_id := auth.uid();
        END IF;
        IF NOT v_is_admin AND auth.uid() IS NOT NULL THEN
            NEW.approval_status := 'pending';
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        IF NOT v_is_admin AND auth.uid() IS NOT NULL THEN
            NEW.approval_status := 'pending';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.enforce_property_compliance_status() FROM PUBLIC, anon, authenticated;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgname = 'trg_properties_compliance_lock'
    ) THEN
        CREATE TRIGGER trg_properties_compliance_lock
            BEFORE INSERT OR UPDATE ON public.properties
            FOR EACH ROW
            EXECUTE FUNCTION public.enforce_property_compliance_status();
    END IF;
END
$$;

-- Policies (RLS) em public.properties
ALTER POLICY "public_read_properties"
    ON public.properties
    TO anon, authenticated
    USING (approval_status = 'approved');

CREATE POLICY "admin_select_all_properties"
    ON public.properties
    FOR SELECT
    TO authenticated
    USING ((SELECT public.is_admin()));

CREATE POLICY "admin_update_all_properties"
    ON public.properties
    FOR UPDATE
    TO authenticated
    USING ((SELECT public.is_admin()))
    WITH CHECK ((SELECT public.is_admin()));

CREATE POLICY "admin_insert_all_properties"
    ON public.properties
    FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT public.is_admin()));

CREATE POLICY "owner_select_own_properties"
    ON public.properties
    FOR SELECT
    TO authenticated
    USING (owner_id = (SELECT auth.uid()));

CREATE POLICY "owner_insert_own_properties"
    ON public.properties
    FOR INSERT
    TO authenticated
    WITH CHECK (
        owner_id = (SELECT auth.uid())
        AND approval_status = 'pending'
        AND EXISTS (
            SELECT 1 FROM public.user_profiles up
            WHERE up.id = (SELECT auth.uid())
              AND up.role IN ('pf_owner', 'broker', 'b2b_partner', 'admin')
        )
    );

CREATE POLICY "owner_update_own_properties"
    ON public.properties
    FOR UPDATE
    TO authenticated
    USING (owner_id = (SELECT auth.uid()))
    WITH CHECK (
        owner_id = (SELECT auth.uid())
        AND approval_status = 'pending'
    );
