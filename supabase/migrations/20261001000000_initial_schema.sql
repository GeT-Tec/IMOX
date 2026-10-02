-- ========================================================================================
-- IMOX - Portal Imobiliário Analítico
-- Arquivo DDL: Inicialização do Banco de Dados Supabase (PostgreSQL 15+)
-- ========================================================================================

-- 1. Ativação de extensões essenciais
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- 2. Enumerações de domínio
CREATE TYPE property_status_enum AS ENUM ('for_sale', 'sold', 'precon', 'rental');
CREATE TYPE property_type_enum AS ENUM ('condo', 'townhouse', 'detached', 'apartment', 'house');
CREATE TYPE history_event_enum AS ENUM ('listed', 'price_change', 'sold', 'delisted');

-- 3. Entidade de Corretores (Broker)
CREATE TABLE IF NOT EXISTS brokers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_broker_id VARCHAR(100) UNIQUE,
    nome VARCHAR(255) NOT NULL,
    creci VARCHAR(50) NOT NULL,
    foto_url TEXT,
    tempo_de_casa VARCHAR(100),
    imoveis_cadastrados INTEGER DEFAULT 0,
    negocios_fechados INTEGER DEFAULT 0,
    valor_geral_vendas NUMERIC(15, 2) DEFAULT 0.00,
    microsite_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Entidade de Imóveis (Property)
CREATE TABLE IF NOT EXISTS properties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_id VARCHAR(100) UNIQUE NOT NULL,
    broker_id UUID REFERENCES brokers(id) ON DELETE SET NULL,
    address TEXT NOT NULL,
    street VARCHAR(255),
    neighborhood VARCHAR(150),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(2) NOT NULL,
    zipcode VARCHAR(20),
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    price NUMERIC(15, 2) NOT NULL,
    condo_fee NUMERIC(10, 2),
    tax_fee NUMERIC(10, 2),
    area_sqm NUMERIC(10, 2) NOT NULL,
    listing_date DATE NOT NULL,
    status property_status_enum NOT NULL DEFAULT 'for_sale',
    property_type property_type_enum NOT NULL,
    bedrooms INTEGER NOT NULL DEFAULT 0,
    bathrooms INTEGER NOT NULL DEFAULT 0,
    parking INTEGER NOT NULL DEFAULT 0,
    images TEXT[] NOT NULL DEFAULT '{}',
    features TEXT[] NOT NULL DEFAULT '{}',
    source_url TEXT NOT NULL,
    view_count INTEGER DEFAULT 0,
    condominium_name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Histórico de Preços (PriceHistory)
CREATE TABLE IF NOT EXISTS price_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    price NUMERIC(15, 2) NOT NULL,
    event history_event_enum NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Métricas e Inteligência de Mercado (MarketStats)
CREATE TABLE IF NOT EXISTS market_stats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    region_id VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    neighborhood VARCHAR(150),
    period DATE NOT NULL,
    avg_price NUMERIC(15, 2) NOT NULL,
    avg_price_sqm NUMERIC(10, 2) NOT NULL,
    inventory INTEGER NOT NULL,
    absorption_rate NUMERIC(5, 2) NOT NULL,
    trend VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT uq_region_period UNIQUE (region_id, period)
);

-- 7. Índices geoespaciais e de performance
CREATE INDEX IF NOT EXISTS idx_properties_location ON properties USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_properties_search ON properties (city, status, property_type, price);
CREATE INDEX IF NOT EXISTS idx_price_history_property ON price_history (property_id, date DESC);

-- ========================================================================================
-- ROW LEVEL SECURITY (RLS) E SEGURANÇA
-- ========================================================================================

-- Habilitando RLS em todas as tabelas
ALTER TABLE brokers ENABLE ROW LEVEL SECURITY;
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE price_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE market_stats ENABLE ROW LEVEL SECURITY;

-- Políticas de Leitura Pública (Apenas permissão SELECT para clientes via PostgREST)
-- Isso garante que o frontend Next.js usando a `anon_key` possa apenas ler os dados.
CREATE POLICY "Permitir leitura publica em brokers" ON brokers FOR SELECT USING (true);
CREATE POLICY "Permitir leitura publica em properties" ON properties FOR SELECT USING (true);
CREATE POLICY "Permitir leitura publica em price_history" ON price_history FOR SELECT USING (true);
CREATE POLICY "Permitir leitura publica em market_stats" ON market_stats FOR SELECT USING (true);

-- NOTA ARQUITETURAL: 
-- O Crawler Node.js deverá autenticar utilizando a `service_role_key`. 
-- O Supabase, por padrão, concede permissão de bypass RLS para a role `service_role`.
-- Logo, não é necessário criar regras explícitas para INSERT/UPDATE/DELETE.
