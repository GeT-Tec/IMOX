-- ========================================================================================
-- ImobiLit (LIT Capital) - RPC Segura de Gestão e Elevação de Perfil (Super Admin)
-- Arquivo: 20261108_admin_role_management.sql
-- ========================================================================================

-- 1. Garantir coluna de e-mail sincronizada em public.user_profiles para listagem corporativa
ALTER TABLE public.user_profiles
    ADD COLUMN IF NOT EXISTS email VARCHAR(255);

-- Backfill de e-mails existentes a partir de auth.users
UPDATE public.user_profiles up
SET email = u.email
FROM auth.users u
WHERE up.id = u.id
  AND (up.email IS NULL OR up.email <> u.email);

-- Atualizar handle_new_user() para gravar também o email automaticamente no cadastro/OAuth
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
    ELSIF v_raw_role IN ('b2b_partner', 'broker', 'pf_owner', 'customer') THEN
        v_role := v_raw_role::public.user_role_enum;
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

-- ========================================================================================
-- 2. RPC: admin_change_user_role(target_user_id UUID, new_role public.user_role_enum)
-- ========================================================================================
CREATE OR REPLACE FUNCTION public.admin_change_user_role(
    target_user_id UUID,
    new_role public.user_role_enum
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_caller_id UUID;
    v_is_caller_admin BOOLEAN := FALSE;
BEGIN
    v_caller_id := auth.uid();

    -- Verifica se o usuário logado possui role = 'admin' na tabela public.user_profiles
    IF v_caller_id IS NOT NULL THEN
        SELECT EXISTS (
            SELECT 1
            FROM public.user_profiles up
            WHERE up.id = v_caller_id
              AND up.role = 'admin'::public.user_role_enum
        ) INTO v_is_caller_admin;
    END IF;

    IF NOT v_is_caller_admin THEN
        RAISE EXCEPTION 'Acesso negado';
    END IF;

    -- Executa a alteração do perfil do usuário alvo
    UPDATE public.user_profiles
    SET role = new_role,
        updated_at = NOW()
    WHERE id = target_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Usuário alvo não encontrado em user_profiles';
    END IF;
END;
$$;

-- Hardening de permissões de execução da RPC
REVOKE EXECUTE ON FUNCTION public.admin_change_user_role(UUID, public.user_role_enum) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_change_user_role(UUID, public.user_role_enum) TO authenticated;
