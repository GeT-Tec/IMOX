// mock: dados fictícios, estado do ES. Substituir por Supabase na integração.
import type { Broker, MarketStat, PriceHistory, Property } from "./schema";

const properties: Property[] = [
  {
    id: "imovel-01",
    source_id: "mock-src-01",
    broker_id: "corretor-01",
    address: "Rua Exemplo Alfa, 100 - Praia do Canto, Vitória - ES",
    street: "Rua Exemplo Alfa",
    neighborhood: "Praia do Canto",
    city: "Vitória",
    state: "ES",
    zipcode: "29000-000", // mock: CEP fictício
    price: 1250000, // mock: preço fictício
    condo_fee: 1100,
    tax_fee: 650,
    area_sqm: 120,
    listing_date: "2025-03-10",
    status: "for_sale",
    property_type: "apartment",
    bedrooms: 3,
    bathrooms: 3,
    parking: 2,
    images: [],
    features: ["varanda", "piscina"],
    source_url: "https://exemplo.invalid/imovel-01",
    view_count: 120,
    condominium_name: "Edifício Exemplo Praia do Canto",
    created_at: null,
    updated_at: null,
    lat: -20.2956, // mock: coordenada aproximada, validar no mapa.
    lng: -40.2862, // mock: coordenada aproximada, validar no mapa.
  },
  {
    id: "imovel-02",
    source_id: "mock-src-02",
    broker_id: "corretor-01",
    address: "Rua Exemplo Beta, 250 - Jardim da Penha, Vitória - ES",
    street: "Rua Exemplo Beta",
    neighborhood: "Jardim da Penha",
    city: "Vitória",
    state: "ES",
    zipcode: "29000-000", // mock: CEP fictício
    price: 890000, // mock: preço fictício
    condo_fee: 850,
    tax_fee: 480,
    area_sqm: 90,
    listing_date: "2025-01-22",
    status: "for_sale",
    property_type: "condo",
    bedrooms: 3,
    bathrooms: 2,
    parking: 2,
    images: [],
    features: ["academia"],
    source_url: "https://exemplo.invalid/imovel-02",
    view_count: 85,
    condominium_name: "Condomínio Exemplo Jardim da Penha",
    created_at: null,
    updated_at: null,
    lat: -20.2873, // mock: coordenada aproximada, validar no mapa.
    lng: -40.2921, // mock: coordenada aproximada, validar no mapa.
  },
  {
    id: "imovel-03",
    source_id: "mock-src-03",
    broker_id: "corretor-02",
    address: "Rua Exemplo Gama, 78 - Praia da Costa, Vila Velha - ES",
    street: "Rua Exemplo Gama",
    neighborhood: "Praia da Costa",
    city: "Vila Velha",
    state: "ES",
    zipcode: "29000-000", // mock: CEP fictício
    price: 2900000, // mock: preço fictício
    condo_fee: null,
    tax_fee: 2100,
    area_sqm: 320,
    listing_date: "2024-11-05",
    status: "for_sale",
    property_type: "detached",
    bedrooms: 4,
    bathrooms: 4,
    parking: 4,
    images: [],
    features: ["jardim", "churrasqueira"],
    source_url: "https://exemplo.invalid/imovel-03",
    view_count: 210,
    condominium_name: null,
    created_at: null,
    updated_at: null,
    lat: -20.3346, // mock: coordenada aproximada, validar no mapa.
    lng: -40.2884, // mock: coordenada aproximada, validar no mapa.
  },
  {
    id: "imovel-04",
    source_id: "mock-src-04",
    broker_id: "corretor-02",
    address: "Rua Exemplo Delta, 45 - Enseada do Suá, Vitória - ES",
    street: "Rua Exemplo Delta",
    neighborhood: "Enseada do Suá",
    city: "Vitória",
    state: "ES",
    zipcode: "29000-000", // mock: CEP fictício
    price: 1480000, // mock: preço fictício
    condo_fee: 500,
    tax_fee: 900,
    area_sqm: 170,
    listing_date: "2025-02-14",
    status: "for_sale",
    property_type: "townhouse",
    bedrooms: 3,
    bathrooms: 3,
    parking: 2,
    images: [],
    features: ["terraço"],
    source_url: "https://exemplo.invalid/imovel-04",
    view_count: 64,
    condominium_name: null,
    created_at: null,
    updated_at: null,
    lat: -20.3093, // mock: coordenada aproximada, validar no mapa.
    lng: -40.2928, // mock: coordenada aproximada, validar no mapa.
  },
  {
    id: "imovel-05",
    source_id: "mock-src-05",
    broker_id: "corretor-03",
    address: "Rua Exemplo Epsilon, 310 - Praia do Canto, Vitória - ES",
    street: "Rua Exemplo Epsilon",
    neighborhood: "Praia do Canto",
    city: "Vitória",
    state: "ES",
    zipcode: "29000-000", // mock: CEP fictício
    price: 980000, // mock: preço fictício
    condo_fee: 900,
    tax_fee: 520,
    area_sqm: 75,
    listing_date: "2024-08-30",
    status: "sold",
    property_type: "apartment",
    bedrooms: 2,
    bathrooms: 2,
    parking: 1,
    images: [],
    features: [],
    source_url: "https://exemplo.invalid/imovel-05",
    view_count: 300,
    condominium_name: "Edifício Exemplo Canto",
    created_at: null,
    updated_at: null,
    lat: -20.2956, // mock: coordenada aproximada, validar no mapa.
    lng: -40.2862, // mock: coordenada aproximada, validar no mapa.
  },
  {
    id: "imovel-06",
    source_id: "mock-src-06",
    broker_id: "corretor-03",
    address: "Rua Exemplo Zeta, 12 - Jardim da Penha, Vitória - ES",
    street: "Rua Exemplo Zeta",
    neighborhood: "Jardim da Penha",
    city: "Vitória",
    state: "ES",
    zipcode: "29000-000", // mock: CEP fictício
    price: 780000, // mock: preço fictício
    condo_fee: 700,
    tax_fee: 420,
    area_sqm: 82,
    listing_date: "2025-04-01",
    status: "precon",
    property_type: "condo",
    bedrooms: 2,
    bathrooms: 2,
    parking: 1,
    images: [],
    features: ["lançamento"],
    source_url: "https://exemplo.invalid/imovel-06",
    view_count: 40,
    condominium_name: "Condomínio Exemplo Penha",
    created_at: null,
    updated_at: null,
    lat: -20.2873, // mock: coordenada aproximada, validar no mapa.
    lng: -40.2921, // mock: coordenada aproximada, validar no mapa.
  },
  {
    id: "imovel-07",
    source_id: "mock-src-07",
    broker_id: "corretor-01",
    address: "Rua Exemplo Eta, 520 - Praia da Costa, Vila Velha - ES",
    street: "Rua Exemplo Eta",
    neighborhood: "Praia da Costa",
    city: "Vila Velha",
    state: "ES",
    zipcode: "29000-000", // mock: CEP fictício
    price: 4500, // mock: valor mensal de aluguel
    condo_fee: 900,
    tax_fee: 0,
    area_sqm: 100,
    listing_date: "2025-05-12",
    status: "rental",
    property_type: "apartment",
    bedrooms: 3,
    bathrooms: 2,
    parking: 2,
    images: [],
    features: ["mobiliado"],
    source_url: "https://exemplo.invalid/imovel-07",
    view_count: 150,
    condominium_name: "Edifício Exemplo Orla",
    created_at: null,
    updated_at: null,
    lat: -20.3346, // mock: coordenada aproximada, validar no mapa.
    lng: -40.2884, // mock: coordenada aproximada, validar no mapa.
  },
  {
    id: "imovel-08",
    source_id: "mock-src-08",
    broker_id: null,
    address: "Rua Exemplo Theta, 60 - Enseada do Suá, Vitória - ES",
    street: "Rua Exemplo Theta",
    neighborhood: "Enseada do Suá",
    city: "Vitória",
    state: "ES",
    zipcode: "29000-000", // mock: CEP fictício
    price: 6800, // mock: valor mensal de aluguel
    condo_fee: null,
    tax_fee: null,
    area_sqm: 150,
    listing_date: "2025-06-03",
    status: "rental",
    property_type: "townhouse",
    bedrooms: 3,
    bathrooms: 3,
    parking: 2,
    images: [],
    features: ["quintal"],
    source_url: "https://exemplo.invalid/imovel-08",
    view_count: 55,
    condominium_name: null,
    created_at: null,
    updated_at: null,
    lat: -20.3093, // mock: coordenada aproximada, validar no mapa.
    lng: -40.2928, // mock: coordenada aproximada, validar no mapa.
  },
];

const priceHistory: PriceHistory[] = [
  { id: "hist-01", property_id: "imovel-01", date: "2025-03-10", price: 1350000, event: "listed", created_at: null },
  { id: "hist-02", property_id: "imovel-01", date: "2025-07-15", price: 1300000, event: "price_change", created_at: null },
  { id: "hist-03", property_id: "imovel-01", date: "2025-11-20", price: 1250000, event: "price_change", created_at: null },
  { id: "hist-04", property_id: "imovel-02", date: "2025-01-22", price: 950000, event: "listed", created_at: null },
  { id: "hist-05", property_id: "imovel-02", date: "2025-06-10", price: 890000, event: "price_change", created_at: null },
  { id: "hist-06", property_id: "imovel-03", date: "2024-11-05", price: 3200000, event: "listed", created_at: null },
  { id: "hist-07", property_id: "imovel-03", date: "2025-04-18", price: 2900000, event: "price_change", created_at: null },
  { id: "hist-08", property_id: "imovel-05", date: "2024-08-30", price: 1050000, event: "listed", created_at: null },
  { id: "hist-09", property_id: "imovel-05", date: "2025-02-12", price: 980000, event: "sold", created_at: null },
];

const brokers: Broker[] = [
  {
    id: "corretor-01",
    source_broker_id: "mock-broker-01",
    nome: "Corretor Exemplo 01",
    creci: "CRECI-ES-000000-F",
    foto_url: null,
    tempo_de_casa: "5 anos",
    imoveis_cadastrados: 3,
    negocios_fechados: 10,
    valor_geral_vendas: 9000000,
    microsite_url: null,
    created_at: null,
    updated_at: null,
  },
  {
    id: "corretor-02",
    source_broker_id: "mock-broker-02",
    nome: "Corretor Exemplo 02",
    creci: "CRECI-ES-000000-F",
    foto_url: null,
    tempo_de_casa: "3 anos",
    imoveis_cadastrados: 2,
    negocios_fechados: 6,
    valor_geral_vendas: 14000000,
    microsite_url: null,
    created_at: null,
    updated_at: null,
  },
  {
    id: "corretor-03",
    source_broker_id: "mock-broker-03",
    nome: "Corretor Exemplo 03",
    creci: "CRECI-ES-000000-F",
    foto_url: null,
    tempo_de_casa: "8 anos",
    imoveis_cadastrados: 2,
    negocios_fechados: 18,
    valor_geral_vendas: 21000000,
    microsite_url: null,
    created_at: null,
    updated_at: null,
  },
];

// mock: valores de trend ainda não confirmados no banco.
const marketStats: MarketStat[] = [
  {
    id: "stat-01",
    region_id: "es-vitoria-praia-do-canto",
    city: "Vitória",
    neighborhood: "Praia do Canto",
    period: "2025-06-01",
    avg_price: 1250000,
    avg_price_sqm: 10400,
    inventory: 64,
    absorption_rate: 1.5,
    trend: "alta",
  },
  {
    id: "stat-02",
    region_id: "es-vitoria-jardim-da-penha",
    city: "Vitória",
    neighborhood: "Jardim da Penha",
    period: "2025-06-01",
    avg_price: 890000,
    avg_price_sqm: 9200,
    inventory: 88,
    absorption_rate: 1.2,
    trend: "estavel",
  },
  {
    id: "stat-03",
    region_id: "es-vila-velha-praia-da-costa",
    city: "Vila Velha",
    neighborhood: "Praia da Costa",
    period: "2025-06-01",
    avg_price: 1450000,
    avg_price_sqm: 9800,
    inventory: 72,
    absorption_rate: 1.4,
    trend: "alta",
  },
  {
    id: "stat-04",
    region_id: "es-vitoria-enseada-do-sua",
    city: "Vitória",
    neighborhood: "Enseada do Suá",
    period: "2025-06-01",
    avg_price: 1100000,
    avg_price_sqm: 8900,
    inventory: 41,
    absorption_rate: 0.9,
    trend: "queda",
  },
];

export function getProperties(): Property[] {
  return properties;
}

export function getProperty(id: string): Property | undefined {
  return properties.find((p) => p.id === id);
}

export function getPriceHistory(propertyId: string): PriceHistory[] {
  return priceHistory.filter((h) => h.property_id === propertyId);
}

export function getBroker(id: string): Broker | undefined {
  return brokers.find((b) => b.id === id);
}

export function getBrokers(): Broker[] {
  return brokers;
}

export function getMarketStats(): MarketStat[] {
  return marketStats;
}
