-- Atualiza a function de trigger de novos usuários para reconhecer os 5 perfis do Marketplace
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

    IF NEW.email = 'master@litcapital.com.br' THEN
        v_role := 'admin'::public.user_role_enum;
    ELSIF v_raw_role IN ('b2b_partner', 'broker', 'pf_owner', 'customer') THEN
        v_role := v_raw_role::public.user_role_enum;
    ELSIF (NEW.raw_user_meta_data->>'access_profile') = 'B2B' THEN
        v_role := 'b2b_partner'::public.user_role_enum;
    ELSE
        v_role := 'customer'::public.user_role_enum;
    END IF;

    v_full_name := COALESCE(
        NULLIF(BTRIM(NEW.raw_user_meta_data->>'full_name'), ''),
        NULLIF(SPLIT_PART(COALESCE(NEW.email, ''), '@', 1), ''),
        'Usuário ImobiLit'
    );

    v_company_name := NULLIF(BTRIM(NEW.raw_user_meta_data->>'company_name'), '');

    INSERT INTO public.user_profiles (
        id,
        role,
        full_name,
        company_name
    )
    VALUES (
        NEW.id,
        v_role,
        v_full_name,
        v_company_name
    )
    ON CONFLICT (id) DO UPDATE
        SET role = EXCLUDED.role,
            full_name = EXCLUDED.full_name,
            company_name = COALESCE(EXCLUDED.company_name, public.user_profiles.company_name),
            updated_at = NOW();

    RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;

-- ========================================================================================
-- PASSO 2: Trava de Compliance nos Anúncios (properties)
-- ========================================================================================
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

-- Trigger que força retorno para 'pending' sempre que o dono (não-admin) inserir ou editar seu anúncio
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

-- Atualização das Policies (RLS) da tabela public.properties
-- 1. SELECT público: apenas imóveis com approval_status = 'approved'
ALTER POLICY "public_read_properties"
    ON public.properties
    TO anon, authenticated
    USING (approval_status = 'approved');

-- 2. SELECT/UPDATE/INSERT Admin: acesso irrestrito a todos os imóveis
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public' AND tablename = 'properties' AND policyname = 'admin_select_all_properties'
    ) THEN
        CREATE POLICY "admin_select_all_properties"
            ON public.properties
            FOR SELECT
            TO authenticated
            USING (
                EXISTS (
                    SELECT 1 FROM public.user_profiles up
                    WHERE up.id = (SELECT auth.uid()) AND up.role = 'admin'
                )
            );
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public' AND tablename = 'properties' AND policyname = 'admin_update_all_properties'
    ) THEN
        CREATE POLICY "admin_update_all_properties"
            ON public.properties
            FOR UPDATE
            TO authenticated
            USING (
                EXISTS (
                    SELECT 1 FROM public.user_profiles up
                    WHERE up.id = (SELECT auth.uid()) AND up.role = 'admin'
                )
            )
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM public.user_profiles up
                    WHERE up.id = (SELECT auth.uid()) AND up.role = 'admin'
                )
            );
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public' AND tablename = 'properties' AND policyname = 'admin_insert_all_properties'
    ) THEN
        CREATE POLICY "admin_insert_all_properties"
            ON public.properties
            FOR INSERT
            TO authenticated
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM public.user_profiles up
                    WHERE up.id = (SELECT auth.uid()) AND up.role = 'admin'
                )
            );
    END IF;

    -- 3. Dono do anúncio: SELECT próprio + INSERT/UPDATE voltando para 'pending'
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public' AND tablename = 'properties' AND policyname = 'owner_select_own_properties'
    ) THEN
        CREATE POLICY "owner_select_own_properties"
            ON public.properties
            FOR SELECT
            TO authenticated
            USING (owner_id = (SELECT auth.uid()));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public' AND tablename = 'properties' AND policyname = 'owner_insert_own_properties'
    ) THEN
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
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public' AND tablename = 'properties' AND policyname = 'owner_update_own_properties'
    ) THEN
        CREATE POLICY "owner_update_own_properties"
            ON public.properties
            FOR UPDATE
            TO authenticated
            USING (owner_id = (SELECT auth.uid()))
            WITH CHECK (
                owner_id = (SELECT auth.uid())
                AND approval_status = 'pending'
            );
    END IF;
END
$$;

-- Também permite que o Admin leia todos os user_profiles para gestão da plataforma
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public' AND tablename = 'user_profiles' AND policyname = 'admin_read_all_profiles'
    ) THEN
        CREATE POLICY "admin_read_all_profiles"
            ON public.user_profiles
            FOR SELECT
            TO authenticated
            USING (
                (SELECT auth.uid()) = id
                OR EXISTS (
                    SELECT 1 FROM public.user_profiles up
                    WHERE up.id = (SELECT auth.uid()) AND up.role = 'admin'
                )
            );
    END IF;
END
$$;

-- ========================================================================================
-- PASSO 3: Criação da Conta MASTER FULL (master@litcapital.com.br)
-- ========================================================================================
DO $$
DECLARE
    v_master_id UUID := '00000000-0000-0000-0000-000000000001';
    v_existing_id UUID;
BEGIN
    SELECT id INTO v_existing_id
    FROM auth.users
    WHERE email = 'master@litcapital.com.br'
    LIMIT 1;

    IF v_existing_id IS NULL THEN
        INSERT INTO auth.users (
            instance_id,
            id,
            aud,
            role,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at,
            confirmation_token,
            email_change,
            email_change_token_new,
            recovery_token
        )
        VALUES (
            '00000000-0000-0000-0000-000000000000',
            v_master_id,
            'authenticated',
            'authenticated',
            'master@litcapital.com.br',
            extensions.crypt('AdminMaster123!', extensions.gen_salt('bf')),
            NOW(),
            '{"provider": "email", "providers": ["email"]}'::jsonb,
            '{"full_name": "LIT Capital Master", "role": "admin"}'::jsonb,
            NOW(),
            NOW(),
            '',
            '',
            '',
            ''
        );

        INSERT INTO auth.identities (
            id,
            user_id,
            identity_data,
            provider,
            provider_id,
            last_sign_in_at,
            created_at,
            updated_at
        )
        VALUES (
            extensions.uuid_generate_v4(),
            v_master_id,
            jsonb_build_object(
                'sub', v_master_id::text,
                'email', 'master@litcapital.com.br',
                'email_verified', true,
                'phone_verified', false
            ),
            'email',
            v_master_id::text,
            NOW(),
            NOW(),
            NOW()
        );
    ELSE
        v_master_id := v_existing_id;
        UPDATE auth.users
        SET encrypted_password = extensions.crypt('AdminMaster123!', extensions.gen_salt('bf')),
            email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
            raw_user_meta_data = '{"full_name": "LIT Capital Master", "role": "admin"}'::jsonb,
            updated_at = NOW()
        WHERE id = v_master_id;
    END IF;

    -- Garante gravação em public.user_profiles com role = 'admin' e full_name = 'LIT Capital Master'
    INSERT INTO public.user_profiles (
        id,
        role,
        full_name,
        company_name
    )
    VALUES (
        v_master_id,
        'admin'::public.user_role_enum,
        'LIT Capital Master',
        'LIT Capital'
    )
    ON CONFLICT (id) DO UPDATE
        SET role = 'admin'::public.user_role_enum,
            full_name = 'LIT Capital Master',
            company_name = 'LIT Capital',
            updated_at = NOW();
END
$$;