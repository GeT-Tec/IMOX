<script setup lang="ts">
import {
  Shield,
  ShieldCheck,
  Scale,
  Building2,
  CheckCircle2,
  Lock,
  ArrowUpRight,
  Sparkles,
  FileCheck2
} from 'lucide-vue-next'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const garantiaStats = [
  { label: 'Apólices Vigentes', value: '47', sub: 'Seguradoras SUSEP parceiras', icon: ShieldCheck },
  { label: 'Laudos Patrimoniais', value: 'R$ 84M', sub: 'Norma Técnica NBR 14.653', icon: Scale },
  { label: 'Fiança sem Fiador', value: '100% Digital', sub: 'Aprovação em até 15 minutos', icon: Sparkles }
]

const recentGarantias = [
  {
    id: 'gar-01',
    apolice: 'SUSEP-88912',
    ativo: 'Edifício Royal Sunset • Cobertura 01',
    tipo: 'Seguro Garantia Término de Obra',
    seguradora: 'Porto Seguro S.A.',
    cobertura: 'R$ 4.500.000',
    status: 'Vigente & Ativa'
  },
  {
    id: 'gar-02',
    apolice: 'LAUDO-2026/04',
    ativo: 'Fazenda Rio Doce • 340 ha',
    tipo: 'Avaliação Patrimonial NBR 14.653',
    seguradora: 'IBAPE Peritos Associados',
    cobertura: 'R$ 18.500.000',
    status: 'Homologado'
  },
  {
    id: 'gar-03',
    apolice: 'FIAN-10294',
    ativo: 'Mansão Suspensa do Canto • Apto 1401',
    tipo: 'Fiança Locatícia Sem Fiador',
    seguradora: 'Tokio Marine Seguradora',
    cobertura: 'R$ 180.000 (Anual)',
    status: 'Vigente & Ativa'
  }
]
</script>

<template>
  <div class="space-y-8">
    <!-- Cabeçalho da Página -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <div class="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#F28C28] mb-1">
          <Shield class="w-4 h-4" />
          <span>Vertical 06 • Mitigação de Risco & Liquidez</span>
        </div>
        <h1 class="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
          Segurança, Garantias & Avaliação Patrimonial
        </h1>
        <p class="text-xs sm:text-sm text-slate-300 mt-1 max-w-2xl leading-relaxed">
          Seguros imobiliários corporativos, fiança locatícia sem fiador, garantia de término de obra e laudos periciais da NBR 14.653.
        </p>
      </div>

      <div class="flex items-center gap-3">
        <button
          type="button"
          class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] text-white text-xs sm:text-sm font-bold shadow-md shadow-[#D96826]/20 hover:brightness-110 transition cursor-pointer"
        >
          <ShieldCheck class="w-4 h-4" />
          <span>Cotar Garantia / Laudo</span>
        </button>
      </div>
    </div>

    <!-- Cards de Métricas de Garantias -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <div
        v-for="stat in garantiaStats"
        :key="stat.label"
        class="p-5 rounded-2xl bg-[#0D2230] border border-white/10 flex items-center justify-between shadow-lg"
      >
        <div>
          <p class="text-xs text-slate-400 font-medium">
            {{ stat.label }}
          </p>
          <p class="text-2xl font-black text-white mt-1">
            {{ stat.value }}
          </p>
          <p class="text-[11px] text-slate-400 mt-0.5">
            {{ stat.sub }}
          </p>
        </div>
        <div class="w-11 h-11 rounded-xl bg-[#00384A] border border-white/10 flex items-center justify-center text-[#F28C28]">
          <component :is="stat.icon" class="w-5 h-5" />
        </div>
      </div>
    </div>

    <!-- Tabela de Apólices & Laudos Cadastrados -->
    <div class="p-6 rounded-2xl bg-[#0D2230] border border-white/10 space-y-4 shadow-xl">
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h3 class="text-base font-bold text-white">
            Apólices & Laudos Periciais Vinculados
          </h3>
          <p class="text-xs text-slate-400">
            Painel consolidado de garantias ativas sob custódia e compliance LIT Capital.
          </p>
        </div>
        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-xs font-medium">
          <Lock class="w-3.5 h-3.5" />
          Cofre RLS Criptografado
        </span>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs text-slate-300">
          <thead class="text-[11px] uppercase font-bold text-slate-400 bg-white/[0.03] border-b border-white/10">
            <tr>
              <th class="py-3 px-4">Código / Apólice</th>
              <th class="py-3 px-4">Ativo Vinculado</th>
              <th class="py-3 px-4">Modalidade de Garantia</th>
              <th class="py-3 px-4">Instituição Emissora</th>
              <th class="py-3 px-4">Cobertura / Valor</th>
              <th class="py-3 px-4 text-right">Status</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-white/5">
            <tr v-for="item in recentGarantias" :key="item.id" class="hover:bg-white/[0.02] transition">
              <td class="py-3.5 px-4 font-mono font-bold text-white">
                {{ item.apolice }}
              </td>
              <td class="py-3.5 px-4 font-medium text-slate-200">
                {{ item.ativo }}
              </td>
              <td class="py-3.5 px-4 text-slate-300">
                {{ item.tipo }}
              </td>
              <td class="py-3.5 px-4 text-slate-400">
                {{ item.seguradora }}
              </td>
              <td class="py-3.5 px-4 text-[#F28C28] font-bold">
                {{ item.cobertura }}
              </td>
              <td class="py-3.5 px-4 text-right">
                <span class="px-2.5 py-1 rounded-full text-[11px] font-bold bg-emerald-500/15 text-emerald-300 border border-emerald-500/30">
                  {{ item.status }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
