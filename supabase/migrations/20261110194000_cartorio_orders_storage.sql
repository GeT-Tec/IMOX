-- ========================================================================================
-- ImobiLit (LIT Capital) - Vertical 03: Cartório & Integração ONR/SAEC
-- Arquivo: 20261110194000_cartorio_orders_storage.sql
--
-- 1. Tabela public.cartorio_orders (esteira de pedidos de matrículas/certidões)
-- 2. Bucket privado storage 'documentos_oficiais' (PDFs devolvidos pelos cartórios)
-- 3. RLS: leitura apenas pelo dono do pedido ou admin. Escrita exclusiva do backend
--    FastAPI (service_role, que ignora RLS) -> o cliente nunca forja status ou PDF.
-- ========================================================================================

-- ----------------------------------------------------------------------------------------
-- 1. Tabela de pedidos
-- ----------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.cartorio_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    property_id UUID REFERENCES public.properties(id) ON DELETE SET NULL,

    -- Chave de idempotência compartilhada com o ONR (gerada pelo backend)
    transaction_id UUID NOT NULL DEFAULT gen_random_uuid(),

    matricula VARCHAR(100) NOT NULL,
    rgi VARCHAR(255) NOT NULL,                 -- Serventia / Registro de Imóveis de destino
    cartorio_cns VARCHAR(50),                  -- Código Nacional de Serventia (opcional)
    tipo_certidao VARCHAR(100) NOT NULL DEFAULT 'matricula_inteiro_teor',

    status VARCHAR(20) NOT NULL DEFAULT 'solicitado',
    protocolo_onr VARCHAR(100),                -- Protocolo devolvido pelo ONR/SAEC
    documento_path TEXT,                       -- Caminho no bucket: {user_id}/{order_id}.pdf
    error_message TEXT,
    onr_payload JSONB,                         -- Último retorno recebido (auditoria)

    requested_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CONSTRAINT uq_cartorio_orders_transaction_id UNIQUE (transaction_id),
    CONSTRAINT chk_cartorio_orders_status
        CHECK (status IN ('solicitado', 'processando', 'concluido', 'erro'))
);

CREATE INDEX IF NOT EXISTS idx_cartorio_orders_user_id ON public.cartorio_orders(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_cartorio_orders_status ON public.cartorio_orders(status);
CREATE INDEX IF NOT EXISTS idx_cartorio_orders_property_id
    ON public.cartorio_orders(property_id) WHERE property_id IS NOT NULL;

DROP TRIGGER IF EXISTS trg_cartorio_orders_updated_at ON public.cartorio_orders;
CREATE TRIGGER trg_cartorio_orders_updated_at
    BEFORE UPDATE ON public.cartorio_orders
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();

-- ----------------------------------------------------------------------------------------
-- 2. RLS da tabela de pedidos
-- ----------------------------------------------------------------------------------------
ALTER TABLE public.cartorio_orders ENABLE ROW LEVEL SECURITY;

-- Defesa em profundidade: nenhum cliente (anon/authenticated) escreve diretamente.
REVOKE ALL ON public.cartorio_orders FROM anon;
REVOKE INSERT, UPDATE, DELETE ON public.cartorio_orders FROM authenticated;

DROP POLICY IF EXISTS "cartorio_orders_select_owner_or_admin" ON public.cartorio_orders;
CREATE POLICY "cartorio_orders_select_owner_or_admin"
    ON public.cartorio_orders
    FOR SELECT
    TO authenticated
    USING (
        user_id = (SELECT auth.uid())
        OR (SELECT public.is_admin())
    );

-- ----------------------------------------------------------------------------------------
-- 3. Bucket privado de documentos oficiais (somente PDF, até 20 MB)
-- ----------------------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('documentos_oficiais', 'documentos_oficiais', false, 20971520, ARRAY['application/pdf'])
ON CONFLICT (id) DO UPDATE
    SET public = false,
        file_size_limit = EXCLUDED.file_size_limit,
        allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Download (SELECT): apenas o dono (1º segmento do path = auth.uid()) ou admin.
-- Upload/alteração/remoção: sem policy -> exclusivo do backend via service_role.
DROP POLICY IF EXISTS "documentos_oficiais_select_owner_or_admin" ON storage.objects;
CREATE POLICY "documentos_oficiais_select_owner_or_admin"
    ON storage.objects
    FOR SELECT
    TO authenticated
    USING (
        bucket_id = 'documentos_oficiais'
        AND (
            (storage.foldername(name))[1] = (SELECT auth.uid())::text
            OR (SELECT public.is_admin())
        )
    );
