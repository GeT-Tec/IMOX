<script setup lang="ts">
import {
  MapPin,
  Maximize2,
  BedDouble,
  Bath,
  Car,
  ShieldCheck,
  FileText,
  FileCheck2,
  Sprout,
  Receipt,
  File,
  Gauge,
  TrendingDown,
  Minus,
  TrendingUp,
  Lock
} from 'lucide-vue-next'
import type { PublicDocumentItem } from '~/types'
import { sanitizePublicDocuments } from '~/utils/propertyShowcase'

export interface PropertyCardItem {
  id: string
  title: string
  type: string
  category: 'urbano' | 'agro' | 'lancamentos'
  badge: 'À venda' | 'Lançamento' | 'Agro / ESG' | 'Aluguel'
  price: number
  isRental?: boolean
  city: string
  neighborhood: string
  areaSqm: number
  areaLabel?: string
  bedrooms: number
  bathrooms: number
  parking: number
  imageUrl: string
  lit_certified?: boolean
  public_documents?: PublicDocumentItem[]
  show_market_price?: boolean
  regional_avg_price?: number | null
}

const props = defineProps<{
  property: PropertyCardItem
}>()

const formattedPrice = computed(() => {
  const formatted = new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
    maximumFractionDigits: 0
  }).format(props.property.price)

  return props.property.isRental ? `${formatted}/mês` : formatted
})

const badgeClasses = computed(() => {
  switch (props.property.badge) {
    case 'Lançamento':
      return 'bg-[#D96826] text-white'
    case 'Agro / ESG':
      return 'bg-[#00384A] text-white border border-white/15'
    case 'Aluguel':
      return 'bg-[#1D4ED8] text-white'
    case 'À venda':
    default:
      return 'bg-[#0F766E] text-white'
  }
})

// ---- 2. Cofre de Transparência ----------------------------------------------------------
const sanitizedDocs = computed(() => sanitizePublicDocuments(props.property.public_documents))

function getDocIcon(category: PublicDocumentItem['category']) {
  switch (category) {
    case 'matricula':
      return FileText
    case 'certidao':
      return FileCheck2
    case 'car':
      return Sprout
    case 'iptu':
      return Receipt
    default:
      return File
  }
}

// ---- 3. Termômetro de Mercado -----------------------------------------------------------
const thermometer = computed(() => {
  if (
    props.property.show_market_price !== true ||
    !props.property.regional_avg_price ||
    props.property.regional_avg_price <= 0 ||
    !props.property.areaSqm ||
    props.property.areaSqm <= 0 ||
    props.property.isRental ||
    props.property.badge === 'Aluguel'
  ) {
    return null
  }

  const unitPriceSqm = props.property.price / props.property.areaSqm
  const regionalAvg = props.property.regional_avg_price
  const percentDiff = ((unitPriceSqm - regionalAvg) / regionalAvg) * 100
  const absDiff = Math.abs(percentDiff).toFixed(1).replace('.', ',')

  let status: 'oportunidade' | 'alinhado' | 'acima'
  let label: string

  if (percentDiff < -5) {
    status = 'oportunidade'
    label = `Oportunidade (-${absDiff}%)`
  } else if (percentDiff > 5) {
    status = 'acima'
    label = `Acima (+${absDiff}%)`
  } else {
    status = 'alinhado'
    label = 'Alinhado à Média'
  }

  const range = 30
  const barPercent = Math.min(95, Math.max(5, ((percentDiff + range) / (range * 2)) * 100))

  return {
    unitPriceSqm,
    regionalAvg,
    percentDiff,
    status,
    label,
    barPercent
  }
})

const thermometerIcon = computed(() => {
  if (!thermometer.value) return Minus
  if (thermometer.value.status === 'oportunidade') return TrendingDown
  if (thermometer.value.status === 'acima') return TrendingUp
  return Minus
})

const thermometerBadgeClasses = computed(() => {
  if (!thermometer.value) return ''
  switch (thermometer.value.status) {
    case 'oportunidade':
      return 'bg-emerald-500/15 border-emerald-400/40 text-emerald-300'
    case 'acima':
      return 'bg-rose-500/15 border-rose-400/40 text-rose-300'
    default:
      return 'bg-[#D96826]/20 border-[#F28C28]/45 text-[#F28C28]'
  }
})

const thermometerMarkerClasses = computed(() => {
  if (!thermometer.value) return ''
  switch (thermometer.value.status) {
    case 'oportunidade':
      return 'bg-emerald-400 ring-2 ring-emerald-400/30'
    case 'acima':
      return 'bg-rose-400 ring-2 ring-rose-400/30'
    default:
      return 'bg-[#F28C28] ring-2 ring-[#F28C28]/30'
  }
})

function formatPriceSqm(value: number) {
  const hasDecimals = value < 100
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
    minimumFractionDigits: hasDecimals ? 2 : 0,
    maximumFractionDigits: hasDecimals ? 2 : 0
  }).format(value)
}
</script>

<template>
  <div
    @click="navigateTo(`/imoveis/${property.id}`)"
    class="group bg-gradient-to-b from-[#0D2230] to-[#07161F] rounded-2xl border border-white/10 shadow-xl cursor-pointer transition-all duration-200 hover:scale-[1.015] hover:border-[#F28C28]/50 hover:shadow-[0_20px_40px_-15px_rgba(0,41,54,0.75)] overflow-hidden flex flex-col justify-between"
  >
    <!-- 1. Imagem de Destaque (Topo) + Badge Superior Esquerdo + Selo de Governança -->
    <div class="relative h-52 w-full overflow-hidden bg-[#002936]">
      <img
        :src="property.imageUrl"
        :alt="property.title"
        loading="lazy"
        class="h-full w-full object-cover group-hover:scale-105 transition-transform duration-500"
      />
      <div class="absolute inset-0 bg-gradient-to-t from-[#07161F]/80 via-transparent to-[#07161F]/30 pointer-events-none" />

      <!-- Linha superior: Badge de categoria à esquerda + Selo LIT à direita -->
      <div class="absolute top-3 left-3 right-3 flex flex-wrap items-start justify-between gap-2">
        <span
          :class="[
            'px-2.5 py-1 rounded-lg text-[11px] font-bold tracking-wide shadow-sm',
            badgeClasses
          ]"
        >
          {{ property.badge }}
        </span>

        <!-- 1. Selo de Governança (Trust Badge LIT): apenas se lit_certified === true -->
        <span
          v-if="property.lit_certified === true"
          title="Ativo com lastro físico e documental auditado pela curadoria LIT Capital"
          class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-[#002936]/90 backdrop-blur-md border border-[#F28C28]/60 text-[10px] font-extrabold text-white shadow-[0_4px_16px_rgba(242,140,40,0.35)]"
        >
          <ShieldCheck class="w-3.5 h-3.5 text-[#F28C28] shrink-0" />
          <span>Lastro Checado • LIT Capital</span>
        </span>
      </div>

      <!-- Selo discreto no canto inferior direito -->
      <span
        class="absolute bottom-2.5 right-2.5 px-2.5 py-0.5 rounded bg-black/65 backdrop-blur-xs text-[11px] font-medium text-slate-200 border border-white/10"
      >
        Ativo Homologado
      </span>
    </div>

    <!-- Corpo do Card (Dark / Glassmorphism) -->
    <div class="p-5 flex-1 flex flex-col justify-between">
      <div>
        <!-- Cabeçalho do Card: Tipo à esquerda e Cidade à direita -->
        <div class="flex items-center justify-between text-xs text-slate-400 font-medium mb-1.5">
          <span>{{ property.type }}</span>
          <span>{{ property.city }}</span>
        </div>

        <!-- Preço em destaque -->
        <p class="text-2xl font-extrabold text-white tracking-tight mb-2">
          {{ formattedPrice }}
        </p>

        <!-- Título e Localização (Bairro com pino) -->
        <h3
          class="text-sm font-bold text-slate-100 group-hover:text-[#F28C28] transition-colors line-clamp-1"
        >
          {{ property.title }}
        </h3>

        <div class="flex items-center gap-1 text-xs text-slate-400 mt-1">
          <MapPin class="w-3.5 h-3.5 text-[#F28C28] shrink-0" />
          <span class="truncate">{{ property.neighborhood }}</span>
        </div>

        <!-- 3. Termômetro de Mercado (somente se show_market_price === true e regional_avg_price existir) -->
        <div
          v-if="thermometer"
          class="mt-3.5 rounded-xl bg-white/[0.04] backdrop-blur-md border border-white/10 p-3 space-y-2"
        >
          <div class="flex items-center justify-between gap-2">
            <span class="inline-flex items-center gap-1 text-[10px] font-bold uppercase tracking-wider text-slate-300">
              <Gauge class="w-3.5 h-3.5 text-[#F28C28]" />
              Mercado
            </span>
            <span
              :class="[
                'inline-flex items-center gap-1 px-2 py-0.5 rounded-full border text-[10px] font-bold',
                thermometerBadgeClasses
              ]"
            >
              <component :is="thermometerIcon" class="w-3 h-3" />
              {{ thermometer.label }}
            </span>
          </div>

          <div
            class="relative h-2 rounded-full bg-gradient-to-r from-emerald-500/40 via-white/15 to-rose-500/40 border border-white/10"
            role="meter"
            :aria-valuenow="Math.round(thermometer.percentDiff)"
            aria-valuemin="-30"
            aria-valuemax="30"
            :aria-valuetext="thermometer.label"
          >
            <div class="absolute inset-y-0 left-[41.6%] w-[16.8%] bg-[#F28C28]/25 border-x border-[#F28C28]/50" />
            <div
              :class="['absolute top-1/2 -translate-x-1/2 -translate-y-1/2 w-3 h-3 rounded-full border-2 border-[#07161F] shadow', thermometerMarkerClasses]"
              :style="{ left: `${thermometer.barPercent}%` }"
            />
          </div>

          <div class="flex items-center justify-between text-[10px] text-slate-400 font-medium">
            <span>Imóvel: <strong class="text-white">{{ formatPriceSqm(thermometer.unitPriceSqm) }}/m²</strong></span>
            <span>Média: <strong class="text-slate-200">{{ formatPriceSqm(thermometer.regionalAvg) }}/m²</strong></span>
          </div>
        </div>

        <!-- 2. Cofre de Transparência (oculto se public_documents estiver vazio) -->
        <div
          v-if="sanitizedDocs.length > 0"
          class="mt-3 rounded-xl bg-white/[0.04] backdrop-blur-md border border-white/10 p-3 space-y-2"
        >
          <div class="flex items-center justify-between gap-2">
            <span class="inline-flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-wider text-slate-300">
              <Lock class="w-3.5 h-3.5 text-[#F28C28]" />
              Cofre de Transparência
            </span>
            <span class="text-[10px] font-bold px-1.5 py-0.5 rounded-full bg-[#D96826]/20 text-[#F28C28] border border-[#D96826]/30">
              {{ sanitizedDocs.length }}
            </span>
          </div>

          <ul class="space-y-1.5">
            <li v-for="doc in sanitizedDocs" :key="doc.id">
              <a
                v-if="doc.documentUrl"
                :href="doc.documentUrl"
                target="_blank"
                rel="noopener noreferrer"
                @click.stop
                class="flex items-center gap-2 p-2 rounded-lg bg-[#002936]/75 border border-white/10 hover:border-[#F28C28]/50 transition group/doc"
              >
                <component :is="getDocIcon(doc.category)" class="w-3.5 h-3.5 text-[#F28C28] shrink-0" />
                <div class="min-w-0 flex-1">
                  <p class="text-[11px] font-semibold text-white truncate group-hover/doc:text-[#F28C28] transition-colors">
                    {{ doc.title }}
                  </p>
                  <p v-if="doc.issuedBy" class="text-[10px] text-slate-400 truncate">
                    {{ doc.issuedBy }}
                  </p>
                </div>
              </a>
              <div
                v-else
                class="flex items-center gap-2 p-2 rounded-lg bg-[#002936]/75 border border-white/10"
              >
                <component :is="getDocIcon(doc.category)" class="w-3.5 h-3.5 text-[#F28C28] shrink-0" />
                <div class="min-w-0 flex-1">
                  <p class="text-[11px] font-semibold text-white truncate">
                    {{ doc.title }}
                  </p>
                  <p v-if="doc.issuedBy" class="text-[10px] text-slate-400 truncate">
                    {{ doc.issuedBy }}
                  </p>
                </div>
              </div>
            </li>
          </ul>
        </div>
      </div>

      <!-- Rodapé (Características: m², qts, banh, vg) -->
      <div
        class="mt-4 pt-3.5 border-t border-white/10 flex items-center justify-between text-xs text-slate-300 font-medium"
      >
        <span class="inline-flex items-center gap-1" title="Área útil / total">
          <Maximize2 class="w-3.5 h-3.5 text-[#F28C28]/80" />
          {{ property.areaLabel || `${property.areaSqm} m²` }}
        </span>

        <span class="inline-flex items-center gap-1" title="Quartos">
          <BedDouble class="w-3.5 h-3.5 text-slate-400" />
          {{ property.bedrooms }} qts
        </span>

        <span class="inline-flex items-center gap-1" title="Banheiros">
          <Bath class="w-3.5 h-3.5 text-slate-400" />
          {{ property.bathrooms }} banh
        </span>

        <span class="inline-flex items-center gap-1" title="Vagas">
          <Car class="w-3.5 h-3.5 text-slate-400" />
          {{ property.parking }} vg
        </span>
      </div>
    </div>
  </div>
</template>
