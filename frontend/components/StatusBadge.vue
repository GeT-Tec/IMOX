<script setup lang="ts">
import { computed } from 'vue'

export type StatusVariant =
  | 'approved'
  | 'homologado'
  | 'concluido'
  | 'active'
  | 'pending'
  | 'pendente'
  | 'analise'
  | 'rejected'
  | 'rejeitado'
  | 'corporate'
  | 'lit'
  | 'neutral'

const props = withDefaults(
  defineProps<{
    status: StatusVariant | string
    label?: string
    size?: 'sm' | 'md'
    pulse?: boolean
  }>(),
  {
    size: 'sm',
    pulse: false
  }
)

const normalizedVariant = computed<StatusVariant>(() => {
  const s = props.status?.toLowerCase() || 'neutral'
  if (['approved', 'homologado', 'concluido', 'active', 'ativo'].includes(s)) return 'approved'
  if (['pending', 'pendente', 'analise', 'em análise', 'em analise'].includes(s)) return 'pending'
  if (['rejected', 'rejeitado', 'inativo'].includes(s)) return 'rejected'
  if (['corporate', 'lit', 'admin', 'b2b'].includes(s)) return 'corporate'
  return 'neutral'
})

const badgeClasses = computed(() => {
  const base =
    'inline-flex items-center gap-1.5 font-bold uppercase tracking-wider transition-all select-none'

  const sizeClasses =
    props.size === 'md'
      ? 'px-3 py-1 text-xs rounded-full'
      : 'px-2.5 py-0.5 text-[10px] sm:text-[11px] rounded-full'

  const variantMap: Record<StatusVariant, string> = {
    approved: 'bg-emerald-500/15 text-emerald-300 border border-emerald-500/30',
    homologado: 'bg-emerald-500/15 text-emerald-300 border border-emerald-500/30',
    concluido: 'bg-emerald-500/15 text-emerald-300 border border-emerald-500/30',
    active: 'bg-emerald-500/15 text-emerald-300 border border-emerald-500/30',
    pending: 'bg-amber-500/15 text-amber-300 border border-amber-500/30',
    pendente: 'bg-amber-500/15 text-amber-300 border border-amber-500/30',
    analise: 'bg-amber-500/15 text-amber-300 border border-amber-500/30',
    rejected: 'bg-red-500/15 text-red-300 border border-red-500/30',
    rejeitado: 'bg-red-500/15 text-red-300 border border-red-500/30',
    corporate: 'bg-[#D96826]/15 text-[#F28C28] border border-[#D96826]/30',
    lit: 'bg-[#D96826]/15 text-[#F28C28] border border-[#D96826]/30',
    neutral: 'bg-white/5 text-slate-300 border border-white/10'
  }

  return [base, sizeClasses, variantMap[normalizedVariant.value]]
})

const dotClasses = computed(() => {
  const variantDotMap: Record<StatusVariant, string> = {
    approved: 'bg-emerald-400',
    homologado: 'bg-emerald-400',
    concluido: 'bg-emerald-400',
    active: 'bg-emerald-400',
    pending: 'bg-amber-400',
    pendente: 'bg-amber-400',
    analise: 'bg-amber-400',
    rejected: 'bg-red-400',
    rejeitado: 'bg-red-400',
    corporate: 'bg-[#F28C28]',
    lit: 'bg-[#F28C28]',
    neutral: 'bg-slate-400'
  }
  return variantDotMap[normalizedVariant.value]
})

const displayLabel = computed(() => {
  if (props.label) return props.label
  const defaultLabels: Record<StatusVariant, string> = {
    approved: 'Homologado',
    homologado: 'Homologado',
    concluido: 'Concluído',
    active: 'Ativo',
    pending: 'Pendente de Revisão',
    pendente: 'Pendente',
    analise: 'Em Análise',
    rejected: 'Rejeitado',
    rejeitado: 'Rejeitado',
    corporate: 'LIT Capital',
    lit: 'LIT Capital',
    neutral: 'Registro Geral'
  }
  return defaultLabels[normalizedVariant.value] || props.status
})
</script>

<template>
  <span :class="badgeClasses">
    <span
      v-if="pulse"
      :class="['w-1.5 h-1.5 rounded-full animate-pulse shrink-0', dotClasses]"
    />
    <span>{{ displayLabel }}</span>
  </span>
</template>
