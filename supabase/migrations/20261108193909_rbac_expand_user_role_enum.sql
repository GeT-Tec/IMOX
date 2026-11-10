-- ========================================================================================
-- ImobiLit (LIT Capital) - RBAC Expansão do Enum de Roles
-- Arquivo: 20261108193909_rbac_expand_user_role_enum.sql
-- ========================================================================================

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
