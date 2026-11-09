<script setup lang="ts">
import {
  ShieldCheck,
  Users,
  ClipboardCheck,
  Building2,
  ArrowRight,
  CheckCircle2,
  Clock,
  XCircle
} from 'lucide-vue-next'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const user = useSupabaseUser()
const supabase = useSupabaseClient()

const totalUsers = ref(1)
const pendingCount = ref(0)
const approvedCount = ref(0)

onMounted(async () => {
  const { count: profilesCount } = await supabase
    .from('user_profiles')
    .select('*', { count: 'exact', head: true })
  if (typeof profilesCount === 'number') totalUsers.value = profilesCount

  const { count: pCount } = await supabase
    .from('properties')
    .select('*', { count: 'exact', head: true })
    .eq('approval_status', 'pending')
  if (typeof pCount === 'number') pendingCount.value = pCount

  const { count: aCount } = await supabase
    .from('properties')
    .select('*', { count: 'exact', head: true })
    .eq('approval_status', 'approved')
  if (typeof aCount === 'number') approvedCount.value = aCount
})

const rbacRoles = [
  {
    role: 'admin',
    label: '1. Admin Master',
    desc: 'Controle corporativo total da plataforma, governança, compliance e moderação de ativos.'
  },
  {
    role: 'b2b_partner',
    label: '2. Parceiro B2B',
    desc: 'Imobiliárias, incorporadoras e empresas parceiras integradas ao ecossistema.'
  },
  {
    role: 'broker',
    label: '3. Corretor Autônomo',
    desc: 'Corretores credenciados com registro profissional CRECI ativo no marketplace.'
  },
  {
    role: 'customer',
    label: '4. Usuário / Proprietário PF',
    desc: 'Investidor, comprador ou proprietário pessoa física anunciante na plataforma.'
  }
]
</script>

<template>
  <div class="space-y-8">
    <!-- Header Master Full -->
    <section class="rounded-2xl bg-gradient-to-r from-[#00384A] via-[#002936] to-[#0D2230] border border-[#D96826]/40 p-6 sm:p-8 shadow-xl">
      <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-6">
        <div class="space-y-2">
          <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#D96826]/20 border border-[#D96826]/50 text-[#F28C28] text-xs font-bold uppercase tracking-wider">
            <ShieldCheck class="w-4 h-4" />
            <span>Master Full Access • Governança Corporativa</span>
          </div>

          <h2 class="text-2xl sm:text-3xl font-extrabold text-white">
            Painel de Comando LIT Capital Master
          </h2>
          <p class="text-sm text-slate-300">
            Sessão ativa: <strong class="text-[#F28C28]">{{ user?.email }}</strong> — Governança institucional, controle de acessos e esteira de compliance de ativos.
          </p>
        </div>

        <div class="flex flex-wrap items-center gap-3">
          <NuxtLink
            to="/admin/usuarios"
            class="inline-flex items-center justify-center gap-2 px-5 py-3.5 rounded-xl bg-white/10 hover:bg-white/15 border border-white/15 text-white font-semibold text-sm transition"
          >
            <Users class="w-4 h-4 text-[#F28C28]" />
            <span>Gestão de Acessos & Governança</span>
          </NuxtLink>

          <NuxtLink
            to="/admin/moderacao-anuncios"
            class="inline-flex items-center justify-center gap-2 px-5 py-3.5 rounded-xl bg-[#D96826] hover:bg-[#c35a1d] text-white font-semibold text-sm shadow-lg shadow-[#D96826]/25 transition"
          >
            <ClipboardCheck class="w-4 h-4" />
            <span>Moderação de Ativos</span>
            <ArrowRight class="w-4 h-4" />
          </NuxtLink>
        </div>
      </div>
    </section>

    <!-- KPIs de Governança e Compliance -->
    <section class="grid grid-cols-1 sm:grid-cols-3 gap-5">
      <div class="p-6 rounded-2xl bg-[#0D2230] border border-white/10 space-y-2">
        <div class="flex items-center justify-between text-slate-400 text-xs font-semibold uppercase">
          <span>Contas Registradas</span>
          <Users class="w-4 h-4 text-[#F28C28]" />
        </div>
        <p class="text-3xl font-extrabold text-white">{{ totalUsers }}</p>
        <p class="text-xs text-slate-400">Usuários cadastrados na plataforma</p>
      </div>

      <div class="p-6 rounded-2xl bg-[#0D2230] border border-amber-500/30 space-y-2">
        <div class="flex items-center justify-between text-amber-300 text-xs font-semibold uppercase">
          <span>Anúncios Pendentes</span>
          <Clock class="w-4 h-4 text-amber-400" />
        </div>
        <p class="text-3xl font-extrabold text-white">{{ pendingCount }}</p>
        <p class="text-xs text-slate-400">Aguardando curadoria e compliance</p>
      </div>

      <div class="p-6 rounded-2xl bg-[#0D2230] border border-emerald-500/30 space-y-2">
        <div class="flex items-center justify-between text-emerald-300 text-xs font-semibold uppercase">
          <span>Anúncios na Vitrine Pública</span>
          <CheckCircle2 class="w-4 h-4 text-emerald-400" />
        </div>
        <p class="text-3xl font-extrabold text-white">{{ approvedCount }}</p>
        <p class="text-xs text-slate-400">Ativos publicados e disponíveis</p>
      </div>
    </section>

    <!-- Matriz de Governança de 4 Níveis -->
    <section class="rounded-2xl bg-[#0D2230] border border-white/10 p-6 space-y-4">
      <div>
        <h3 class="text-base font-bold text-white">
          Níveis de Acesso e Governança da Plataforma
        </h3>
        <p class="text-xs text-slate-400">
          4 perfis com alçadas e permissões corporativas dedicadas
        </p>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <div
          v-for="item in rbacRoles"
          :key="item.role"
          class="p-4 rounded-xl bg-[#07161F] border border-white/10 space-y-1.5"
        >
          <span class="inline-block font-mono text-[11px] px-2 py-0.5 rounded bg-[#00384A] text-[#F28C28] font-bold">
            {{ item.role }}
          </span>
          <p class="text-xs font-bold text-white">{{ item.label }}</p>
          <p class="text-[11px] text-slate-400 leading-relaxed">{{ item.desc }}</p>
        </div>
      </div>
    </section>
  </div>
</template>
