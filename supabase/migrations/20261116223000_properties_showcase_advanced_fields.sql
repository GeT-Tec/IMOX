-- ========================================================================================
-- ImobiLit (LIT Capital) - Vertical 01: Usabilidade Avançada da Vitrine de Anúncios
-- Arquivo: 20261116223000_properties_showcase_advanced_fields.sql
-- ========================================================================================

-- Adiciona campos analíticos, de compliance e de inteligência na tabela properties:
-- 1. lit_certified (boolean, default false): Selo de Lastro Checado (Auditoria LIT Capital).
-- 2. public_documents (jsonb, default '[]'::jsonb): Documentos públicos homologados exibíveis na vitrine.
-- 3. show_market_price (boolean, default true): Controle do anunciante para exibir/ocultar o termômetro.
-- 4. regional_avg_price (numeric, nullable): Preço médio do m² na região para cálculo do termômetro.

ALTER TABLE public.properties
    ADD COLUMN IF NOT EXISTS lit_certified BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS public_documents JSONB NOT NULL DEFAULT '[]'::jsonb,
    ADD COLUMN IF NOT EXISTS show_market_price BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS regional_avg_price NUMERIC(15, 2);

-- Índices para otimização de filtros da vitrine
CREATE INDEX IF NOT EXISTS idx_properties_lit_certified ON public.properties(lit_certified);
CREATE INDEX IF NOT EXISTS idx_properties_show_market_price ON public.properties(show_market_price);

COMMENT ON COLUMN public.properties.lit_certified IS 'Selo de Lastro Checado: indica auditoria e homologação documental pela curadoria LIT Capital.';
COMMENT ON COLUMN public.properties.public_documents IS 'Metadados e URLs de documentos e certidões públicas validadas para exibição na vitrine.';
COMMENT ON COLUMN public.properties.show_market_price IS 'Controle do anunciante/plataforma para habilitar o termômetro de mercado na vitrine.';
COMMENT ON COLUMN public.properties.regional_avg_price IS 'Valor de referência do m² médio na região para cálculo do termômetro de preço.';

-- ========================================================================================
-- GATE 1: Hardening Anti-Fraude do Selo de Lastro Checado (lit_certified)
-- ========================================================================================
-- Apenas a curadoria Master (admin) pode conceder ou alterar a certificação LIT Capital.
-- Qualquer edição por usuário comum reseta a certificação e força retorno para pending.

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

                -- Anti-fraude do Selo LIT: novo anúncio de não-admin jamais nasce certificado
                NEW.lit_certified := FALSE;
                NEW.owner_id := auth.uid();
                NEW.approval_status := 'pending';

            ELSIF TG_OP = 'UPDATE' THEN
                IF NEW.owner_id IS DISTINCT FROM OLD.owner_id THEN
                    RAISE EXCEPTION 'Acesso negado: apenas administradores podem alterar a titularidade do imóvel.';
                END IF;

                -- Anti-fraude do Selo LIT: não-admin não pode alterar o status da certificação
                IF NEW.lit_certified IS DISTINCT FROM OLD.lit_certified THEN
                    RAISE EXCEPTION 'Acesso negado: apenas a curadoria Master (admin) pode certificar o lastro LIT Capital.';
                END IF;

                IF NEW.approval_status = 'rejected' THEN
                    RAISE EXCEPTION 'Acesso negado: apenas administradores podem rejeitar imóveis.';
                END IF;

                IF NEW.approval_status = 'approved' AND OLD.approval_status <> 'approved' THEN
                    RAISE EXCEPTION 'Acesso negado: apenas administradores podem aprovar imóveis.';
                END IF;

                -- Edições legítimas pelo dono não-admin retornam o imóvel para fila de revisão
                -- e revogam a certificação prévia até nova homologação pela curadoria
                NEW.lit_certified := FALSE;
                NEW.approval_status := 'pending';
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.enforce_property_compliance_status() FROM PUBLIC, anon, authenticated;

-- Garante que a trigger de compliance está registrada na tabela properties
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
