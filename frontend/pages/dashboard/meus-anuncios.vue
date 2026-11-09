<script setup lang="ts">
import {
  Building2,
  PlusCircle,
  Clock,
  Eye,
  CheckCircle2,
  ShieldCheck,
  Home
} from 'lucide-vue-next'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})
</script>

<template>
  <div class="space-y-8">
    <!-- Cabeçalho -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h1 class="text-2xl font-bold text-white tracking-tight">Meus Anúncios</h1>
        <p class="text-xs sm:text-sm text-slate-400 mt-1">
          Gerencie seu portfólio de ativos imobiliários, esteira de curadoria e métricas de visualização.
        </p>
      </div>

      <button
        type="button"
        class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] hover:from-[#c35a1d] hover:to-[#e07b1d] text-white text-xs sm:text-sm font-bold shadow-md shadow-[#D96826]/20 transition cursor-pointer shrink-0"
      >
        <PlusCircle class="w-4 h-4" />
        <span>Cadastrar Novo Ativo</span>
      </button>
    </div>

    <!-- Mini KPIs do Usuário -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <div class="p-5 rounded-2xl bg-[#0D2230] border border-white/10 space-y-1.5 shadow-lg">
        <div class="flex items-center justify-between text-slate-400 text-xs font-semibold uppercase">
          <span>Ativos Publicados</span>
          <CheckCircle2 class="w-4 h-4 text-emerald-400" />
        </div>
        <p class="text-2xl font-extrabold text-white">0</p>
        <p class="text-[11px] text-slate-400">Visíveis na Vitrine Pública</p>
      </div>

      <div class="p-5 rounded-2xl bg-[#0D2230] border border-white/10 space-y-1.5 shadow-lg">
        <div class="flex items-center justify-between text-slate-400 text-xs font-semibold uppercase">
          <span>Em Curadoria</span>
          <Clock class="w-4 h-4 text-amber-400" />
        </div>
        <p class="text-2xl font-extrabold text-white">0</p>
        <p class="text-[11px] text-slate-400">Aguardando validação compliance</p>
      </div>

      <div class="p-5 rounded-2xl bg-[#0D2230] border border-white/10 space-y-1.5 shadow-lg">
        <div class="flex items-center justify-between text-slate-400 text-xs font-semibold uppercase">
          <span>Interesses Recebidos</span>
          <Eye class="w-4 h-4 text-[#F28C28]" />
        </div>
        <p class="text-2xl font-extrabold text-white">0</p>
        <p class="text-[11px] text-slate-400">Contatos de investidores</p>
      </div>
    </div>

    <!-- Empty State Elegante -->
    <div class="rounded-2xl bg-[#0D2230] border border-white/10 p-12 text-center max-w-2xl mx-auto space-y-4 shadow-xl">
      <div class="w-16 h-16 rounded-2xl bg-[#00384A]/60 border border-white/10 flex items-center justify-center text-[#F28C28] mx-auto shadow-inner">
        <Home class="w-8 h-8" />
      </div>

      <div class="space-y-2">
        <h3 class="text-xl font-bold text-white">
          Você ainda não possui ativos na vitrine
        </h3>
        <p class="text-xs sm:text-sm text-slate-400 leading-relaxed max-w-md mx-auto">
          Cadastre seu imóvel urbano ou gleba rural para ser analisado pela curadoria e compliance da LIT Capital e exibido para investidores qualificados.
        </p>
      </div>

      <div class="pt-2">
        <button
          type="button"
          class="inline-flex items-center gap-2 px-5 py-3 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] hover:from-[#c35a1d] hover:to-[#e07b1d] text-white text-xs sm:text-sm font-bold shadow-lg shadow-[#D96826]/25 transition cursor-pointer"
        >
          <PlusCircle class="w-4 h-4" />
          <span>Cadastrar Novo Ativo</span>
        </button>
      </div>
    </div>
  </div>
</template>
