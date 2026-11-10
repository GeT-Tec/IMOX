<script setup lang="ts">
import {
  Scale,
  ShieldCheck,
  FileCheck,
  FileSpreadsheet,
  AlertTriangle,
  Clock,
  CheckCircle2,
  ArrowUpRight,
  Sparkles,
  Search,
  Filter
} from 'lucide-vue-next'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

// KPIs de Governança & Risco da LIT Capital
const legalKpis = [
  {
    label: 'Due Diligence (Em andamento)',
    value: '3',
    sub: 'Processos ativos de auditoria',
    icon: Clock,
    color: 'text-[#F28C28]'
  },
  {
    label: 'Ativos em Compliance (LIT Score A+)',
    value: '24',
    sub: 'Imóveis e carteiras homologadas',
    icon: ShieldCheck,
    color: 'text-emerald-400'
  },
  {
    label: 'Minutas Contratuais',
    value: '100%',
    sub: 'Auditadas e padronizadas',
    icon: FileCheck,
    color: 'text-sky-400'
  }
]

// Esteira de Análise Jurídica e Risco (Due Diligence)
const dueDiligenceItems = [
  {
    id: 'dd-01',
    ativo: 'Fazenda Rio Claro (Agro)',
    categoria: 'Ativo Rural • CAR & Reserva Legal',
    tipoAnalise: 'Due Diligence Ambiental',
    responsavel: 'Equipe LIT',
    data: 'Hoje',
    status: 'Aprovado (Risco Baixo)',
    statusType: 'success',
    litScore: 'LIT Score A+'
  },
  {
    id: 'dd-02',
    ativo: 'Edifício Morar Reserva',
    categoria: 'Incorporação Imobiliária • Lançamento',
    tipoAnalise: 'Minuta de Incorporação',
    responsavel: 'Escritório Parceiro B2B',
    data: 'Ontem',
    status: 'Em Análise',
    statusType: 'warning',
    litScore: 'LIT Score B+'
  },
  {
    id: 'dd-03',
    ativo: 'Loteamento Sol Nascente',
    categoria: 'Desenvolvimento Urbano • Gleba',
    tipoAnalise: 'Análise de Passivo (RGI)',
    responsavel: 'Equipe LIT',
    data: '08/11/2026',
    status: 'Com Ressalvas',
    statusType: 'caution',
    litScore: 'LIT Score C'
  }
]
</script>

<template>
  <div class="space-y-8">
    <!-- Cabeçalho Exclusivo da Vertical 04 -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <div class="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#F28C28] mb-1">
          <Scale class="w-4 h-4" />
          <span>Vertical 04 • Jurídico, Due Diligence & Governança</span>
        </div>
        <h1 class="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
          Jurídico & Compliance
        </h1>
        <p class="text-xs sm:text-sm text-slate-300 mt-1 max-w-2xl leading-relaxed">
          Due Diligence, auditoria de risco (LIT Score) e governança contratual para ativos imobiliários, incorporações e crédito estruturado.
        </p>
      </div>

      <div class="flex items-center gap-3">
        <button
          type="button"
          class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] hover:from-[#c35a1d] hover:to-[#e07b1d] text-white text-xs sm:text-sm font-bold shadow-md shadow-[#D96826]/20 hover:brightness-110 transition cursor-pointer"
        >
          <FileSpreadsheet class="w-4 h-4" />
          <span>Nova Due Diligence</span>
        </button>
      </div>
    </div>

    <!-- Cards de KPIs Jurídicos -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-5">
      <div
        v-for="kpi in legalKpis"
        :key="kpi.label"
        class="p-5 rounded-2xl bg-[#0D2230] border border-white/10 space-y-2 shadow-lg"
      >
        <div class="flex items-center justify-between text-slate-400 text-xs font-semibold uppercase">
          <span>{{ kpi.label }}</span>
          <component :is="kpi.icon" :class="['w-4 h-4', kpi.color]" />
        </div>
        <p class="text-3xl font-extrabold text-white tracking-tight">{{ kpi.value }}</p>
        <p class="text-[11px] text-slate-400">{{ kpi.sub }}</p>
      </div>
    </div>

    <!-- Esteira de Análise Jurídica e Risco (Tabela) -->
    <div class="p-6 rounded-2xl bg-[#0D2230] border border-white/10 space-y-5 shadow-xl">
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h3 class="text-base font-bold text-white flex items-center gap-2">
            <span>Esteira de Análise Jurídica e Risco</span>
            <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-[#F28C28]/15 text-[#F28C28] border border-[#F28C28]/30">
              <Sparkles class="w-3 h-3" />
              LIT Score Engine
            </span>
          </h3>
          <p class="text-xs text-slate-400 mt-0.5">
            Mapeamento preventivo de passivos cíveis, fiscais, trabalhistas e conformidade registral.
          </p>
        </div>

        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/[0.04] border border-white/10 text-slate-300 text-xs font-medium">
          Total de processos: <strong class="text-white">{{ dueDiligenceItems.length }}</strong>
        </span>
      </div>

      <div class="rounded-xl border border-white/10 overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse text-xs">
            <thead>
              <tr class="bg-[#002936] border-b border-white/10 text-[11px] font-bold uppercase tracking-wider text-slate-300">
                <th class="py-4 px-5">Ativo / Projeto</th>
                <th class="py-4 px-5">Tipo de Análise</th>
                <th class="py-4 px-5">Responsável</th>
                <th class="py-4 px-5">Data</th>
                <th class="py-4 px-5">Status de Compliance</th>
                <th class="py-4 px-5 text-right">Parecer</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-white/5 text-slate-300">
              <tr
                v-for="item in dueDiligenceItems"
                :key="item.id"
                class="hover:bg-white/[0.02] transition"
              >
                <!-- Ativo / Projeto -->
                <td class="py-4 px-5">
                  <p class="font-bold text-white text-sm">{{ item.ativo }}</p>
                  <p class="text-[11px] text-slate-400">{{ item.categoria }}</p>
                </td>

                <!-- Tipo de Análise -->
                <td class="py-4 px-5 font-medium text-slate-200">
                  {{ item.tipoAnalise }}
                </td>

                <!-- Responsável -->
                <td class="py-4 px-5 text-slate-300">
                  <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-white/[0.03] border border-white/5 text-[11px]">
                    {{ item.responsavel }}
                  </span>
                </td>

                <!-- Data -->
                <td class="py-4 px-5 font-mono text-slate-400 text-[11px]">
                  {{ item.data }}
                </td>

                <!-- Status de Compliance -->
                <td class="py-4 px-5">
                  <span
                    :class="[
                      'inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold',
                      item.statusType === 'success'
                        ? 'bg-emerald-500/15 text-emerald-300 border border-emerald-500/30'
                        : item.statusType === 'warning'
                          ? 'bg-[#D96826]/15 text-[#F28C28] border border-[#D96826]/30'
                          : 'bg-amber-500/15 text-amber-300 border border-amber-500/30'
                    ]"
                  >
                    <CheckCircle2 v-if="item.statusType === 'success'" class="w-3.5 h-3.5" />
                    <Clock v-else-if="item.statusType === 'warning'" class="w-3.5 h-3.5" />
                    <AlertTriangle v-else class="w-3.5 h-3.5" />
                    {{ item.status }}
                  </span>
                </td>

                <!-- Parecer / Ação -->
                <td class="py-4 px-5 text-right">
                  <span class="inline-flex items-center gap-1 text-xs font-semibold text-[#F28C28] hover:text-[#d96826] hover:underline cursor-pointer transition">
                    Ver Relatório
                    <ArrowUpRight class="w-3.5 h-3.5" />
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>
