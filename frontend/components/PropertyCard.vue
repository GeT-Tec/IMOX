<script setup lang="ts">
import { MapPin, Maximize2, BedDouble, Bath, Car } from 'lucide-vue-next'

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
      return 'bg-[#002936] text-white'
    case 'Aluguel':
      return 'bg-[#1D4ED8] text-white'
    case 'À venda':
    default:
      return 'bg-[#0F766E] text-white'
  }
})
</script>

<template>
  <div
    @click="navigateTo('/login')"
    class="group bg-white rounded-2xl border border-slate-200/90 shadow-sm cursor-pointer transition-transform duration-200 hover:scale-[1.02] hover:shadow-xl overflow-hidden flex flex-col justify-between"
  >
    <!-- 1. Imagem de Destaque (Topo) + Badge Superior Esquerdo -->
    <div class="relative h-52 w-full overflow-hidden bg-slate-100">
      <img
        :src="property.imageUrl"
        :alt="property.title"
        loading="lazy"
        class="h-full w-full object-cover group-hover:scale-105 transition-transform duration-500"
      />

      <!-- Badge / Tag no canto superior esquerdo -->
      <span
        :class="[
          'absolute top-3.5 left-3.5 px-3 py-1 rounded-lg text-xs font-bold tracking-wide shadow-sm',
          badgeClasses
        ]"
      >
        {{ property.badge }}
      </span>

      <!-- Selo discreto no canto inferior direito -->
      <span
        class="absolute bottom-2.5 right-2.5 px-2.5 py-0.5 rounded bg-black/65 backdrop-blur-xs text-[11px] font-medium text-white"
      >
        Ativo Homologado
      </span>
    </div>

    <!-- Corpo do Card -->
    <div class="p-5 flex-1 flex flex-col justify-between">
      <div>
        <!-- 2. Cabeçalho do Card: Tipo à esquerda e Cidade à direita -->
        <div class="flex items-center justify-between text-xs text-slate-500 font-medium mb-1.5">
          <span>{{ property.type }}</span>
          <span>{{ property.city }}</span>
        </div>

        <!-- 3. Preço em destaque -->
        <p class="text-2xl font-extrabold text-[#002936] tracking-tight mb-2">
          {{ formattedPrice }}
        </p>

        <!-- 4. Título e Localização (Bairro com pino) -->
        <h3
          class="text-sm font-bold text-slate-900 group-hover:text-[#D96826] transition-colors line-clamp-1"
        >
          {{ property.title }}
        </h3>

        <div class="flex items-center gap-1 text-xs text-slate-500 mt-1">
          <MapPin class="w-3.5 h-3.5 text-[#D96826] shrink-0" />
          <span class="truncate">{{ property.neighborhood }}</span>
        </div>
      </div>

      <!-- 5. Rodapé (Características: m², qts, banh, vg) -->
      <div
        class="mt-4 pt-3.5 border-t border-slate-100 flex items-center justify-between text-xs text-slate-600 font-medium"
      >
        <span class="inline-flex items-center gap-1" title="Área útil / total">
          <Maximize2 class="w-3.5 h-3.5 text-slate-400" />
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
