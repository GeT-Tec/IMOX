<script setup lang="ts">
import {
  LayoutDashboard,
  Building2,
  Sprout,
  Scale,
  Landmark,
  LogOut,
  ShieldCheck,
  Menu,
  X
} from 'lucide-vue-next'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const route = useRoute()

const mobileSidebarOpen = ref(false)

const navigationItems = [
  {
    id: 'overview',
    label: '1. Visão Geral (Dashboard)',
    shortLabel: 'Visão Geral',
    to: '/dashboard',
    icon: LayoutDashboard,
    badge: 'Ativo'
  },
  {
    id: 'urban',
    label: '2. Ativos Imobiliários (Urbano)',
    shortLabel: 'Ativos Urbanos',
    to: '/dashboard?vertical=urbano',
    icon: Building2,
    badge: 'Morar / Urbano'
  },
  {
    id: 'agro',
    label: '3. Ativos Rurais & ESG (Agro)',
    shortLabel: 'Ativos Rurais & ESG',
    to: '/dashboard?vertical=agro',
    icon: Sprout,
    badge: 'CAR / ESG'
  },
  {
    id: 'cartorio',
    label: '4. Serviços de Cartório & Jurídico',
    shortLabel: 'Cartório & Jurídico',
    to: '/dashboard?vertical=cartorio',
    icon: Scale,
    badge: 'RGI / Compliance'
  },
  {
    id: 'funding',
    label: '5. Viabilidade & Financiamento',
    shortLabel: 'Viabilidade & Capital',
    to: '/dashboard?vertical=financiamento',
    icon: Landmark,
    badge: 'LIT Capital'
  }
]

function isItemActive(itemTo: string) {
  if (itemTo === '/dashboard') {
    return route.path === '/dashboard' && !route.query.vertical
  }
  return route.fullPath === itemTo
}

async function handleSignOut() {
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
        'fixed inset-y-0 left-0 z-50 w-80 bg-[#002936] border-r border-white/10 flex flex-col justify-between transition-transform duration-200 lg:static lg:translate-x-0',
        mobileSidebarOpen ? 'translate-x-0' : '-translate-x-full'
      ]"
    >
      <!-- Faixa Institucional Laranja no Topo -->
      <div>
        <div class="h-1.5 w-full bg-gradient-to-r from-[#D96826] via-[#F28C28] to-[#D96826]" />

        <!-- Cabeçalho da Marca -->
        <div class="p-6 border-b border-white/10 flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="bg-white px-3 py-1.5 rounded-lg shadow-sm flex items-center">
              <img
                src="/images/lit-capital-logo.png"
                alt="LIT Capital"
                class="h-6 w-auto object-contain"
              />
            </div>
            <div>
              <span class="text-xl font-extrabold tracking-tight text-white">
                Imobi<span class="text-[#F28C28]">Lit</span>
              </span>
              <p class="text-[10px] uppercase tracking-widest text-slate-300 font-semibold">
                LIT Capital Ecosystem
              </p>
            </div>
          </div>

          <button
            type="button"
            class="lg:hidden text-slate-400 hover:text-white p-1"
            @click="mobileSidebarOpen = false"
          >
            <X class="w-5 h-5" />
          </button>
        </div>

        <!-- Menu de Verticais Multi-Serviços -->
        <div class="p-4 space-y-1.5">
          <p class="px-3 py-2 text-[11px] font-bold uppercase tracking-widest text-slate-400">
            Verticais de Serviços
          </p>

          <NuxtLink
            v-for="item in navigationItems"
            :key="item.id"
            :to="item.to"
            @click="mobileSidebarOpen = false"
            :class="[
              'group flex items-center justify-between px-3.5 py-3 rounded-xl text-sm font-medium transition-all',
              isItemActive(item.to)
                ? 'bg-[#D96826] text-white shadow-md shadow-[#D96826]/20'
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

            <span
              :class="[
                'ml-2 text-[10px] px-2 py-0.5 rounded-full font-semibold shrink-0',
                isItemActive(item.to)
                  ? 'bg-black/20 text-white'
                  : 'bg-white/[0.06] text-slate-300'
              ]"
            >
              {{ item.badge }}
            </span>
          </NuxtLink>
        </div>
      </div>

      <!-- Rodapé da Sidebar: Sessão Ativa & Logout -->
      <div class="p-4 border-t border-white/10 bg-[#001F29] space-y-3">
        <div class="flex items-center gap-3 px-2">
          <div class="w-9 h-9 rounded-full bg-[#D96826]/20 border border-[#D96826]/50 flex items-center justify-center text-[#F28C28] font-bold text-sm shrink-0">
            {{ user?.email ? user.email.charAt(0).toUpperCase() : 'L' }}
          </div>
          <div class="min-w-0 flex-1">
            <p class="text-xs font-semibold text-white truncate">
              {{ user?.user_metadata?.full_name || 'Investidor / Parceiro' }}
            </p>
            <p class="text-[11px] text-slate-400 truncate">
              {{ user?.email || 'Sessão autenticada' }}
            </p>
          </div>
        </div>

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
      <!-- Topbar Institucional -->
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
            Supabase RLS Ativo
          </span>
        </div>
      </header>

      <!-- Slot das Páginas -->
      <main class="flex-1 p-6 sm:p-8 lg:p-10 max-w-7xl w-full mx-auto">
        <slot />
      </main>
    </div>
  </div>
</template>
