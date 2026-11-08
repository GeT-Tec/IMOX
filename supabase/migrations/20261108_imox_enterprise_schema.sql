-- ========================================================================================
-- IMOX - Enterprise Schema Migration (Morar / B2B & B2C / Agro / Cartório)
-- Arquivo: 20261108_imox_enterprise_schema.sql
-- ========================================================================================

-- 1. Enumerações de Domínio Adicionais
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role_enum') THEN
        CREATE TYPE public.user_role_enum AS ENUM ('customer', 'broker', 'cartorio', 'builder');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'development_status_enum') THEN
        CREATE TYPE public.development_status_enum AS ENUM ('pre_launch', 'launch', 'under_construction', 'ready');
    END IF;
END
$$;

-- Expansão segura do enum de tipos de imóveis para suportar Agro e Lotes
ALTER TYPE public.property_type_enum ADD VALUE IF NOT EXISTS 'rural';
ALTER TYPE public.property_type_enum ADD VALUE IF NOT EXISTS 'land';
ALTER TYPE public.property_type_enum ADD VALUE IF NOT EXISTS 'commercial';

-- ========================================================================================
-- 2. Perfis de Usuários B2B / B2C (user_profiles)
-- Vinculada diretamente ao auth.users do Supabase Auth
-- ========================================================================================
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role public.user_role_enum NOT NULL DEFAULT 'customer',
    full_name VARCHAR(255) NOT NULL,
    document_number VARCHAR(30),          -- CPF (B2C) ou CNPJ (B2B: Construtora, Imobiliária, Cartório)
    company_name VARCHAR(255),            -- Nome fantasia / Razão Social para operações B2B
    creci VARCHAR(50),                    -- Registro CRECI (quando role = 'broker')
    cns_cartorio VARCHAR(50),             -- Código Nacional de Serventia (quando role = 'cartorio')
    phone VARCHAR(30),
    avatar_url TEXT,
    broker_id UUID REFERENCES public.brokers(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX IF NOT EXISTS idx_user_profiles_broker_id ON public.user_profiles(broker_id);

-- ========================================================================================
-- 3. Incorporação e Lançamentos / Operação Morar (developments)
-- Representa empreendimentos imobiliários, condomínios horizontais/verticais e loteamentos
-- ========================================================================================
CREATE TABLE IF NOT EXISTS public.developments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    builder_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    builder_name VARCHAR(255) NOT NULL DEFAULT 'Morar Construtora',
    description TEXT,
    status public.development_status_enum NOT NULL DEFAULT 'launch',
    address TEXT NOT NULL,
    neighborhood VARCHAR(150),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(2) NOT NULL,
    zipcode VARCHAR(20),
    location GEOGRAPHY(POINT, 4326),
    total_units INTEGER NOT NULL DEFAULT 0,
    available_units INTEGER NOT NULL DEFAULT 0,
    delivery_date DATE,
    incorporation_registry VARCHAR(150),  -- Registro de Incorporação na matrícula mãe
    amenities TEXT[] NOT NULL DEFAULT '{}',
    images TEXT[] NOT NULL DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_developments_builder_id ON public.developments(builder_id);
CREATE INDEX IF NOT EXISTS idx_developments_city_status ON public.developments(city, status);
CREATE INDEX IF NOT EXISTS idx_developments_location ON public.developments USING GIST (location);

-- ========================================================================================
-- 4. Extensão da Tabela de Imóveis (properties)
-- Suporte nativo a Unidades de Empreendimentos (Morar), Agro e Cartório
-- ========================================================================================
ALTER TABLE public.properties
    -- Vínculo com Empreendimentos / Lançamentos (Morar)
    ADD COLUMN IF NOT EXISTS development_id UUID REFERENCES public.developments(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS unit_identifier VARCHAR(100),

    -- Atributos Agro / Rurais
    ADD COLUMN IF NOT EXISTS numero_car VARCHAR(100),
    ADD COLUMN IF NOT EXISTS area_total_ha NUMERIC(12, 4),
    ADD COLUMN IF NOT EXISTS area_reserva_ha NUMERIC(12, 4),
    ADD COLUMN IF NOT EXISTS recursos_hidricos TEXT[] DEFAULT '{}',
    ADD COLUMN IF NOT EXISTS perimeter_polygon GEOGRAPHY(POLYGON, 4326),

    -- Atributos de Cartório / Compliance Jurídico
    ADD COLUMN IF NOT EXISTS matricula VARCHAR(100),
    ADD COLUMN IF NOT EXISTS rgi VARCHAR(255),
    ADD COLUMN IF NOT EXISTS status_juridico VARCHAR(100) NOT NULL DEFAULT 'regular';

-- Índices para as novas colunas de busca, chaves estrangeiras e geoespacial
CREATE INDEX IF NOT EXISTS idx_properties_broker_id ON public.properties(broker_id);
CREATE INDEX IF NOT EXISTS idx_properties_development_id ON public.properties(development_id);
CREATE INDEX IF NOT EXISTS idx_properties_matricula ON public.properties(matricula) WHERE matricula IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_properties_numero_car ON public.properties(numero_car) WHERE numero_car IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_properties_status_juridico ON public.properties(status_juridico);
CREATE INDEX IF NOT EXISTS idx_properties_perimeter_polygon ON public.properties USING GIST (perimeter_polygon);

-- ========================================================================================
-- 5. Triggers de Atualização Automática (updated_at) e Hardening de search_path
-- ========================================================================================
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_user_profiles_updated_at
BEFORE UPDATE ON public.user_profiles
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_developments_updated_at
BEFORE UPDATE ON public.developments
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

-- ========================================================================================
-- 6. Row Level Security (RLS) e Políticas de Acesso
-- ========================================================================================
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.developments ENABLE ROW LEVEL SECURITY;

-- Políticas para user_profiles:
CREATE POLICY "users_read_own_profile"
    ON public.user_profiles
    FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = id);

CREATE POLICY "users_update_own_profile"
    ON public.user_profiles
    FOR UPDATE
    TO authenticated
    USING ((SELECT auth.uid()) = id)
    WITH CHECK ((SELECT auth.uid()) = id);

CREATE POLICY "users_insert_own_profile"
    ON public.user_profiles
    FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT auth.uid()) = id);

-- Políticas para developments (Empreendimentos):
CREATE POLICY "public_read_developments"
    ON public.developments
    FOR SELECT
    TO anon, authenticated
    USING (true);

CREATE POLICY "builders_insert_developments"
    ON public.developments
    FOR INSERT
    TO authenticated
    WITH CHECK (
        builder_id = (SELECT auth.uid())
        AND EXISTS (
            SELECT 1 FROM public.user_profiles up
            WHERE up.id = (SELECT auth.uid()) AND up.role = 'builder'
        )
    );

CREATE POLICY "builders_update_developments"
    ON public.developments
    FOR UPDATE
    TO authenticated
    USING (builder_id = (SELECT auth.uid()))
    WITH CHECK (builder_id = (SELECT auth.uid()));
