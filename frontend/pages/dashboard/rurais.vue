<script setup lang="ts">
import {
  Sprout,
  TrendingUp,
  MapPin,
  CheckCircle2,
  TreePine,
  ShieldCheck,
  ArrowUpRight
} from 'lucide-vue-next'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const ruralStats = [
  { label: 'Fazendas em Carteira', value: '3', sub: 'Linhares, Santa Teresa e Domingos Martins', icon: Sprout },
  { label: 'Área Total Auditada', value: '1.200 ha', sub: '100% com CAR e Reserva Legal', icon: TreePine },
  { label: 'Avaliação Patrimonial', value: 'R$ 38,5M', sub: 'Agronegócio & Ativos ESG', icon: TrendingUp }
]

const ruralProperties = [
  {
    id: 'rur-01',
    name: 'Fazenda Vale do Canaã',
    municipality: 'Santa Teresa, ES',
    area: '420 hectares',
    vocation: 'Café Conilon & Especial',
    carStatus: 'CAR Ativo • Reserva 20%',
    price: 'R$ 14.800.000'
  },
  {
    id: 'rur-02',
    name: 'Gleba Rio Doce',
    municipality: 'Linhares, ES',
    area: '510 hectares',
    vocation: 'Cacau & Pecuária de Corte',
    carStatus: 'CAR Ativo • Outorga Hídrica',
    price: 'R$ 16.200.000'
  },
  {
    id: 'rur-03',
    name: 'Sítio Alto das Montanhas',
    municipality: 'Domingos Martins, ES',
    area: '270 hectares',
    vocation: 'Agrofloresta & Ecoturismo',
    carStatus: 'CAR Homologado • Nascentes',
    price: 'R$ 7.500.000'
  }
]
</script>

<template>
  <div class="space-y-8">
    <!-- Cabeçalho -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <div class="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#F28C28] mb-1">
          <Sprout class="w-4 h-4" />
          <span>Vertical 02 • Agronegócio & Governança ESG</span>
        </div>
        <h1 class="text-2xl font-bold text-white tracking-tight">Ativos Rurais (Agro)</h1>
        <p class="text-xs sm:text-sm text-slate-400 mt-0.5">
          Fazendas produtivas e terras estruturadas com georreferenciamento poligonal e conformidade ambiental.
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
        v-for="st in ruralStats"
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

    <!-- Tabela Corporativa de Ativos Rurais -->
    <div class="space-y-4">
      <div class="flex items-center justify-between">
        <h3 class="text-base font-bold text-white">
          Fazendas e Glebas Auditadas
        </h3>
        <span class="text-xs text-slate-400">
          Total: <strong class="text-white">{{ ruralProperties.length }}</strong> glebas rurais homologadas
        </span>
      </div>

      <div class="rounded-2xl bg-[#0D2230] border border-white/10 overflow-hidden shadow-xl">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-[#002936] border-b border-white/10 text-[11px] font-bold uppercase tracking-wider text-slate-300">
                <th class="py-4 px-6">Propriedade Rural</th>
                <th class="py-4 px-6">Região / ES</th>
                <th class="py-4 px-6">Área Total</th>
                <th class="py-4 px-6">Vocação Produtiva</th>
                <th class="py-4 px-6">Conformidade Ambiental</th>
                <th class="py-4 px-6 text-right">Valor Estimado</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-white/10 text-sm">
              <tr
                v-for="item in ruralProperties"
                :key="item.id"
                class="hover:bg-white/[0.02] transition"
              >
                <td class="py-4 px-6">
                  <p class="font-bold text-white">{{ item.name }}</p>
                  <p class="text-xs text-slate-400 font-mono">Georreferenciada SIGEF</p>
                </td>
                <td class="py-4 px-6 text-slate-300">
                  <span class="inline-flex items-center gap-1.5">
                    <MapPin class="w-3.5 h-3.5 text-[#F28C28]" />
                    {{ item.municipality }}
                  </span>
                </td>
                <td class="py-4 px-6 font-semibold text-white">
                  {{ item.area }}
                </td>
                <td class="py-4 px-6 text-slate-300 text-xs">
                  {{ item.vocation }}
                </td>
                <td class="py-4 px-6">
                  <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-500/15 text-emerald-300 border border-emerald-500/30">
                    <ShieldCheck class="w-3.5 h-3.5" />
                    {{ item.carStatus }}
                  </span>
                </td>
                <td class="py-4 px-6 text-right font-bold text-[#F28C28]">
                  {{ item.price }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>
