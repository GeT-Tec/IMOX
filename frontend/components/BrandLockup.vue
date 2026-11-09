<script setup lang="ts">
// Lockup oficial da marca ImobiLit: Logo oficial LIT Capital com transparência nativa + divisor + wordmark ImobiLit.
// Flutua de forma elegante sobre o fundo corporativo (#002936) sem caixote branco ou padding excessivo.
withDefaults(
  defineProps<{
    size?: 'md' | 'lg'
    showEndorse?: boolean
    endorseText?: string
    to?: string
  }>(),
  { size: 'md', showEndorse: true, endorseText: 'Marketplace & Ativos', to: '/' }
)
</script>

<template>
  <NuxtLink
    :to="to"
    class="group inline-flex items-center gap-3 shrink-0 rounded-xl focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-white"
    aria-label="ImobiLit, uma plataforma LIT Capital"
  >
    <!-- Logo Oficial LIT Capital com transparência nativa -->
    <img
      src="/images/lit-capital-logo.png"
      alt="LIT Capital"
      :class="[
        'object-contain opacity-95 group-hover:opacity-100 transition-opacity',
        size === 'lg' ? 'h-7 sm:h-8 w-auto' : 'h-6 sm:h-6.5 w-auto'
      ]"
    />

    <!-- Divisor vertical elegante -->
    <div
      :class="[
        'w-[1px] bg-white/20 shrink-0',
        size === 'lg' ? 'h-7' : 'h-5.5'
      ]"
    />

    <!-- Wordmark ImobiLit + Subtítulo -->
    <span class="flex flex-col leading-none">
      <span
        :class="[
          'font-extrabold tracking-[-0.035em] text-white',
          size === 'lg' ? 'text-[22px]' : 'text-xl'
        ]"
      >
        Imobi<span class="text-[#F28C28]">Lit</span>
      </span>
      <span
        v-if="showEndorse"
        class="mt-1 text-[10px] sm:text-[11px] font-semibold uppercase tracking-[0.14em] text-slate-300/70"
      >
        {{ endorseText }}
      </span>
    </span>
  </NuxtLink>
</template>
