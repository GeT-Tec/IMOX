-- ========================================================================================
-- ImobiLit (LIT Capital) - Fase 2: Motor de Permissões (RBAC Master Hardening)
-- Arquivo: 20261116183000_rbac_phase2_hardening.sql
--
-- Objetivos:
-- 1. Bloquear auto-escalação de privilégios (role) em public.user_profiles via PATCH direto.
-- 2. Garantir que apenas 'admin' altere 'role' (via RPC ou painel) e aprove/rejeite imóveis.
-- 3. Incluir todos os 5 perfis do RBAC ('admin', 'b2b_partner', 'broker', 'pf_owner', 'customer')
--    nas regras de propriedade com trava estrita de compliance ('pending').
-- 4. Revogar privilégios excessivos de 'anon' e 'authenticated' em user_profiles e properties.
-- ========================================================================================

-- ----------------------------------------------------------------------------------------
-- 1. Hardening de Privilégios de Tabela (Defense in Depth)
-- ----------------------------------------------------------------------------------------
REVOKE ALL ON public.user_profiles FROM anon;
REVOKE DELETE ON public.user_profiles FROM authenticated;

REVOKE INSERT, UPDATE, DELETE ON public.properties FROM anon;
REVOKE DELETE ON public.properties FROM authenticated;

-- ----------------------------------------------------------------------------------------
-- 2. Trigger Anti-Escalação em public.user_profiles
-- ----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enforce_user_profile_role_lock()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_jwt_role TEXT;
    v_is_admin BOOLEAN := FALSE;
BEGIN
    v_jwt_role := COALESCE(
        NULLIF(current_setting('request.jwt.claim.role', true), ''),
        NULLIF((NULLIF(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role'), ''),
        ''
    );

    IF v_jwt_role = 'anon' THEN
        RAISE EXCEPTION 'Acesso negado: usuário anônimo não pode modificar perfis.';
    END IF;

    -- Permite operações internas (GoTrue signup via supabase_auth_admin com auth.uid() IS NULL,
    -- postgres superuser, ou backend via service_role).
    IF v_jwt_role <> 'service_role' AND auth.uid() IS NOT NULL THEN
        v_is_admin := public.is_admin();

        IF TG_OP = 'INSERT' THEN
            IF NEW.id IS DISTINCT FROM auth.uid() AND NOT v_is_admin THEN
                RAISE EXCEPTION 'Acesso negado: não é permitido criar perfil para outro usuário.';
            END IF;

            IF NEW.role = 'admin'::public.user_role_enum
               AND NOT v_is_admin
               AND COALESCE(NEW.email, '') <> 'master@litcapital.com.br' THEN
                RAISE EXCEPTION 'Acesso negado: auto-atribuição de perfil admin bloqueada.';
            END IF;
        ELSIF TG_OP = 'UPDATE' THEN
            IF NEW.id IS DISTINCT FROM OLD.id THEN
                RAISE EXCEPTION 'Acesso negado: não é permitido alterar o ID do perfil.';
            END IF;

            IF NEW.role IS DISTINCT FROM OLD.role AND NOT v_is_admin THEN
                RAISE EXCEPTION 'Acesso negado: apenas administradores podem alterar o perfil de acesso (role).';
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.enforce_user_profile_role_lock() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS trg_user_profiles_protect_role ON public.user_profiles;
CREATE TRIGGER trg_user_profiles_protect_role
    BEFORE INSERT OR UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.enforce_user_profile_role_lock();

-- ----------------------------------------------------------------------------------------
-- 3. Helper anti-recursão e Hardening das Policies de RLS em public.user_profiles
-- ----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS public.user_role_enum
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT role
    FROM public.user_profiles
    WHERE id = auth.uid()
    LIMIT 1;
$$;

REVOKE EXECUTE ON FUNCTION public.current_user_role() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.current_user_role() TO authenticated;

DROP POLICY IF EXISTS "users_insert_own_profile" ON public.user_profiles;
CREATE POLICY "users_insert_own_profile"
    ON public.user_profiles
    FOR INSERT
    TO authenticated
    WITH CHECK (
        ((SELECT auth.uid()) = id)
        AND (
            role <> 'admin'::public.user_role_enum
            OR (SELECT public.is_admin())
        )
    );

DROP POLICY IF EXISTS "users_update_own_profile" ON public.user_profiles;
CREATE POLICY "users_update_own_profile"
    ON public.user_profiles
    FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = id)
    WITH CHECK (
        ((SELECT auth.uid()) = id)
        AND (
            role = (SELECT public.current_user_role())
            OR (SELECT public.is_admin())
        )
    );

DROP POLICY IF EXISTS "admin_update_all_profiles" ON public.user_profiles;
CREATE POLICY "admin_update_all_profiles"
    ON public.user_profiles
    FOR UPDATE
    TO authenticated
    USING ((SELECT public.is_admin()))
    WITH CHECK ((SELECT public.is_admin()));

-- ----------------------------------------------------------------------------------------
-- 4. Hardening da Trigger e Policies de Compliance em public.properties
-- ----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.enforce_property_compliance_status()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_jwt_role TEXT;
    v_is_admin BOOLEAN := FALSE;
BEGIN
    v_jwt_role := COALESCE(
        NULLIF(current_setting('request.jwt.claim.role', true), ''),
        NULLIF((NULLIF(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role'), ''),
        ''
    );

    IF v_jwt_role = 'anon' THEN
        RAISE EXCEPTION 'Acesso negado: usuário anônimo não pode modificar imóveis.';
    END IF;

    IF v_jwt_role <> 'service_role' AND auth.uid() IS NOT NULL THEN
        v_is_admin := public.is_admin();

        IF NOT v_is_admin THEN
            IF TG_OP = 'INSERT' THEN
                IF NEW.approval_status IS NOT NULL AND NEW.approval_status <> 'pending' THEN
                    RAISE EXCEPTION 'Acesso negado: apenas administradores podem publicar imóveis com status %.', NEW.approval_status;
                END IF;
                NEW.owner_id := auth.uid();
                NEW.approval_status := 'pending';
            ELSIF TG_OP = 'UPDATE' THEN
                IF NEW.owner_id IS DISTINCT FROM OLD.owner_id THEN
                    RAISE EXCEPTION 'Acesso negado: apenas administradores podem alterar a titularidade do imóvel.';
                END IF;

                IF NEW.approval_status = 'rejected' THEN
                    RAISE EXCEPTION 'Acesso negado: apenas administradores podem rejeitar imóveis.';
                END IF;

                IF NEW.approval_status = 'approved' AND OLD.approval_status <> 'approved' THEN
                    RAISE EXCEPTION 'Acesso negado: apenas administradores podem aprovar imóveis.';
                END IF;

                -- Edições legítimas pelo dono não-admin retornam o imóvel para fila de revisão
                NEW.approval_status := 'pending';
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.enforce_property_compliance_status() FROM PUBLIC, anon, authenticated;

-- Garante cobertura explícita dos 5 perfis do RBAC nas policies de properties
ALTER POLICY "owner_insert_own_properties"
    ON public.properties
    TO authenticated
    WITH CHECK (
        owner_id = (SELECT auth.uid())
        AND approval_status = 'pending'
        AND EXISTS (
            SELECT 1 FROM public.user_profiles up
            WHERE up.id = (SELECT auth.uid())
              AND up.role IN ('customer', 'pf_owner', 'broker', 'b2b_partner', 'admin')
        )
    );

ALTER POLICY "owner_update_own_properties"
    ON public.properties
    TO authenticated
    USING (
        owner_id = (SELECT auth.uid())
        AND EXISTS (
            SELECT 1 FROM public.user_profiles up
            WHERE up.id = (SELECT auth.uid())
              AND up.role IN ('customer', 'pf_owner', 'broker', 'b2b_partner', 'admin')
        )
    )
    WITH CHECK (
        owner_id = (SELECT auth.uid())
        AND approval_status = 'pending'
        AND EXISTS (
            SELECT 1 FROM public.user_profiles up
            WHERE up.id = (SELECT auth.uid())
              AND up.role IN ('customer', 'pf_owner', 'broker', 'b2b_partner', 'admin')
        )
    );
