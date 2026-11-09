<script setup lang="ts">
import {
  Building2,
  Sprout,
  Scale,
  Landmark,
  CheckCircle2,
  UserCheck,
  ArrowRight,
  TrendingUp,
  ShieldCheck,
  Sparkles
} from 'lucide-vue-next'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const user = useSupabaseUser()
const supabase = useSupabaseClient()

interface UserProfileRow {
  id: string
  role: 'admin' | 'b2b_partner' | 'broker' | 'customer'
  full_name: string
  company_name: string | null
  created_at: string | null
}

const profile = ref<UserProfileRow | null>(null)

const formatRole = (role?: string) => {
  switch (role) {
    case 'broker':
      return 'Corretor Credenciado'
    case 'b2b_partner':
      return 'Parceiro B2B'
    case 'customer':
      return 'Investidor / PF'
    case 'admin':
      return 'Admin Master'
    default:
      return 'Investidor'
  }
}

const userInitials = computed(() => {
  const name = profile.value?.full_name || user.value?.user_metadata?.full_name || user.value?.email || 'U'
  return name.trim().charAt(0).toUpperCase()
})

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
    subtitle: 'Alto Padrão, Condomínios & Lançamentos',
    description:
      'Catálogo analítico de empreendimentos urbanos no Espírito Santo, acompanhamento de valor de m² e geolocalização homologada.',
    icon: Building2,
    tag: 'Vertical 01',
    to: '/dashboard/urbanos',
    ctaText: 'Acessar Portfólio',
    metrics: [
      { label: '12 Ativos Homologados' },
      { label: 'R$ 45M VGV' }
    ]
  },
  {
    title: 'Ativos Rurais & ESG (Agro)',
    subtitle: 'Propriedades Produtivas, CAR & Reserva Legal',
    description:
      'Fazendas e glebas agropecuárias estruturadas com validação do Cadastro Ambiental Rural (CAR), recursos hídricos e perímetro poligonal.',
    icon: Sprout,
    tag: 'Vertical 02',
    to: '/dashboard/rurais',
    ctaText: 'Acessar Portfólio',
    metrics: [
      { label: '3 Fazendas' },
      { label: '1.200 hectares verificados' }
    ]
  },
  {
    title: 'Serviços de Cartório & Jurídico',
    subtitle: 'RGI, Matrículas & Due Diligence',
    description:
      'Conferência registral automatizada de matrículas, certidões negativas de ônus reais e governança documental com compliance LIT Capital.',
    icon: Scale,
    tag: 'Vertical 03',
    to: '/dashboard/juridico',
    ctaText: 'Consultar Matrículas',
    metrics: [
      { label: '8 Matrículas Auditadas' },
      { label: '100% RGI Válido' }
    ]
  },
  {
    title: 'Viabilidade & Financiamento',
    subtitle: 'Estruturação de Crédito & Capital (LIT Capital)',
    description:
      'Simulação de funding imobiliário e agro, crédito com garantia real (Home Equity) e conexão direta com mesas de originação de capital.',
    icon: Landmark,
    tag: 'Vertical 04',
    to: '/dashboard/credito',
    ctaText: 'Simular Funding',
    metrics: [
      { label: 'R$ 15M em Análise' },
      { label: 'A partir de 0,99% a.m.' }
    ]
  }
]
</script>

<template>
  <div class="space-y-8">
    <!-- Banner de Boas-Vindas Autenticado (Puxando Nome do Perfil) -->
    <section class="relative overflow-hidden rounded-2xl bg-gradient-to-r from-[#00384A] via-[#002B3A] to-[#0D2230] border border-white/10 p-6 sm:p-8 shadow-xl">
      <div class="absolute top-0 right-0 w-80 h-80 rounded-full bg-[#D96826]/15 blur-3xl pointer-events-none" />

      <div class="relative z-10 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-6">
        <div class="space-y-2.5">
          <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#D96826]/20 border border-[#D96826]/40 text-[#F28C28] text-xs font-semibold">
            <Sparkles class="w-3.5 h-3.5" />
            <span>Ecossistema Corporativo LIT Capital • Vitrine Viva</span>
          </div>

          <h2 class="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
            Bem-vindo à Imobi<span class="text-[#F28C28]">Lit</span>,
            <span class="text-[#F28C28]">{{ profile?.full_name || user?.user_metadata?.full_name || 'Investidor' }}</span>
          </h2>

          <p class="text-sm text-slate-300 max-w-2xl leading-relaxed">
            Painel consolidado de ativos e serviços da <strong class="text-white">LIT Capital</strong>. Acompanhe a esteira de ativos urbanos, agropecuários, regularização jurídica de matrículas e estruturação de funding.
          </p>
        </div>

        <!-- Card Executivo de Perfil & Sessão Segura -->
        <div class="relative rounded-2xl bg-white/[0.06] hover:bg-white/[0.09] backdrop-blur-md border border-white/15 p-5 min-w-[280px] max-w-sm space-y-3.5 shadow-2xl transition-all shrink-0">
          <!-- Topo: Status de Conexão e Perfil Oficial -->
          <div class="flex items-center justify-between gap-3">
            <span class="inline-flex items-center gap-2 text-xs font-medium text-slate-300">
              <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
              Sessão Conectada
            </span>
            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full bg-[#D96826]/20 border border-[#D96826]/40 text-[#F28C28] text-[11px] font-bold tracking-wide">
              {{ formatRole(profile?.role || user?.user_metadata?.role) }}
            </span>
          </div>

          <!-- Meio: Avatar com Inicial + Identidade do Usuário -->
          <div class="flex items-center gap-3.5 pt-1">
            <div class="w-11 h-11 rounded-xl bg-gradient-to-br from-[#D96826] to-[#F28C28] flex items-center justify-center text-white font-extrabold text-base shadow-md shadow-[#D96826]/25 shrink-0">
              {{ userInitials }}
            </div>
            <div class="min-w-0 flex-1">
              <p class="text-sm font-bold text-white truncate">
                {{ profile?.full_name || user?.user_metadata?.full_name || 'Titular da Conta' }}
              </p>
              <p class="text-xs text-slate-300 truncate">
                {{ user?.email }}
              </p>
            </div>
          </div>

          <!-- Rodapé do Card: Acesso Direto ao Perfil e ID -->
          <div class="flex items-center justify-between pt-2.5 border-t border-white/10 text-xs">
            <NuxtLink
              to="/dashboard/perfil"
              class="inline-flex items-center gap-1.5 text-[#F28C28] hover:text-white font-semibold transition group cursor-pointer"
            >
              <span>Gerenciar Perfil</span>
              <ArrowRight class="w-3.5 h-3.5 group-hover:translate-x-0.5 transition-transform" />
            </NuxtLink>
            <span class="text-[11px] text-slate-400">
              ID: #{{ (profile?.id || user?.id || '000000').slice(0, 6) }}
            </span>
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
            Ativos curados e esteiras operacionais disponíveis para originação e investimento
          </p>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
        <div
          v-for="vertical in serviceVerticals"
          :key="vertical.title"
          class="group rounded-2xl bg-[#0D2230] border border-white/10 hover:border-[#D96826]/50 p-6 transition flex flex-col justify-between space-y-5 shadow-lg"
        >
          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <span class="text-[11px] font-bold uppercase tracking-wider px-2.5 py-1 rounded-md bg-[#00384A] text-[#F28C28] border border-white/10">
                {{ vertical.tag }}
              </span>
              <div class="w-10 h-10 rounded-xl bg-[#00384A] border border-white/10 flex items-center justify-center text-[#F28C28] group-hover:scale-105 transition-transform">
                <component :is="vertical.icon" class="w-5 h-5" />
              </div>
            </div>

            <div>
              <h4 class="text-base font-bold text-white group-hover:text-[#F28C28] transition-colors">
                {{ vertical.title }}
              </h4>
              <p class="text-xs font-medium text-slate-400 mt-0.5">
                {{ vertical.subtitle }}
              </p>
            </div>

            <!-- Tags Visuais de Métricas (Mock Metrics) -->
            <div class="flex flex-wrap gap-2 pt-1">
              <span
                v-for="(m, idx) in vertical.metrics"
                :key="idx"
                class="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg bg-white/[0.05] border border-white/10 text-xs font-semibold text-slate-200"
              >
                <TrendingUp class="w-3.5 h-3.5 text-[#F28C28]" />
                {{ m.label }}
              </span>
            </div>

            <p class="text-xs sm:text-sm text-slate-300 leading-relaxed">
              {{ vertical.description }}
            </p>
          </div>

          <div class="pt-4 border-t border-white/10">
            <NuxtLink
              :to="vertical.to"
              class="inline-flex items-center justify-center gap-2 w-full py-2.5 px-4 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] hover:from-[#c35a1d] hover:to-[#e07b1d] text-white text-xs sm:text-sm font-bold shadow-md shadow-[#D96826]/20 transition cursor-pointer"
            >
              <span>{{ vertical.ctaText }}</span>
              <ArrowRight class="w-4 h-4" />
            </NuxtLink>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>
