<script setup lang="ts">
// ========================================================================================
// ImobiLit - Página de Detalhes do Imóvel (Vertical 01 - Vitrine Avançada, Etapa 2)
// Blocos: Selo de Governança (LIT), Cofre de Transparência e Termômetro de Mercado.
// Rota pública: o RLS do Supabase só devolve imóveis 'approved' (ou do próprio dono).
// ========================================================================================
import {
  ArrowLeft,
  MapPin,
  Maximize2,
  BedDouble,
  Bath,
  Car,
  Building2,
  SearchX,
  CheckCircle2
} from 'lucide-vue-next'
import type { Property, PropertyStatus, PropertyType } from '~/types'
import { SHOWCASE_DEMO_PROPERTIES } from '~/fixtures/showcaseProperties'

const route = useRoute()
const supabase = useSupabaseClient()

const propertyId = computed(() => String(route.params.id || ''))

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

// Colunas explícitas: evita trafegar campos geoespaciais (location / perimeter_polygon) em WKB.
const PROPERTY_COLUMNS = [
  'id',
  'address',
  'street',
  'neighborhood',
  'city',
  'state',
  'zipcode',
  'price',
  'condo_fee',
  'tax_fee',
  'area_sqm',
  'listing_date',
  'status',
  'property_type',
  'bedrooms',
  'bathrooms',
  'parking',
  'images',
  'features',
  'condominium_name',
  'approval_status',
  'lit_certified',
  'public_documents',
  'show_market_price',
  'regional_avg_price'
].join(', ')

const { data: property, status: fetchStatus } = await useAsyncData(
  () => `property-${propertyId.value}`,
  async (): Promise<Property | null> => {
    const id = propertyId.value

    if (import.meta.dev && SHOWCASE_DEMO_PROPERTIES[id]) {
      return SHOWCASE_DEMO_PROPERTIES[id]
    }

    if (!UUID_REGEX.test(id)) return null

    const { data, error } = await supabase
      .from('properties')
      .select(PROPERTY_COLUMNS)
      .eq('id', id)
      .maybeSingle<Property>()

    if (error) {
      console.error('[imoveis/:id] Falha ao carregar imóvel:', error.message)
      return null
    }
    return data
  },
  { watch: [propertyId] }
)

// ---- Derivações dos blocos avançados ----------------------------------------------------
const publicDocuments = computed(() => sanitizePublicDocuments(property.value?.public_documents))
const marketThermometer = computed(() =>
  property.value ? computeMarketThermometer(property.value) : null
)

// ---- Apresentação ----------------------------------------------------------------------
const STATUS_LABELS: Record<PropertyStatus, string> = {
  for_sale: 'À venda',
  sold: 'Vendido',
  precon: 'Lançamento',
  rental: 'Aluguel'
}

const TYPE_LABELS: Record<PropertyType, string> = {
  condo: 'Condomínio',
  townhouse: 'Sobrado',
  detached: 'Casa Térrea',
  apartment: 'Apartamento',
  house: 'Casa'
}

const title = computed(
  () => property.value?.condominium_name || property.value?.address || 'Imóvel'
)

const formattedPrice = computed(() => {
  if (!property.value) return ''
  const value = formatBRL(Number(property.value.price))
  return property.value.status === 'rental' ? `${value}/mês` : value
})

const coverImage = computed(() => {
  const first = property.value?.images?.find((src) => /^https?:\/\//i.test(src))
  return first || ''
})

const specs = computed(() => {
  const p = property.value
  if (!p) return []
  return [
    { icon: Maximize2, label: 'Área', value: `${p.area_sqm} m²` },
    { icon: BedDouble, label: 'Quartos', value: String(p.bedrooms) },
    { icon: Bath, label: 'Banheiros', value: String(p.bathrooms) },
    { icon: Car, label: 'Vagas', value: String(p.parking) }
  ]
})

useSeoMeta({
  title: () => `${title.value} • ImobiLit`,
  description: () =>
    property.value
      ? `${TYPE_LABELS[property.value.property_type] ?? 'Imóvel'} em ${property.value.neighborhood ?? property.value.city} - ${formattedPrice.value}`
      : 'Imóvel não encontrado na vitrine ImobiLit.'
})
</script>

<template>
  <div class="min-h-screen bg-[#07161F] text-slate-100 relative overflow-hidden">
    <!-- Brilhos de fundo (glassmorphism) -->
    <div class="pointer-events-none absolute -top-40 -left-40 w-[28rem] h-[28rem] rounded-full bg-[#00384A]/40 blur-3xl" />
    <div class="pointer-events-none absolute top-1/3 -right-40 w-[26rem] h-[26rem] rounded-full bg-[#D96826]/10 blur-3xl" />

    <main class="relative z-10 max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-6">
      <NuxtLink
        to="/"
        class="inline-flex items-center gap-2 text-xs font-semibold text-slate-400 hover:text-[#F28C28] transition"
      >
        <ArrowLeft class="w-4 h-4" />
        <span>Voltar para a Vitrine</span>
      </NuxtLink>

      <!-- Carregando -->
      <div v-if="fetchStatus === 'pending'" class="space-y-6 animate-pulse">
        <div class="h-72 rounded-2xl bg-white/[0.05] border border-white/10" />
        <div class="grid lg:grid-cols-3 gap-6">
          <div class="lg:col-span-2 h-56 rounded-2xl bg-white/[0.05] border border-white/10" />
          <div class="h-56 rounded-2xl bg-white/[0.05] border border-white/10" />
        </div>
      </div>

      <!-- Não encontrado -->
      <section
        v-else-if="!property"
        class="rounded-2xl bg-white/[0.04] backdrop-blur-md border border-white/10 p-12 text-center space-y-3"
      >
        <SearchX class="w-10 h-10 text-[#F28C28] mx-auto" />
        <h1 class="text-lg font-bold text-white">Imóvel não encontrado</h1>
        <p class="text-sm text-slate-400 max-w-md mx-auto">
          Este anúncio não existe, foi removido ou ainda está em revisão pela curadoria LIT Capital.
        </p>
      </section>

      <template v-else>
        <!-- 1. Cabeçalho do imóvel + Selo de Governança -->
        <section
          class="rounded-2xl overflow-hidden bg-white/[0.04] backdrop-blur-md border border-white/10 shadow-2xl"
        >
          <div class="relative h-64 sm:h-80 bg-gradient-to-br from-[#00384A] via-[#002936] to-[#0D2230]">
            <img
              v-if="coverImage"
              :src="coverImage"
              :alt="title"
              class="absolute inset-0 w-full h-full object-cover"
            />
            <div v-else class="absolute inset-0 flex items-center justify-center">
              <Building2 class="w-16 h-16 text-white/10" />
            </div>
            <div class="absolute inset-0 bg-gradient-to-t from-[#07161F] via-[#07161F]/40 to-transparent" />

            <div class="absolute top-4 left-4 right-4 flex flex-wrap items-start justify-between gap-3">
              <span
                class="px-3 py-1 rounded-lg bg-[#002936]/80 backdrop-blur-md border border-white/15 text-xs font-bold text-white"
              >
                {{ STATUS_LABELS[property.status] ?? property.status }}
              </span>

              <LitTrustBadge v-if="property.lit_certified === true" />
            </div>
          </div>

          <div class="p-5 sm:p-7 -mt-16 relative space-y-3">
            <p class="text-xs font-semibold uppercase tracking-wider text-[#F28C28]">
              {{ TYPE_LABELS[property.property_type] ?? property.property_type }}
            </p>
            <div class="flex flex-col md:flex-row md:items-end md:justify-between gap-4">
              <div class="min-w-0">
                <h1 class="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
                  {{ title }}
                </h1>
                <p class="mt-1.5 flex items-center gap-1.5 text-sm text-slate-300">
                  <MapPin class="w-4 h-4 text-[#F28C28] shrink-0" />
                  <span class="truncate">
                    {{ [property.neighborhood, property.city, property.state].filter(Boolean).join(', ') }}
                  </span>
                </p>
              </div>
              <div class="md:text-right shrink-0">
                <p class="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
                  {{ formattedPrice }}
                </p>
                <p v-if="property.condo_fee || property.tax_fee" class="text-xs text-slate-400 mt-1">
                  <span v-if="property.condo_fee">Condomínio {{ formatBRL(Number(property.condo_fee)) }}</span>
                  <span v-if="property.condo_fee && property.tax_fee"> • </span>
                  <span v-if="property.tax_fee">IPTU {{ formatBRL(Number(property.tax_fee)) }}</span>
                </p>
              </div>
            </div>
          </div>
        </section>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
          <!-- Coluna principal -->
          <div class="lg:col-span-2 space-y-6">
            <!-- Características -->
            <section class="rounded-2xl bg-white/[0.04] backdrop-blur-md border border-white/10 p-5 sm:p-6 shadow-xl space-y-5">
              <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
                <div
                  v-for="spec in specs"
                  :key="spec.label"
                  class="rounded-xl bg-[#0D2230]/70 border border-white/10 p-3.5 flex items-center gap-3"
                >
                  <component :is="spec.icon" class="w-5 h-5 text-[#F28C28] shrink-0" />
                  <div>
                    <p class="text-sm font-bold text-white">{{ spec.value }}</p>
                    <p class="text-[10px] uppercase tracking-wider text-slate-400">{{ spec.label }}</p>
                  </div>
                </div>
              </div>

              <ul v-if="property.features?.length" class="flex flex-wrap gap-2">
                <li
                  v-for="feature in property.features"
                  :key="feature"
                  class="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg bg-white/[0.05] border border-white/10 text-xs font-medium text-slate-200"
                >
                  <CheckCircle2 class="w-3.5 h-3.5 text-[#F28C28]" />
                  {{ feature }}
                </li>
              </ul>
            </section>

            <!-- 3. Termômetro de Mercado (show_market_price && regional_avg_price) -->
            <MarketThermometer v-if="marketThermometer" :data="marketThermometer" />
          </div>

          <!-- Coluna lateral -->
          <aside class="space-y-6 lg:sticky lg:top-6">
            <!-- 2. Cofre de Transparência (oculto se public_documents estiver vazio) -->
            <TransparencyVault :documents="publicDocuments" />

            <div class="rounded-2xl bg-gradient-to-br from-[#00384A] to-[#0D2230] border border-[#F28C28]/30 p-5 sm:p-6 shadow-xl space-y-3">
              <h2 class="text-sm font-bold text-white">Interessado neste ativo?</h2>
              <p class="text-xs text-slate-300">
                Acesse a plataforma para falar com o anunciante e acompanhar a due diligence.
              </p>
              <NuxtLink
                to="/login"
                class="block w-full text-center py-3 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] hover:from-[#c35a1d] hover:to-[#e07b1d] text-white text-sm font-bold shadow-lg shadow-[#D96826]/25 transition"
              >
                Falar com o anunciante
              </NuxtLink>
            </div>
          </aside>
        </div>
      </template>
    </main>
  </div>
</template>
