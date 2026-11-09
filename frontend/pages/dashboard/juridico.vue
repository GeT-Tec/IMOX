<script setup lang="ts">
import {
  Scale,
  FileCheck2,
  ShieldCheck,
  CheckCircle2,
  FileText,
  Search,
  ArrowUpRight
} from 'lucide-vue-next'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const legalStats = [
  { label: 'Matrículas Auditadas', value: '8', sub: 'Conferência registral completa', icon: FileCheck2 },
  { label: 'Conformidade Registral', value: '100%', sub: 'Sem ônus ou gravames impeditivos', icon: ShieldCheck },
  { label: 'Certidões Negativas', value: '24', sub: 'Receita, CNDT e Justiças', icon: CheckCircle2 }
]

const records = [
  {
    id: 'mat-01',
    matricula: '45.192',
    assetName: 'Edifício Royal Sunset',
    cartorio: '1º Ofício de Registro de Imóveis',
    city: 'Vila Velha, ES',
    burden: 'Livre e Desembaraçado',
    status: 'Auditado & Conforme'
  },
  {
    id: 'mat-02',
    matricula: '78.401',
    assetName: 'Fazenda Vale do Canaã',
    cartorio: 'Cartório do Registro Geral de Imóveis',
    city: 'Santa Teresa, ES',
    burden: 'Sem Ônus Reais / CAR Vinculado',
    status: 'Auditado & Conforme'
  },
  {
    id: 'mat-03',
    matricula: '102.390',
    assetName: 'Mansão Suspensa do Canto',
    cartorio: '2ª Zona de Registro de Imóveis',
    city: 'Vitória, ES',
    burden: 'Certidão Vintenária Emitida',
    status: 'Auditado & Conforme'
  }
]
</script>

<template>
  <div class="space-y-8">
    <!-- Cabeçalho -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <div class="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#F28C28] mb-1">
          <Scale class="w-4 h-4" />
          <span>Vertical 03 • Cartório, RGI & Compliance Registral</span>
        </div>
        <h1 class="text-2xl font-bold text-white tracking-tight">Cartório & Governança Jurídica</h1>
        <p class="text-xs sm:text-sm text-slate-400 mt-0.5">
          Auditoria preventiva de matrículas, emissão de certidões e due diligence imobiliária.
        </p>
      </div>

      <button
        type="button"
        class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] hover:from-[#c35a1d] hover:to-[#e07b1d] text-white text-xs sm:text-sm font-bold shadow-md shadow-[#D96826]/20 transition cursor-pointer shrink-0"
      >
        <FileText class="w-4 h-4" />
        <span>Solicitar Auditoria de RGI</span>
      </button>
    </div>

    <!-- Mini-Dashboard -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-5">
      <div
        v-for="st in legalStats"
        :key="st.label"
        class="p-5 rounded-2xl bg-[#0D2230] border border-white/10 space-y-2 shadow-lg"
      >
        <div class="flex items-center justify-between text-slate-400 text-xs font-semibold uppercase">
          <span>{{ st.label }}</span>
          <component :is="st.icon" class="w-4 h-4 text-[#F28C28]" />
        </div>
        <p class="text-3xl font-extrabold text-white">{{ st.value }}</p>
        <p class="text-[11px] text-slate-400">{{ st.sub }}</p>
      </div>
    </div>

    <!-- Tabela de Matrículas e Conformidade -->
    <div class="space-y-4">
      <div class="flex items-center justify-between">
        <h3 class="text-base font-bold text-white">
          Esteira de Matrículas em Monitoramento
        </h3>
        <span class="text-xs text-slate-400">
          Total: <strong class="text-white">{{ records.length }}</strong> matrículas auditadas
        </span>
      </div>

      <div class="rounded-2xl bg-[#0D2230] border border-white/10 overflow-hidden shadow-xl">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-[#002936] border-b border-white/10 text-[11px] font-bold uppercase tracking-wider text-slate-300">
                <th class="py-4 px-6">Matrícula / Ativo</th>
                <th class="py-4 px-6">Cartório Competente</th>
                <th class="py-4 px-6">Comarca</th>
                <th class="py-4 px-6">Situação Jurídica</th>
                <th class="py-4 px-6">Parecer Compliance</th>
                <th class="py-4 px-6 text-right">Certidão</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-white/10 text-sm">
              <tr
                v-for="item in records"
                :key="item.id"
                class="hover:bg-white/[0.02] transition"
              >
                <td class="py-4 px-6">
                  <p class="font-bold text-white">Matrícula nº {{ item.matricula }}</p>
                  <p class="text-xs text-slate-400">{{ item.assetName }}</p>
                </td>
                <td class="py-4 px-6 text-slate-300 text-xs">
                  {{ item.cartorio }}
                </td>
                <td class="py-4 px-6 text-slate-300 text-xs">
                  {{ item.city }}
                </td>
                <td class="py-4 px-6 text-slate-200 text-xs">
                  {{ item.burden }}
                </td>
                <td class="py-4 px-6">
                  <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-500/15 text-emerald-300 border border-emerald-500/30">
                    <CheckCircle2 class="w-3.5 h-3.5" />
                    {{ item.status }}
                  </span>
                </td>
                <td class="py-4 px-6 text-right">
                  <span class="inline-flex items-center gap-1 text-xs font-semibold text-[#F28C28] cursor-pointer hover:underline">
                    Visualizar PDF
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
