<script setup lang="ts">
import {
  Building2,
  Sprout,
  Scale,
  Landmark,
  CheckCircle2,
  UserCheck,
  ArrowUpRight,
  Database
} from 'lucide-vue-next'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const user = useSupabaseUser()
const supabase = useSupabaseClient()

interface UserProfileRow {
  id: string
  role: 'customer' | 'broker' | 'cartorio' | 'builder'
  full_name: string
  company_name: string | null
  created_at: string | null
}

const profile = ref<UserProfileRow | null>(null)

onMounted(async () => {
  if (!user.value?.id) return
  const { data } = await supabase
    .from('user_profiles')
    .select('id, role, full_name, company_name, created_at')
    .eq('id', user.value.id)
    .maybeSingle()

  if (data) {
    profile.value = data as UserProfileRow
  }
})

const serviceVerticals = [
  {
    title: 'Ativos Imobiliários (Urbano)',
    subtitle: 'Incorporação, Lançamentos & Estoque',
    description:
      'Catálogo analítico de empreendimentos urbanos, acompanhamento de valor de m², histórico transacional e geolocalização PostGIS.',
    icon: Building2,
    tag: 'Vertical 01',
    metrics: 'Tabelas properties + developments'
  },
  {
    title: 'Ativos Rurais & ESG (Agro)',
    subtitle: 'Propriedades Rurais, CAR & Reserva Legal',
    description:
      'Estruturação de fazendas e glebas produtivas com validação de Cadastro Ambiental Rural (CAR), recursos hídricos e perímetro poligonal.',
    icon: Sprout,
    tag: 'Vertical 02',
    metrics: 'Polígonos PostGIS + Compliance ESG'
  },
  {
    title: 'Serviços de Cartório & Jurídico',
    subtitle: 'RGI, Matrículas & Due Diligence',
    description:
      'Conferência registral automatizada de matrículas, cartório de registro de imóveis competente (RGI) e status jurídico de ônus reais.',
    icon: Scale,
    tag: 'Vertical 03',
    metrics: 'Auditoria Registral Integrada'
  },
  {
    title: 'Viabilidade & Financiamento',
    subtitle: 'Estruturação de Crédito & Capital (LIT Capital)',
    description:
      'Análise de viabilidade econômico-financeira, simulação de funding imobiliário/agro e conexão direta com mesas de crédito estruturado.',
    icon: Landmark,
    tag: 'Vertical 04',
    metrics: 'Originação B2B & B2C'
  }
]
</script>

<template>
  <div class="space-y-8">
    <!-- Banner de Boas-Vindas Autenticado (Puxando user.value.email) -->
    <section class="relative overflow-hidden rounded-2xl bg-gradient-to-r from-[#00384A] via-[#002B3A] to-[#0D2230] border border-white/10 p-6 sm:p-8 shadow-xl">
      <div class="absolute top-0 right-0 w-72 h-72 rounded-full bg-[#D96826]/15 blur-3xl pointer-events-none" />

      <div class="relative z-10 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-6">
        <div class="space-y-2">
          <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#D96826]/20 border border-[#D96826]/40 text-[#F28C28] text-xs font-semibold">
            <CheckCircle2 class="w-3.5 h-3.5" />
            <span>Sessão Autenticada via Supabase Auth</span>
          </div>

          <h2 class="text-2xl sm:text-3xl font-bold text-white tracking-tight">
            Bem-vindo à Imobi<span class="text-[#F28C28]">Lit</span>,
            <span class="text-[#F28C28] break-all">{{ user?.email }}</span>
          </h2>

          <p class="text-sm text-slate-300 max-w-2xl leading-relaxed">
            Você está conectado ao ecossistema Multi-Serviços da <strong class="text-white">LIT Capital</strong>. Utilize o menu lateral para navegar entre Ativos Urbanos, Agro/ESG, Cartório & Jurídico e Estruturação de Financiamento.
          </p>
        </div>

        <!-- Card Resumo do Perfil Sincronizado -->
        <div class="bg-[#07161F]/80 border border-white/10 rounded-xl p-4 min-w-[260px] space-y-2">
          <div class="flex items-center justify-between text-xs text-slate-400">
            <span class="flex items-center gap-1.5 font-semibold text-slate-200">
              <UserCheck class="w-4 h-4 text-[#F28C28]" />
              Perfil Sincronizado
            </span>
            <span class="uppercase px-2 py-0.5 rounded bg-[#D96826]/20 text-[#F28C28] font-bold text-[10px]">
              {{ profile?.role || user?.user_metadata?.role || 'customer' }}
            </span>
          </div>

          <div class="text-xs text-slate-300 space-y-1 pt-1 border-t border-white/10">
            <p class="truncate">
              <span class="text-slate-400">E-mail:</span> {{ user?.email }}
            </p>
            <p class="truncate">
              <span class="text-slate-400">Nome:</span>
              {{ profile?.full_name || user?.user_metadata?.full_name || 'Titular da Conta' }}
            </p>
            <p class="truncate font-mono text-[11px] text-slate-400">
              UID: {{ user?.id?.slice(0, 18) }}...
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Grid das 4 Verticais Operacionais da LIT Capital -->
    <section class="space-y-4">
      <div class="flex items-center justify-between">
        <div>
          <h3 class="text-lg font-bold text-white">
            Verticais Operacionais Multi-Serviços
          </h3>
          <p class="text-xs text-slate-400">
            Módulos integrados ao schema corporativo do Supabase Cloud (`kbnyesbkmablickwcwfw`)
          </p>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
        <div
          v-for="vertical in serviceVerticals"
          :key="vertical.title"
          class="group rounded-2xl bg-[#0D2230] border border-white/10 hover:border-[#D96826]/50 p-6 transition flex flex-col justify-between space-y-5"
        >
          <div class="space-y-3">
            <div class="flex items-center justify-between">
              <span class="text-[11px] font-bold uppercase tracking-wider px-2.5 py-1 rounded-md bg-[#00384A] text-[#F28C28] border border-white/10">
                {{ vertical.tag }}
              </span>
              <div class="w-10 h-10 rounded-xl bg-[#00384A] border border-white/10 flex items-center justify-center text-[#F28C28]">
                <component :is="vertical.icon" class="w-5 h-5" />
              </div>
            </div>

            <div>
              <h4 class="text-base font-bold text-white group-hover:text-[#F28C28] transition-colors">
                {{ vertical.title }}
              </h4>
              <p class="text-xs font-medium text-slate-400">
                {{ vertical.subtitle }}
              </p>
            </div>

            <p class="text-sm text-slate-300 leading-relaxed">
              {{ vertical.description }}
            </p>
          </div>

          <div class="pt-4 border-t border-white/10 flex items-center justify-between text-xs text-slate-400">
            <span class="inline-flex items-center gap-1.5">
              <Database class="w-3.5 h-3.5 text-[#F28C28]" />
              {{ vertical.metrics }}
            </span>
            <span class="inline-flex items-center gap-1 font-semibold text-[#F28C28]">
              Explorar módulo
              <ArrowUpRight class="w-3.5 h-3.5" />
            </span>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>
