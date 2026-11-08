-- ========================================================================================
-- ImobiLit (LIT Capital) - Sincronização Automática de Perfil (Supabase Auth -> user_profiles)
-- Arquivo: 20261108_auth_trigger.sql
-- ========================================================================================

-- 1. Function que insere automaticamente o perfil em public.user_profiles após signup em auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_role public.user_role_enum;
    v_full_name VARCHAR(255);
    v_company_name VARCHAR(255);
BEGIN
    -- Mapeia o perfil selecionado no cadastro (B2C -> customer | B2B -> broker)
    IF (NEW.raw_user_meta_data->>'role') = 'broker'
       OR (NEW.raw_user_meta_data->>'access_profile') = 'B2B' THEN
        v_role := 'broker'::public.user_role_enum;
    ELSE
        v_role := 'customer'::public.user_role_enum;
    END IF;

    -- Garante preenchimento seguro de full_name (coluna NOT NULL)
    v_full_name := COALESCE(
        NULLIF(BTRIM(NEW.raw_user_meta_data->>'full_name'), ''),
        NULLIF(SPLIT_PART( COALESCE(NEW.email, ''), '@', 1), ''),
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
    ON CONFLICT (id) DO NOTHING;

    RETURN NEW;
END;
$$;

-- Hardening de Segurança: impede chamada direta via PostgREST RPC por anon/authenticated
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;

-- 2. Trigger em auth.users disparado a cada novo registro (AFTER INSERT)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_trigger t
        JOIN pg_class c ON c.oid = t.tgrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE t.tgname = 'on_auth_user_created'
          AND n.nspname = 'auth'
          AND c.relname = 'users'
    ) THEN
        CREATE TRIGGER on_auth_user_created
            AFTER INSERT ON auth.users
            FOR EACH ROW
            EXECUTE FUNCTION public.handle_new_user();
    END IF;
END
$$;
