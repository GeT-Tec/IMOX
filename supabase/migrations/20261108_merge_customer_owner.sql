-- ========================================================================================
-- ImobiLit (LIT Capital) - Unificação de Perfil: Depreciação de pf_owner em customer
-- Arquivo: 20261108_merge_customer_owner.sql
-- ========================================================================================

-- 1. Atualizar todos os perfis existentes em public.user_profiles de 'pf_owner' para 'customer'
UPDATE public.user_profiles
SET role = 'customer'::public.user_role_enum,
    updated_at = NOW()
WHERE role = 'pf_owner'::public.user_role_enum;

-- 2. Atualizar a function de sincronização de Auth (handle_new_user) para mapear qualquer
--    cadastro PF para 'customer' (Usuário / Proprietário PF)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_role public.user_role_enum;
    v_raw_role TEXT;
    v_full_name VARCHAR(255);
    v_company_name VARCHAR(255);
BEGIN
    v_raw_role := COALESCE(NEW.raw_user_meta_data->>'role', '');

    -- Jamais permite que um auto-cadastro público defina 'admin' (exceto o e-mail master institucional)
    IF NEW.email = 'master@litcapital.com.br' THEN
        v_role := 'admin'::public.user_role_enum;
    ELSIF v_raw_role IN ('b2b_partner', 'broker', 'customer') THEN
        v_role := v_raw_role::public.user_role_enum;
    ELSIF v_raw_role = 'pf_owner' THEN
        v_role := 'customer'::public.user_role_enum;
    ELSIF (NEW.raw_user_meta_data->>'access_profile') = 'B2B' THEN
        v_role := 'b2b_partner'::public.user_role_enum;
    ELSE
        v_role := 'customer'::public.user_role_enum;
    END IF;

    v_full_name := COALESCE(
        NULLIF(BTRIM(NEW.raw_user_meta_data->>'full_name'), ''),
        NULLIF(BTRIM(NEW.raw_user_meta_data->>'name'), ''),
        NULLIF(SPLIT_PART(COALESCE(NEW.email, ''), '@', 1), ''),
        'Usuário ImobiLit'
    );

    v_company_name := NULLIF(BTRIM(NEW.raw_user_meta_data->>'company_name'), '');

    INSERT INTO public.user_profiles (
        id,
        email,
        role,
        full_name,
        company_name
    )
    VALUES (
        NEW.id,
        NEW.email,
        v_role,
        v_full_name,
        v_company_name
    )
    ON CONFLICT (id) DO UPDATE
        SET email = COALESCE(EXCLUDED.email, public.user_profiles.email),
            full_name = COALESCE(NULLIF(EXCLUDED.full_name, 'Usuário ImobiLit'), public.user_profiles.full_name),
            company_name = COALESCE(EXCLUDED.company_name, public.user_profiles.company_name),
            updated_at = NOW();

    RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;

-- 3. Alterar as Policies de INSERT e UPDATE de public.properties para empoderar 'customer'
--    como "Usuário / Proprietário PF" (o trigger trg_properties_compliance_lock garante status 'pending')
ALTER POLICY "owner_insert_own_properties"
    ON public.properties
    TO authenticated
    WITH CHECK (
        owner_id = (SELECT auth.uid())
        AND approval_status = 'pending'
        AND EXISTS (
            SELECT 1 FROM public.user_profiles up
            WHERE up.id = (SELECT auth.uid())
              AND up.role IN ('customer', 'broker', 'b2b_partner', 'admin')
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
              AND up.role IN ('customer', 'broker', 'b2b_partner', 'admin')
        )
    )
    WITH CHECK (
        owner_id = (SELECT auth.uid())
        AND approval_status = 'pending'
        AND EXISTS (
            SELECT 1 FROM public.user_profiles up
            WHERE up.id = (SELECT auth.uid())
              AND up.role IN ('customer', 'broker', 'b2b_partner', 'admin')
        )
    );
