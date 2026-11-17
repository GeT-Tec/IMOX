// ========================================================================================
// ImobiLit - Fixtures de validação visual da Vitrine Avançada (somente em desenvolvimento)
// Acessíveis em /imoveis/imobilit-01 .. imobilit-08 e /imoveis/demo-certificado, demo-alinhado, demo-basico.
// Em produção (import.meta.dev === false) a página ignora este arquivo e consulta o Supabase.
// ========================================================================================
import type { Property } from '~/types'

const base: Omit<Property, 'id' | 'lit_certified' | 'public_documents' | 'show_market_price' | 'regional_avg_price'> = {
  address: 'Rua Exemplo Alfa, 100 - Praia do Canto, Vitória - ES',
  neighborhood: 'Praia do Canto',
  city: 'Vitória',
  state: 'ES',
  price: 1250000,
  condo_fee: 1100,
  tax_fee: 650,
  area_sqm: 120,
  listing_date: '2026-10-01',
  status: 'for_sale',
  property_type: 'apartment',
  bedrooms: 3,
  bathrooms: 3,
  parking: 2,
  images: [],
  features: ['Varanda gourmet', 'Piscina', 'Academia'],
  condominium_name: 'Edifício Exemplo Praia do Canto',
  approval_status: 'approved'
}

export const SHOWCASE_DEMO_PROPERTIES: Record<string, Property> = {
  'imobilit-01': {
    ...base,
    id: 'imobilit-01',
    condominium_name: 'Casa com 3 quartos em Jardim Camburi',
    address: 'Jardim Camburi, Vitória - ES',
    neighborhood: 'Jardim Camburi',
    city: 'Vitória',
    state: 'ES',
    price: 2125000,
    condo_fee: null,
    tax_fee: 890,
    area_sqm: 260,
    status: 'for_sale',
    property_type: 'house',
    bedrooms: 3,
    bathrooms: 2,
    parking: 3,
    images: ['https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=900&q=80'],
    features: ['Piscina privativa', 'Área gourmet', 'Energia solar'],
    lit_certified: true,
    show_market_price: true,
    regional_avg_price: 9600,
    public_documents: [
      {
        id: 'doc-01-mat',
        title: 'Matrícula Atualizada (RGI)',
        category: 'matricula',
        documentUrl: 'https://example.com/imobilit-01-matricula.pdf',
        issuedBy: '2º Ofício de Registro de Imóveis de Vitória',
        verifiedAt: '2026-11-12'
      },
      {
        id: 'doc-01-onus',
        title: 'Certidão Negativa de Ônus Reais',
        category: 'certidao',
        documentUrl: 'https://example.com/imobilit-01-onus.pdf',
        issuedBy: 'ONR / SAEC'
      }
    ]
  },
  'imobilit-02': {
    ...base,
    id: 'imobilit-02',
    condominium_name: 'Casa com 5 quartos em Enseada do Suá',
    address: 'Enseada do Suá, Vitória - ES',
    neighborhood: 'Enseada do Suá',
    city: 'Vitória',
    state: 'ES',
    price: 6095000,
    condo_fee: 1850,
    tax_fee: 1450,
    area_sqm: 416,
    status: 'precon',
    property_type: 'house',
    bedrooms: 5,
    bathrooms: 3,
    parking: 3,
    images: ['https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=900&q=80'],
    features: ['Arquitetura contemporânea', 'Automação residencial', 'Vista baía'],
    lit_certified: false,
    show_market_price: true,
    regional_avg_price: 14500,
    public_documents: []
  },
  'imobilit-03': {
    ...base,
    id: 'imobilit-03',
    condominium_name: 'Casa com 4 quartos em Praia do Canto',
    address: 'Praia do Canto, Vitória - ES',
    neighborhood: 'Praia do Canto',
    city: 'Vitória',
    state: 'ES',
    price: 2350000,
    condo_fee: null,
    tax_fee: 980,
    area_sqm: 173,
    status: 'for_sale',
    property_type: 'house',
    bedrooms: 4,
    bathrooms: 4,
    parking: 2,
    images: ['https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=900&q=80'],
    features: ['Living integrado', 'Projeto luminotécnico', 'Climatização central'],
    lit_certified: true,
    show_market_price: true,
    regional_avg_price: 15800,
    public_documents: [
      {
        id: 'doc-03-mat',
        title: 'Matrícula Inteiro Teor #48.920',
        category: 'matricula',
        documentUrl: 'https://example.com/imobilit-03-matricula.pdf',
        issuedBy: '1º Ofício de Registro de Imóveis de Vitória',
        verifiedAt: '2026-11-10'
      },
      {
        id: 'doc-03-iptu',
        title: 'CND de Débitos Municipais (IPTU)',
        category: 'iptu',
        documentUrl: '',
        issuedBy: 'Prefeitura Municipal de Vitória'
      }
    ]
  },
  'imobilit-04': {
    ...base,
    id: 'imobilit-04',
    condominium_name: 'Fazenda Vale do Café — CAR Ativo & Reserva Legal',
    address: 'Pedra Azul • Zona Rural, Domingos Martins - ES',
    neighborhood: 'Pedra Azul • Zona Rural',
    city: 'Domingos Martins',
    state: 'ES',
    price: 12800000,
    condo_fee: null,
    tax_fee: 1200,
    area_sqm: 1850000,
    area_total_ha: 185,
    status: 'for_sale',
    property_type: 'detached',
    bedrooms: 6,
    bathrooms: 7,
    parking: 8,
    images: ['https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=900&q=80'],
    features: ['CAR Homologado', 'Reserva Legal averbada', 'Nascentes preservadas'],
    lit_certified: true,
    show_market_price: true,
    regional_avg_price: 9,
    public_documents: [
      {
        id: 'doc-04-car',
        title: 'Recibo CAR & Reserva Legal',
        category: 'car',
        documentUrl: 'https://example.com/imobilit-04-car.pdf',
        issuedBy: 'SICAR / IDAF-ES',
        verifiedAt: '2026-11-08'
      },
      {
        id: 'doc-04-mat',
        title: 'Certidão de Cadeia Dominial',
        category: 'certidao',
        documentUrl: 'https://example.com/imobilit-04-dominial.pdf',
        issuedBy: 'Cartório de Domingos Martins'
      }
    ]
  },
  'imobilit-05': {
    ...base,
    id: 'imobilit-05',
    condominium_name: 'Apartamento Vista Mar com 4 suítes na Orla',
    address: 'Praia da Costa, Vila Velha - ES',
    neighborhood: 'Praia da Costa',
    city: 'Vila Velha',
    state: 'ES',
    price: 4455000,
    condo_fee: 2400,
    tax_fee: 1100,
    area_sqm: 284,
    status: 'precon',
    property_type: 'apartment',
    bedrooms: 4,
    bathrooms: 5,
    parking: 4,
    images: ['https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=900&q=80'],
    features: ['Frente mar', 'Elevador privativo', 'Clube completo'],
    lit_certified: true,
    show_market_price: true,
    regional_avg_price: 18200,
    public_documents: [
      {
        id: 'doc-05-ri',
        title: 'Registro de Incorporação (RI)',
        category: 'matricula',
        documentUrl: 'https://example.com/imobilit-05-ri.pdf',
        issuedBy: '1º Cartório de Vila Velha',
        verifiedAt: '2026-11-14'
      }
    ]
  },
  'imobilit-06': {
    ...base,
    id: 'imobilit-06',
    condominium_name: 'Fazenda Rio Doce — Pecuária, Irrigação & Silos',
    address: 'Vale do Rio Doce, Linhares - ES',
    neighborhood: 'Vale do Rio Doce',
    city: 'Linhares',
    state: 'ES',
    price: 18500000,
    condo_fee: null,
    tax_fee: 1800,
    area_sqm: 3400000,
    area_total_ha: 340,
    status: 'for_sale',
    property_type: 'detached',
    bedrooms: 5,
    bathrooms: 5,
    parking: 10,
    images: ['https://images.unsplash.com/photo-1500076656116-558758c991c1?auto=format&fit=crop&w=900&q=80'],
    features: ['Pivô de irrigação', 'Silos graneleiros', 'Curral estruturado'],
    lit_certified: false,
    show_market_price: false,
    regional_avg_price: null,
    public_documents: []
  },
  'imobilit-07': {
    ...base,
    id: 'imobilit-07',
    condominium_name: 'Cobertura Linear 3 quartos no Barro Vermelho',
    address: 'Barro Vermelho, Vitória - ES',
    neighborhood: 'Barro Vermelho',
    city: 'Vitória',
    state: 'ES',
    price: 1890000,
    condo_fee: 1350,
    tax_fee: 720,
    area_sqm: 195,
    status: 'for_sale',
    property_type: 'apartment',
    bedrooms: 3,
    bathrooms: 4,
    parking: 3,
    images: ['https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=900&q=80'],
    features: ['Cobertura linear', 'Deck com piscina', 'Portaria 24h'],
    lit_certified: false,
    show_market_price: true,
    regional_avg_price: 9800,
    public_documents: []
  },
  'imobilit-08': {
    ...base,
    id: 'imobilit-08',
    condominium_name: 'Residencial Morar Jardins — Torre Horizon',
    address: 'Itaparica, Vila Velha - ES',
    neighborhood: 'Itaparica',
    city: 'Vila Velha',
    state: 'ES',
    price: 1150000,
    condo_fee: 890,
    tax_fee: 480,
    area_sqm: 112,
    status: 'precon',
    property_type: 'apartment',
    bedrooms: 3,
    bathrooms: 3,
    parking: 2,
    images: ['https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&w=900&q=80'],
    features: ['Lazer completo', 'Varanda gourmet', 'Coworking'],
    lit_certified: false,
    show_market_price: false,
    regional_avg_price: 10500,
    public_documents: []
  },
  // Selo + Cofre + Termômetro "Oportunidade" (m² ≈ R$ 10.417 vs média R$ 12.000)
  'demo-certificado': {
    ...base,
    id: 'demo-certificado',
    lit_certified: true,
    show_market_price: true,
    regional_avg_price: 12000,
    public_documents: [
      {
        id: 'doc-1',
        title: 'Matrícula Atualizada nº 00.000',
        category: 'matricula',
        documentUrl: 'https://example.com/matricula.pdf',
        issuedBy: '1º Ofício de Registro de Imóveis de Vitória',
        verifiedAt: '2026-11-10'
      },
      {
        id: 'doc-2',
        title: 'Certidão Negativa de Ônus Reais',
        category: 'certidao',
        documentUrl: 'https://example.com/onus.pdf',
        issuedBy: 'ONR / SAEC'
      },
      {
        id: 'doc-3',
        title: 'Certidão Negativa de Débitos de IPTU',
        category: 'iptu',
        documentUrl: '',
        issuedBy: 'Prefeitura Municipal de Vitória'
      }
    ]
  },
  // Sem selo, sem documentos, Termômetro "Alinhado" (m² ≈ R$ 10.417 vs média R$ 10.300)
  'demo-alinhado': {
    ...base,
    id: 'demo-alinhado',
    lit_certified: false,
    show_market_price: true,
    regional_avg_price: 10300,
    public_documents: []
  },
  // Nenhum bloco avançado: anunciante ocultou o termômetro
  'demo-basico': {
    ...base,
    id: 'demo-basico',
    lit_certified: false,
    show_market_price: false,
    regional_avg_price: 12000,
    public_documents: []
  }
}
