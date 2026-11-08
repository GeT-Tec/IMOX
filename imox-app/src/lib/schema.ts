export type PropertyStatus = 'for_sale' | 'sold' | 'precon' | 'rental';

export type PropertyType = 'condo' | 'townhouse' | 'detached' | 'apartment' | 'house';

export type HistoryEvent = 'listed' | 'price_change' | 'sold' | 'delisted';

export interface Property {
  id: string;
  source_id: string;
  broker_id: string | null;
  address: string;
  street: string | null;
  neighborhood: string | null;
  city: string;
  state: string;
  zipcode: string | null;
  price: number;
  condo_fee: number | null;
  tax_fee: number | null;
  area_sqm: number;
  listing_date: string;
  status: PropertyStatus;
  property_type: PropertyType;
  bedrooms: number;
  bathrooms: number;
  parking: number;
  images: string[];
  features: string[];
  source_url: string;
  view_count: number | null;
  condominium_name: string | null;
  created_at: string | null;
  updated_at: string | null;
  lat: number; // mock: vem da view PostGIS (ST_Y do campo location) na integração
  lng: number; // mock: vem da view PostGIS (ST_X do campo location) na integração
}

export interface Broker {
  id: string;
  source_broker_id: string | null;
  nome: string;
  creci: string;
  foto_url: string | null;
  tempo_de_casa: string | null;
  imoveis_cadastrados: number | null;
  negocios_fechados: number | null;
  valor_geral_vendas: number | null;
  microsite_url: string | null;
  created_at: string | null;
  updated_at: string | null;
}

export interface PriceHistory {
  id: string;
  property_id: string;
  date: string;
  price: number;
  event: HistoryEvent;
  created_at: string | null;
}

export interface MarketStat {
  id: string;
  region_id: string;
  city: string;
  neighborhood: string | null;
  period: string;
  avg_price: number;
  avg_price_sqm: number;
  inventory: number;
  absorption_rate: number;
  trend: string;
}
