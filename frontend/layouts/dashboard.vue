<script setup lang="ts">
import {
  LayoutDashboard,
  Globe,
  ExternalLink,
  Building,
  Heart,
  User,
  Building2,
  Sprout,
  Scale,
  Landmark,
  ShieldCheck,
  Users,
  ClipboardCheck,
  LogOut,
  Menu,
  X
} from 'lucide-vue-next'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const route = useRoute()

const mobileSidebarOpen = ref(false)

interface UserProfileSidebar {
  id: string
  role: 'admin' | 'b2b_partner' | 'broker' | 'pf_owner' | 'customer'
  full_name: string
  email: string | null
}

const userProfile = ref<UserProfileSidebar | null>(null)

async function loadUserProfile() {
  if (!user.value?.id) {
    userProfile.value = null
    return
  }

  const { data } = await supabase
    .from('user_profiles')
    .select('id, role, full_name, email')
    .eq('id', user.value.id)
    .maybeSingle<UserProfileSidebar>()

  userProfile.value = data || null
}

function formatRoleBadge(role?: string) {
  switch (role) {
    case 'broker':
      return 'Corretor'
    case 'b2b_partner':
      return 'Parceiro B2B'
    case 'customer':
      return 'Investidor'
    case 'admin':
      return 'Admin'
    default:
      return role || 'Membro'
  }
}

watch(
  () => user.value?.id,
  () => {
    loadUserProfile()
  },
  { immediate: true }
)

onMounted(() => {
  loadUserProfile()
})

const menuGroups = [
  {
    id: 'principal',
    title: 'Principal',
    items: [
      {
        id: 'overview',
        label: 'Visão Geral',
        to: '/dashboard',
        icon: LayoutDashboard
      },
      {
        id: 'vitrine',
        label: 'Vitrine Pública',
        to: '/',
        icon: Globe,
        isExternal: true
      }
    ]
  },
  {
    id: 'meu-painel',
    title: 'Meu Painel',
    items: [
      {
        id: 'meus-anuncios',
        label: 'Meus Anúncios',
        to: '/dashboard/meus-anuncios',
        icon: Building
      },
      {
        id: 'favoritos',
        label: 'Favoritos',
        to: '/dashboard/favoritos',
        icon: Heart
      },
      {
        id: 'perfil',
        label: 'Meu Perfil',
        to: '/dashboard/perfil',
        icon: User
      }
    ]
  },
  {
    id: 'servicos',
    title: 'Serviços LIT Capital',
    items: [
      {
        id: 'urbanos',
        label: 'Ativos Urbanos',
        to: '/dashboard/urbanos',
        icon: Building2
      },
      {
        id: 'rurais',
        label: 'Ativos Rurais (Agro)',
        to: '/dashboard/rurais',
        icon: Sprout
      },
      {
        id: 'juridico',
        label: 'Cartório & Jurídico',
        to: '/dashboard/juridico',
        icon: Scale
      },
      {
        id: 'credito',
        label: 'Crédito & Funding',
        to: '/dashboard/credito',
        icon: Landmark
      }
    ]
  }
]

const adminNavigationItems = [
  {
    id: 'admin-dashboard',
    label: 'Dashboard Master',
    to: '/admin/dashboard',
    icon: ShieldCheck
  },
  {
    id: 'admin-users',
    label: 'Gestão de Acessos',
    to: '/admin/usuarios',
    icon: Users
  },
  {
    id: 'admin-moderation',
    label: 'Moderação de Ativos',
    to: '/admin/moderacao-anuncios',
    icon: ClipboardCheck
  }
]

function isItemActive(itemTo: string) {
  if (itemTo === '/') return false
  if (itemTo === '/dashboard') {
    return route.path === '/dashboard'
  }
  return route.path === itemTo || route.path.startsWith(itemTo + '/')
}

async function handleSignOut() {
  userProfile.value = null
  await supabase.auth.signOut()
  await navigateTo('/login')
}
</script>

<template>
  <div class="min-h-screen flex bg-[#07161F] text-slate-100">
    <!-- Overlay Mobile -->
    <div
      v-if="mobileSidebarOpen"
      class="fixed inset-0 z-40 bg-black/60 backdrop-blur-xs lg:hidden"
      @click="mobileSidebarOpen = false"
    />

    <!-- Sidebar Corporativa LIT Capital / ImobiLit -->
    <aside
      :class="[
        'fixed inset-y-0 left-0 z-50 w-80 bg-[#002936] border-r border-white/10 flex flex-col justify-between transition-transform duration-200 lg:static lg:translate-x-0 overflow-y-auto',
        mobileSidebarOpen ? 'translate-x-0' : '-translate-x-full'
      ]"
    >
      <div>
        <div class="h-0.5 w-full bg-gradient-to-r from-[#D96826] via-[#F28C28] to-[#D96826]" />

        <!-- Cabeçalho da Marca -->
        <div class="p-6 border-b border-white/[0.08] flex items-center justify-between">
          <BrandLockup size="lg" to="/dashboard" />

          <button
            type="button"
            class="lg:hidden text-slate-400 hover:text-white p-1"
            aria-label="Fechar menu"
            @click="mobileSidebarOpen = false"
          >
            <X class="w-5 h-5" />
          </button>
        </div>

        <!-- Blocos de Navegação Estruturados -->
        <div class="p-4 space-y-6">
          <div
            v-for="group in menuGroups"
            :key="group.id"
            class="space-y-1"
          >
            <p class="px-3 py-1 text-[11px] font-bold uppercase tracking-wider text-slate-400/80">
              {{ group.title }}
            </p>

            <NuxtLink
              v-for="item in group.items"
              :key="item.id"
              :to="item.to"
              @click="mobileSidebarOpen = false"
              :class="[
                'group flex items-center justify-between px-3.5 py-2.5 rounded-xl text-xs sm:text-sm font-medium transition-all',
                isItemActive(item.to)
                  ? 'bg-[#D96826] text-white shadow-md shadow-[#D96826]/20 font-semibold'
                  : 'text-slate-300 hover:bg-white/[0.06] hover:text-white'
              ]"
            >
              <div class="flex items-center gap-3 min-w-0">
                <component
                  :is="item.icon"
                  :class="[
                    'w-4 h-4 shrink-0 transition-colors',
                    isItemActive(item.to) ? 'text-white' : 'text-[#F28C28] group-hover:text-white'
                  ]"
                />
                <span class="truncate">{{ item.label }}</span>
              </div>

              <!-- Indicador de Link Externo para Vitrine -->
              <ExternalLink
                v-if="item.isExternal"
                class="w-3.5 h-3.5 text-slate-400 group-hover:text-white shrink-0 ml-2 opacity-70"
              />
            </NuxtLink>
          </div>

          <!-- Seção Governança Master (Isolada para Admin) -->
          <div
            v-if="userProfile?.role === 'admin'"
            class="space-y-1 border-t border-white/10 pt-4"
          >
            <p class="px-3 py-1 text-[11px] font-bold uppercase tracking-wider text-[#F28C28]">
              Governança Master
            </p>

            <NuxtLink
              v-for="adm in adminNavigationItems"
              :key="adm.id"
              :to="adm.to"
              @click="mobileSidebarOpen = false"
              :class="[
                'group flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs sm:text-sm font-medium transition-all',
                isItemActive(adm.to)
                  ? 'bg-[#D96826] text-white shadow-md shadow-[#D96826]/20 font-semibold'
                  : 'text-slate-300 hover:bg-white/[0.06] hover:text-white'
              ]"
            >
              <component
                :is="adm.icon"
                :class="[
                  'w-4 h-4 shrink-0 transition-colors',
                  isItemActive(adm.to) ? 'text-white' : 'text-[#F28C28] group-hover:text-white'
                ]"
              />
              <span class="truncate">{{ adm.label }}</span>
            </NuxtLink>
          </div>
        </div>
      </div>

      <!-- Rodapé da Sidebar: Sessão Ativa & Logout -->
      <div class="p-4 border-t border-white/10 bg-[#001F29] space-y-3">
        <NuxtLink
          to="/dashboard/perfil"
          class="flex items-center gap-3 px-2 py-1.5 rounded-xl hover:bg-white/5 transition group cursor-pointer"
        >
          <div class="w-9 h-9 rounded-full bg-[#D96826]/20 border border-[#D96826]/50 flex items-center justify-center text-[#F28C28] font-bold text-sm shrink-0 group-hover:scale-105 transition-transform">
            {{ user?.email ? user.email.charAt(0).toUpperCase() : 'L' }}
          </div>
          <div class="min-w-0 flex-1">
            <div class="flex items-center gap-1.5">
              <p class="text-xs font-semibold text-white group-hover:text-[#F28C28] transition-colors truncate">
                {{ userProfile?.full_name || user?.user_metadata?.full_name || 'LIT Capital User' }}
              </p>
              <span
                v-if="userProfile?.role"
                class="px-1.5 py-0.5 rounded-full bg-[#D96826]/20 border border-[#D96826]/30 text-[#F28C28] text-[9px] font-bold shrink-0"
              >
                {{ formatRoleBadge(userProfile.role) }}
              </span>
            </div>
            <p class="text-[11px] text-slate-400 truncate">
              {{ user?.email || 'Sessão autenticada' }}
            </p>
          </div>
        </NuxtLink>

        <button
          type="button"
          @click="handleSignOut"
          class="w-full flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-white/[0.05] hover:bg-red-500/15 border border-white/10 hover:border-red-500/40 text-xs font-semibold text-slate-300 hover:text-red-200 transition cursor-pointer"
        >
          <LogOut class="w-4 h-4" />
          <span>Encerrar Sessão Segura</span>
        </button>
      </div>
    </aside>

    <!-- Área Principal de Conteúdo -->
    <div class="flex-1 flex flex-col min-w-0">
      <header class="h-16 bg-[#0B1D28]/90 backdrop-blur-md border-b border-white/10 px-6 flex items-center justify-between sticky top-0 z-30">
        <div class="flex items-center gap-4">
          <button
            type="button"
            class="lg:hidden p-2 rounded-lg bg-white/5 text-slate-300 hover:text-white"
            @click="mobileSidebarOpen = true"
          >
            <Menu class="w-5 h-5" />
          </button>

          <div>
            <h1 class="text-sm sm:text-base font-bold text-white tracking-tight">
              Imobi<span class="text-[#F28C28]">Lit</span> • Terminal Multi-Serviços
            </h1>
            <p class="text-[11px] text-slate-400 hidden sm:block">
              LIT Capital Asset & Capital Management — Operação Integrada
            </p>
          </div>
        </div>

        <div class="flex items-center gap-3">
          <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-xs font-medium">
            <ShieldCheck class="w-3.5 h-3.5" />
            Compliance & RLS Ativo
          </span>
        </div>
      </header>

      <main class="flex-1 p-6 sm:p-8 lg:p-10 max-w-7xl w-full mx-auto">
        <slot />
      </main>
    </div>
  </div>
</template>
