<script setup lang="ts">
// Lockup oficial minimalista da marca ImobiLit: Logo oficial LIT Capital com transparência nativa + divisor + wordmark ImobiLit.
// Focado no minimalismo corporativo, perfeitamente centralizado verticalmente com os itens de navegação.
withDefaults(
  defineProps<{
    size?: 'md' | 'lg'
    showEndorse?: boolean
    endorseText?: string
    to?: string
  }>(),
  { size: 'md', showEndorse: false, endorseText: '', to: '/' }
)
</script>

<template>
  <NuxtLink
    :to="to"
    class="group inline-flex items-center gap-2.5 sm:gap-3 shrink-0 rounded-xl focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-white"
    aria-label="ImobiLit, uma plataforma LIT Capital"
  >
    <!-- Logo Oficial LIT Capital com transparência nativa -->
    <img
      src="/images/lit-capital-logo.png"
      alt="LIT Capital"
      :class="[
        'object-contain opacity-95 group-hover:opacity-100 transition-opacity',
        size === 'lg' ? 'h-7 sm:h-7.5 w-auto' : 'h-6 sm:h-6.5 w-auto'
      ]"
    />

    <!-- Divisor vertical elegante -->
    <div
      :class="[
        'w-[1px] bg-white/20 shrink-0 self-center',
        size === 'lg' ? 'h-6' : 'h-5'
      ]"
    />

    <!-- Wordmark ImobiLit Limpo & Centralizado -->
    <span
      :class="[
        'font-extrabold tracking-[-0.03em] text-white leading-none select-none',
        size === 'lg' ? 'text-2xl sm:text-[25px]' : 'text-xl sm:text-[22px]'
      ]"
    >
      Imobi<span class="text-[#F28C28]">Lit</span>
    </span>
  </NuxtLink>
</template>
