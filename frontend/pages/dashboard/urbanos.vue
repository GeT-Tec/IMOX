<script setup lang="ts">
import {
  Building2,
  TrendingUp,
  MapPin,
  CheckCircle2,
  Filter,
  Search,
  ArrowUpRight,
  Sparkles
} from 'lucide-vue-next'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const urbanStats = [
  { label: 'Ativos Homologados', value: '12', sub: 'Vitória e Vila Velha, ES', icon: Building2 },
  { label: 'Volume Geral (VGV)', value: 'R$ 45,8M', sub: 'Carteira consolidada', icon: TrendingUp },
  { label: 'Preço Médio do m²', value: 'R$ 13.450', sub: '+4,2% de valorização a.a.', icon: Sparkles }
]

const urbanProperties = [
  {
    id: 'urb-01',
    name: 'Edifício Royal Sunset',
    neighborhood: 'Praia da Costa',
    city: 'Vila Velha',
    type: 'Apartamento 4Q',
    area: '220 m²',
    price: 'R$ 2.850.000',
    status: 'Homologado'
  },
  {
    id: 'urb-02',
    name: 'Condomínio Reserva da Enseada',
    neighborhood: 'Enseada do Suá',
    city: 'Vitória',
    type: 'Penthouse Duplex',
    area: '340 m²',
    price: 'R$ 5.400.000',
    status: 'Homologado'
  },
  {
    id: 'urb-03',
    name: 'Mansão Suspensa do Canto',
    neighborhood: 'Praia do Canto',
    city: 'Vitória',
    type: 'Apartamento Linear',
    area: '310 m²',
    price: 'R$ 4.200.000',
    status: 'Homologado'
  },
  {
    id: 'urb-04',
    name: 'Residencial Penha Prime',
    neighborhood: 'Jardim da Penha',
    city: 'Vitória',
    type: 'Apartamento 3Q',
    area: '145 m²',
    price: 'R$ 1.650.000',
    status: 'Homologado'
  }
]
</script>

<template>
  <div class="space-y-8">
    <!-- Cabeçalho -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <div class="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#F28C28] mb-1">
          <Building2 class="w-4 h-4" />
          <span>Vertical 01 • Residencial & Comercial</span>
        </div>
        <h1 class="text-2xl font-bold text-white tracking-tight">Ativos Urbanos</h1>
        <p class="text-xs sm:text-sm text-slate-400 mt-0.5">
          Portfólio de empreendimentos de alto padrão curados e auditados pela LIT Capital.
        </p>
      </div>

      <NuxtLink
        to="/"
        class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-xs font-semibold text-white transition cursor-pointer shrink-0"
      >
        <span>Ver na Vitrine Pública</span>
        <ArrowUpRight class="w-4 h-4 text-[#F28C28]" />
      </NuxtLink>
    </div>

    <!-- Mini-Dashboard (3 Blocos de Estatísticas) -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-5">
      <div
        v-for="st in urbanStats"
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

    <!-- Tabela Corporativa de Ativos Urbanos -->
    <div class="space-y-4">
      <div class="flex items-center justify-between">
        <h3 class="text-base font-bold text-white">
          Portfólio Homologado em Carteira
        </h3>
        <span class="text-xs text-slate-400">
          Total: <strong class="text-white">{{ urbanProperties.length }}</strong> ativos listados
        </span>
      </div>

      <div class="rounded-2xl bg-[#0D2230] border border-white/10 overflow-hidden shadow-xl">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-[#002936] border-b border-white/10 text-[11px] font-bold uppercase tracking-wider text-slate-300">
                <th class="py-4 px-6">Empreendimento / Ativo</th>
                <th class="py-4 px-6">Localização</th>
                <th class="py-4 px-6">Tipologia</th>
                <th class="py-4 px-6">Valor de Avaliação</th>
                <th class="py-4 px-6">Status Curadoria</th>
                <th class="py-4 px-6 text-right">Ação</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-white/10 text-sm">
              <tr
                v-for="item in urbanProperties"
                :key="item.id"
                class="hover:bg-white/[0.02] transition"
              >
                <td class="py-4 px-6">
                  <p class="font-bold text-white">{{ item.name }}</p>
                  <p class="text-xs text-slate-400 font-mono">{{ item.area }} privativos</p>
                </td>
                <td class="py-4 px-6 text-slate-300">
                  <span class="inline-flex items-center gap-1.5">
                    <MapPin class="w-3.5 h-3.5 text-[#F28C28]" />
                    {{ item.neighborhood }}, {{ item.city }}
                  </span>
                </td>
                <td class="py-4 px-6 text-slate-300 text-xs">
                  {{ item.type }}
                </td>
                <td class="py-4 px-6 font-bold text-white">
                  {{ item.price }}
                </td>
                <td class="py-4 px-6">
                  <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-500/15 text-emerald-300 border border-emerald-500/30">
                    <CheckCircle2 class="w-3.5 h-3.5" />
                    {{ item.status }}
                  </span>
                </td>
                <td class="py-4 px-6 text-right">
                  <NuxtLink
                    to="/"
                    class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg bg-white/5 hover:bg-white/10 text-xs font-semibold text-slate-200 transition"
                  >
                    <span>Ficha</span>
                    <ArrowUpRight class="w-3.5 h-3.5 text-[#F28C28]" />
                  </NuxtLink>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>
