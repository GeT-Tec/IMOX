-- ========================================================================================
-- IMOX - Catálogo do Schema Remoto de Referência (Supabase Cloud - kbnyesbkmablickwcwfw)
-- Extraído via SQL Editor em 2026-10-05
-- ========================================================================================

-- TABELAS E COLUNAS:
-- brokers (id uuid PK default uuid_generate_v4(), source_broker_id varchar UNIQUE, nome varchar NOT NULL, creci varchar NOT NULL, foto_url text, tempo_de_casa varchar, imoveis_cadastrados integer DEFAULT 0, negocios_fechados integer DEFAULT 0, valor_geral_vendas numeric DEFAULT 0.00, microsite_url text, created_at timestamptz DEFAULT now(), updated_at timestamptz DEFAULT now())
-- market_stats (id uuid PK default uuid_generate_v4(), region_id varchar NOT NULL, city varchar NOT NULL, neighborhood varchar, period date NOT NULL, avg_price numeric NOT NULL, avg_price_sqm numeric NOT NULL, inventory integer NOT NULL, absorption_rate numeric NOT NULL, trend varchar NOT NULL, created_at timestamptz DEFAULT now(), UNIQUE(region_id, period))
-- price_history (id uuid PK default uuid_generate_v4(), property_id uuid NOT NULL REFERENCES properties(id), date date NOT NULL, price numeric NOT NULL, event history_event_enum NOT NULL, created_at timestamptz DEFAULT now())
-- properties (id uuid PK default uuid_generate_v4(), source_id varchar UNIQUE NOT NULL, broker_id uuid REFERENCES brokers(id), address text NOT NULL, street varchar, neighborhood varchar, city varchar NOT NULL, state varchar NOT NULL, zipcode varchar, location geography(Point, 4326) NULL, price numeric NOT NULL, condo_fee numeric, tax_fee numeric, area_sqm numeric NOT NULL, listing_date date NOT NULL, status property_status_enum NOT NULL DEFAULT 'for_sale', property_type property_type_enum NOT NULL, bedrooms integer NOT NULL DEFAULT 0, bathrooms integer NOT NULL DEFAULT 0, parking integer NOT NULL DEFAULT 0, images text[] NOT NULL DEFAULT '{}', features text[] NOT NULL DEFAULT '{}', source_url text NOT NULL, view_count integer DEFAULT 0, condominium_name varchar, created_at timestamptz DEFAULT now(), updated_at timestamptz DEFAULT now())

-- ÍNDICES:
-- brokers_pkey ON brokers(id)
-- brokers_source_broker_id_key ON brokers(source_broker_id)
-- market_stats_pkey ON market_stats(id)
-- uq_region_period ON market_stats(region_id, period)
-- price_history_pkey ON price_history(id)
-- idx_price_history_property ON price_history(property_id, date DESC)
-- properties_pkey ON properties(id)
-- properties_source_id_key ON properties(source_id)
-- idx_properties_location ON properties USING gist (location)
-- idx_properties_search ON properties USING btree (city, status, property_type, price)

-- POLICIES (RLS):
-- "public_read_brokers" ON brokers FOR SELECT TO anon USING (true);
-- "public_read_market_stats" ON market_stats FOR SELECT TO anon USING (true);
-- "public_read_price_history" ON price_history FOR SELECT TO anon USING (true);
-- "public_read_properties" ON properties FOR SELECT TO anon USING (true);
