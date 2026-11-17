<script setup lang="ts">
// Selo de Governança (Trust Badge LIT) — "Lastro Checado".
// O componente pai é responsável por renderizá-lo apenas quando property.lit_certified === true.
import { ShieldCheck } from 'lucide-vue-next'

withDefaults(
  defineProps<{
    size?: 'sm' | 'md'
  }>(),
  { size: 'md' }
)
</script>

<template>
  <span
    role="img"
    aria-label="Lastro Checado pela LIT Capital"
    title="Ativo com lastro físico e documental auditado pela curadoria LIT Capital"
    :class="[
      'relative inline-flex items-center gap-2 rounded-xl border border-[#F28C28]/45 bg-gradient-to-r from-[#00384A]/90 to-[#002936]/90 backdrop-blur-md text-white shadow-[0_6px_24px_-8px_rgba(242,140,40,0.55)] select-none',
      size === 'sm' ? 'px-2.5 py-1' : 'px-3.5 py-2'
    ]"
  >
    <span
      :class="[
        'flex items-center justify-center rounded-lg bg-gradient-to-br from-[#D96826] to-[#F28C28] text-white shrink-0',
        size === 'sm' ? 'w-5 h-5' : 'w-7 h-7'
      ]"
    >
      <ShieldCheck :class="size === 'sm' ? 'w-3 h-3' : 'w-4 h-4'" />
    </span>

    <span class="flex flex-col leading-tight">
      <span :class="['font-extrabold tracking-wide', size === 'sm' ? 'text-[10px]' : 'text-xs']">
        Lastro Checado
      </span>
      <span
        v-if="size === 'md'"
        class="text-[10px] font-semibold uppercase tracking-wider text-[#F28C28]"
      >
        LIT Capital
      </span>
    </span>
  </span>
</template>
