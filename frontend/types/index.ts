// ========================================================================================
// ImobiLit (LIT Capital) - Definições de Tipagem Global do Ecossistema
// Arquivo: frontend/types/index.ts
// ========================================================================================

export type PropertyStatus = 'for_sale' | 'sold' | 'precon' | 'rental'

export type PropertyType = 'condo' | 'townhouse' | 'detached' | 'apartment' | 'house'

export type PropertyApprovalStatus = 'pending' | 'approved' | 'rejected'

export type UserRole = 'admin' | 'b2b_partner' | 'broker' | 'pf_owner' | 'customer'

/**
 * Metadados de documentos públicos e certidões homologadas (campo public_documents).
 */
export interface PublicDocumentItem {
  id: string
  title: string
  category: 'matricula' | 'certidao' | 'car' | 'iptu' | 'outros'
  documentUrl: string
  verifiedAt?: string
  issuedBy?: string
}

/**
 * Entidade central de Imóveis (properties) refletindo o schema do Supabase.
 */
export interface Property {
  id: string
  source_id?: string | null
  broker_id?: string | null
  owner_id?: string | null
  development_id?: string | null
  unit_identifier?: string | null
  address: string
  street?: string | null
  neighborhood?: string | null
  city: string
  state: string
  zipcode?: string | null
  price: number
  condo_fee?: number | null
  tax_fee?: number | null
  area_sqm: number
  listing_date: string
  status: PropertyStatus
  property_type: PropertyType
  bedrooms: number
  bathrooms: number
  parking: number
  images: string[]
  features: string[]
  source_url?: string
  view_count?: number
  condominium_name?: string | null

  // Atributos Agro / Rural
  numero_car?: string | null
  area_total_ha?: number | null
  area_reserva_ha?: number | null
  recursos_hidricos?: string[]

  // Atributos de Cartório / Compliance
  matricula?: string | null
  rgi?: string | null
  status_juridico?: string
  approval_status: PropertyApprovalStatus

  // ========================================================================================
  // USABILIDADE AVANÇADA DA VITRINE (Vertical 01 - Etapa 1)
  // ========================================================================================
  /** Selo de Lastro Checado: indica auditoria e homologação física/documental pela LIT Capital */
  lit_certified: boolean

  /** Coleção de links e metadados de documentos validados exibíveis publicamente na vitrine */
  public_documents: PublicDocumentItem[]

  /** Controle do anunciante/plataforma para exibir ou ocultar o termômetro de mercado */
  show_market_price: boolean

  /** Preço médio do m² na microrregião/bairro para calibração do termômetro de mercado */
  regional_avg_price?: number | null

  created_at?: string | null
  updated_at?: string | null
}

/**
 * Modelo de cálculo do Termômetro de Mercado da Vitrine.
 */
export interface MarketThermometerData {
  unitPriceSqm: number
  regionalAvgPriceSqm: number
  percentDiff: number
  status: 'oportunidade' | 'alinhado' | 'acima'
  badgeText: string
}
