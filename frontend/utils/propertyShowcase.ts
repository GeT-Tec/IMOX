// ========================================================================================
// ImobiLit (LIT Capital) - Regras puras da Vitrine Avançada (Vertical 01 - Etapa 2)
// Arquivo: frontend/utils/propertyShowcase.ts (auto-importado pelo Nuxt)
// ========================================================================================
import type { MarketThermometerData, Property, PublicDocumentItem } from '~/types'

/** Faixa (em %) em torno da média regional considerada "Alinhado". */
export const MARKET_ALIGNED_TOLERANCE_PCT = 5

/** Amplitude visual da barra do termômetro (de -30% a +30% em relação à média). */
export const MARKET_BAR_RANGE_PCT = 30

const DOCUMENT_CATEGORIES: PublicDocumentItem['category'][] = [
  'matricula',
  'certidao',
  'car',
  'iptu',
  'outros'
]

/** Aceita somente URLs http(s), bloqueando esquemas como javascript: e data:. */
function toSafeUrl(value: unknown): string {
  if (typeof value !== 'string' || !value.trim()) return ''
  try {
    const url = new URL(value.trim())
    return url.protocol === 'https:' || url.protocol === 'http:' ? url.toString() : ''
  } catch {
    return ''
  }
}

/**
 * Normaliza o JSONB `public_documents` vindo do banco.
 * Descarta itens sem título e higieniza URLs antes de chegarem ao template.
 */
export function sanitizePublicDocuments(raw: unknown): PublicDocumentItem[] {
  if (!Array.isArray(raw)) return []

  return raw
    .filter((item): item is Record<string, unknown> => !!item && typeof item === 'object')
    .map((item, index) => {
      const category = DOCUMENT_CATEGORIES.includes(item.category as PublicDocumentItem['category'])
        ? (item.category as PublicDocumentItem['category'])
        : 'outros'

      return {
        id: typeof item.id === 'string' && item.id ? item.id : `doc-${index}`,
        title: typeof item.title === 'string' ? item.title.trim() : '',
        category,
        documentUrl: toSafeUrl(item.documentUrl),
        verifiedAt: typeof item.verifiedAt === 'string' ? item.verifiedAt : undefined,
        issuedBy: typeof item.issuedBy === 'string' ? item.issuedBy : undefined
      }
    })
    .filter((doc) => doc.title.length > 0)
}

/**
 * Calcula o Termômetro de Mercado.
 * Retorna `null` (componente oculto) quando:
 * - o anunciante desativou `show_market_price`;
 * - não há `regional_avg_price` válido;
 * - a área é inválida;
 * - o imóvel é locação (preço mensal não é comparável ao m² de venda).
 */
export function computeMarketThermometer(
  property: Pick<Property, 'price' | 'area_sqm' | 'status' | 'show_market_price' | 'regional_avg_price'>
): MarketThermometerData | null {
  if (!property.show_market_price) return null
  if (property.status === 'rental') return null

  const regionalAvg = Number(property.regional_avg_price)
  const area = Number(property.area_sqm)
  const price = Number(property.price)

  if (!Number.isFinite(regionalAvg) || regionalAvg <= 0) return null
  if (!Number.isFinite(area) || area <= 0) return null
  if (!Number.isFinite(price) || price <= 0) return null

  const unitPriceSqm = price / area
  const percentDiff = (unitPriceSqm / regionalAvg - 1) * 100
  const absDiff = Math.abs(percentDiff).toFixed(1).replace('.', ',')

  let status: MarketThermometerData['status']
  let badgeText: string

  if (percentDiff < -MARKET_ALIGNED_TOLERANCE_PCT) {
    status = 'oportunidade'
    badgeText = `Oportunidade • ${absDiff}% abaixo da média`
  } else if (percentDiff > MARKET_ALIGNED_TOLERANCE_PCT) {
    status = 'acima'
    badgeText = `${absDiff}% acima da média regional`
  } else {
    status = 'alinhado'
    badgeText = 'Alinhado à média regional'
  }

  return {
    unitPriceSqm,
    regionalAvgPriceSqm: regionalAvg,
    percentDiff,
    status,
    badgeText
  }
}

/** Formatação monetária padrão BRL sem centavos. */
export function formatBRL(value: number): string {
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
    maximumFractionDigits: 0
  }).format(value)
}
