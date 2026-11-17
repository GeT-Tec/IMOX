<script setup lang="ts">
// Termômetro de Mercado — compara o preço do m² do imóvel com a média regional.
// Recebe o resultado de computeMarketThermometer(); o pai só o renderiza quando não é null.
import { Gauge, TrendingDown, TrendingUp, Minus } from 'lucide-vue-next'
import type { MarketThermometerData } from '~/types'

const props = defineProps<{
  data: MarketThermometerData
}>()

const range = MARKET_BAR_RANGE_PCT
const tolerance = MARKET_ALIGNED_TOLERANCE_PCT

// Posição do marcador na barra (0% = -range, 50% = média, 100% = +range)
const markerPosition = computed(() => {
  const pos = ((props.data.percentDiff + range) / (range * 2)) * 100
  return Math.min(97, Math.max(3, pos))
})

// Limites da zona "Alinhado" em % da largura da barra
const alignedStart = ((range - tolerance) / (range * 2)) * 100
const alignedWidth = ((tolerance * 2) / (range * 2)) * 100

const statusStyle = computed(() => {
  switch (props.data.status) {
    case 'oportunidade':
      return {
        icon: TrendingDown,
        badge: 'bg-emerald-500/15 border-emerald-500/40 text-emerald-300',
        marker: 'bg-emerald-400 ring-emerald-400/30'
      }
    case 'acima':
      return {
        icon: TrendingUp,
        badge: 'bg-rose-500/15 border-rose-500/40 text-rose-300',
        marker: 'bg-rose-400 ring-rose-400/30'
      }
    default:
      return {
        icon: Minus,
        badge: 'bg-[#D96826]/15 border-[#D96826]/40 text-[#F28C28]',
        marker: 'bg-[#F28C28] ring-[#F28C28]/30'
      }
  }
})
</script>

<template>
  <section
    aria-labelledby="market-thermometer-title"
    class="rounded-2xl bg-white/[0.04] backdrop-blur-md border border-white/10 p-5 sm:p-6 shadow-xl space-y-5"
  >
    <header class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
      <div class="flex items-center gap-3">
        <div
          class="w-10 h-10 rounded-xl bg-[#00384A] border border-[#F28C28]/30 flex items-center justify-center text-[#F28C28] shrink-0"
        >
          <Gauge class="w-5 h-5" />
        </div>
        <div>
          <h2 id="market-thermometer-title" class="text-sm sm:text-base font-bold text-white">
            Termômetro de Mercado
          </h2>
          <p class="text-[11px] text-slate-400">Preço do m² comparado à média da região</p>
        </div>
      </div>

      <span
        :class="[
          'inline-flex items-center gap-1.5 px-3 py-1 rounded-full border text-xs font-bold self-start sm:self-auto',
          statusStyle.badge
        ]"
      >
        <component :is="statusStyle.icon" class="w-3.5 h-3.5" />
        {{ props.data.badgeText }}
      </span>
    </header>

    <!-- Valores comparados -->
    <div class="grid grid-cols-2 gap-3">
      <div class="rounded-xl bg-[#0D2230]/70 border border-white/10 p-3.5">
        <p class="text-[10px] uppercase tracking-wider font-semibold text-slate-400">m² deste imóvel</p>
        <p class="text-lg sm:text-xl font-extrabold text-white mt-0.5">
          {{ formatBRL(props.data.unitPriceSqm) }}
        </p>
      </div>
      <div class="rounded-xl bg-[#0D2230]/70 border border-white/10 p-3.5">
        <p class="text-[10px] uppercase tracking-wider font-semibold text-slate-400">Média regional (m²)</p>
        <p class="text-lg sm:text-xl font-extrabold text-slate-200 mt-0.5">
          {{ formatBRL(props.data.regionalAvgPriceSqm) }}
        </p>
      </div>
    </div>

    <!-- Barra do termômetro -->
    <div class="space-y-2">
      <div
        class="relative h-3 rounded-full bg-gradient-to-r from-emerald-500/50 via-white/10 to-rose-500/50 border border-white/10"
        role="meter"
        :aria-valuemin="-range"
        :aria-valuemax="range"
        :aria-valuenow="Math.round(props.data.percentDiff)"
        :aria-valuetext="props.data.badgeText"
      >
        <!-- Zona "Alinhado" -->
        <div
          class="absolute inset-y-0 bg-[#F28C28]/25 border-x border-[#F28C28]/50"
          :style="{ left: `${alignedStart}%`, width: `${alignedWidth}%` }"
        />
        <!-- Marcador do imóvel -->
        <div
          :class="['absolute top-1/2 -translate-x-1/2 -translate-y-1/2 w-4 h-4 rounded-full border-2 border-[#07161F] ring-4 transition-all duration-500', statusStyle.marker]"
          :style="{ left: `${markerPosition}%` }"
        />
      </div>

      <div class="flex justify-between text-[10px] font-semibold text-slate-500">
        <span>-{{ range }}%</span>
        <span class="text-slate-400">Média</span>
        <span>+{{ range }}%</span>
      </div>
    </div>

    <p class="text-[11px] text-slate-500 leading-relaxed">
      Referência informativa calculada a partir do valor anunciado e da média do m² na região. Não constitui laudo de avaliação (NBR 14.653).
    </p>
  </section>
</template>
