<script setup lang="ts">
import {
  FileText,
  Scroll,
  Landmark,
  ShieldCheck,
  CheckCircle2,
  Search,
  ArrowUpRight,
  Sparkles,
  ExternalLink
} from 'lucide-vue-next'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const cartorioStats = [
  { label: 'Matrículas Emitidas', value: '142', sub: 'Buscas eletrônicas no Brasil', icon: FileText },
  { label: 'Certidões Vintenárias', value: '38', sub: 'Cadeia dominial auditada', icon: Scroll },
  { label: 'Conexão ONR / SREI', value: '100% Online', sub: 'Integração em tempo real', icon: Landmark }
]

const recentRequests = [
  {
    id: 'req-01',
    matricula: '52.190',
    cartorio: '1º Ofício do Registro de Imóveis de Vitória, ES',
    tipo: 'Certidão de Ônus & Ações',
    requisitante: 'Mesa de Crédito LIT',
    prazo: 'Emitida em 4h',
    status: 'Concluído'
  },
  {
    id: 'req-02',
    matricula: '14.882',
    cartorio: 'Registro Geral de Imóveis de Domingos Martins, ES',
    tipo: 'Certidão Vintenária com Cadeia Sucessória',
    requisitante: 'Due Diligence Agro',
    prazo: 'Em processamento',
    status: 'Em Análise'
  },
  {
    id: 'req-03',
    matricula: '98.411',
    cartorio: '2ª Zona de Imóveis de Vila Velha, ES',
    tipo: 'Integração ONR • Prenotação Digital',
    requisitante: 'Incorporadora B2B',
    prazo: 'Emitida em 2h',
    status: 'Concluído'
  }
]
</script>

<template>
  <div class="space-y-8">
    <!-- Cabeçalho da Página -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <div class="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#F28C28] mb-1">
          <FileText class="w-4 h-4" />
          <span>Vertical 03 • Serviços Notariais & Registrais</span>
        </div>
        <h1 class="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
          Cartório & Integração Registral (ONR)
        </h1>
        <p class="text-xs sm:text-sm text-slate-300 mt-1 max-w-2xl leading-relaxed">
          Emissão eletrônica de matrículas, certidões vintenárias sem hiatos e conexão oficial com o Operador Nacional do Registro de Imóveis.
        </p>
      </div>

      <div class="flex items-center gap-3">
        <button
          type="button"
          class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] text-white text-xs sm:text-sm font-bold shadow-md shadow-[#D96826]/20 hover:brightness-110 transition cursor-pointer"
        >
          <FileText class="w-4 h-4" />
          <span>Solicitar Matrícula 24h</span>
        </button>
      </div>
    </div>

    <!-- Cards de Métricas Registrais -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <div
        v-for="stat in cartorioStats"
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

    <!-- Tabela de Solicitações Notariais Recentes -->
    <div class="p-6 rounded-2xl bg-[#0D2230] border border-white/10 space-y-4 shadow-xl">
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h3 class="text-base font-bold text-white">
            Esteira de Pedidos de Certidões & Matrículas
          </h3>
          <p class="text-xs text-slate-400">
            Acompanhe o protocolo em tempo real junto aos Registros de Imóveis conveniados.
          </p>
        </div>
        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-xs font-medium">
          <ShieldCheck class="w-3.5 h-3.5" />
          Conexão ONR Homologada
        </span>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs text-slate-300">
          <thead class="text-[11px] uppercase font-bold text-slate-400 bg-white/[0.03] border-b border-white/10">
            <tr>
              <th class="py-3 px-4">Matrícula</th>
              <th class="py-3 px-4">Ofício de Registro</th>
              <th class="py-3 px-4">Tipo de Certidão</th>
              <th class="py-3 px-4">Requisitante</th>
              <th class="py-3 px-4">Prazo / Agilidade</th>
              <th class="py-3 px-4 text-right">Status</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-white/5">
            <tr v-for="item in recentRequests" :key="item.id" class="hover:bg-white/[0.02] transition">
              <td class="py-3.5 px-4 font-mono font-bold text-white">
                #{{ item.matricula }}
              </td>
              <td class="py-3.5 px-4 font-medium text-slate-200">
                {{ item.cartorio }}
              </td>
              <td class="py-3.5 px-4 text-slate-300">
                {{ item.tipo }}
              </td>
              <td class="py-3.5 px-4 text-slate-400">
                {{ item.requisitante }}
              </td>
              <td class="py-3.5 px-4 text-[#F28C28] font-semibold">
                {{ item.prazo }}
              </td>
              <td class="py-3.5 px-4 text-right">
                <span
                  :class="[
                    'px-2.5 py-1 rounded-full text-[11px] font-bold',
                    item.status === 'Concluído'
                      ? 'bg-emerald-500/15 text-emerald-300 border border-emerald-500/30'
                      : 'bg-[#D96826]/15 text-[#F28C28] border border-[#D96826]/30'
                  ]"
                >
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
