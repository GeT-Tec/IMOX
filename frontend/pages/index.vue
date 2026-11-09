<script setup lang="ts">
import {
  Search,
  Lock,
  RotateCcw,
  ShieldCheck,
  SlidersHorizontal
} from 'lucide-vue-next'
import type { PropertyCardItem } from '~/components/PropertyCard.vue'

const user = useSupabaseUser()

const searchQuery = ref('')
const searchInput = ref<HTMLInputElement | null>(null)
const isScrolled = ref(false)

function handleScroll() {
  isScrolled.value = window.scrollY > 8
}

// Atalho "/" foca a busca (ignorado quando já se está digitando em um campo)
function handleShortcut(event: KeyboardEvent) {
  const target = event.target as HTMLElement | null
  const typing =
    target?.tagName === 'INPUT' ||
    target?.tagName === 'TEXTAREA' ||
    target?.tagName === 'SELECT' ||
    target?.isContentEditable
  if (event.key === '/' && !typing) {
    event.preventDefault()
    searchInput.value?.focus()
  }
}

onMounted(() => {
  handleScroll()
  window.addEventListener('scroll', handleScroll, { passive: true })
  window.addEventListener('keydown', handleShortcut)
})

onBeforeUnmount(() => {
  window.removeEventListener('scroll', handleScroll)
  window.removeEventListener('keydown', handleShortcut)
})

const selectedCity = ref('all')
const activeCategory = ref<'all' | 'urbano' | 'agro' | 'lancamentos'>('all')

const filterChips = [
  { id: 'all', label: 'Todos' },
  { id: 'urbano', label: 'Urbano' },
  { id: 'agro', label: 'Fazendas/Agro' },
  { id: 'lancamentos', label: 'Lançamentos' }
] as const

// PASSO 3: Array reativo mockProperties com imóveis Urbanos, Lançamentos e Fazendas/Agro
const mockProperties = ref<PropertyCardItem[]>([
  {
    id: 'imobilit-01',
    title: 'Casa com 3 quartos em Jardim Camburi',
    type: 'Casa',
    category: 'urbano',
    badge: 'À venda',
    price: 2125000,
    city: 'Vitória',
    neighborhood: 'Jardim Camburi',
    areaSqm: 260,
    bedrooms: 3,
    bathrooms: 2,
    parking: 3,
    imageUrl:
      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=900&q=80'
  },
  {
    id: 'imobilit-02',
    title: 'Casa com 5 quartos em Enseada do Suá',
    type: 'Casa',
    category: 'lancamentos',
    badge: 'Lançamento',
    price: 6095000,
    city: 'Vitória',
    neighborhood: 'Enseada do Suá',
    areaSqm: 416,
    bedrooms: 5,
    bathrooms: 3,
    parking: 3,
    imageUrl:
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=900&q=80'
  },
  {
    id: 'imobilit-03',
    title: 'Casa com 4 quartos em Praia do Canto',
    type: 'Casa',
    category: 'urbano',
    badge: 'À venda',
    price: 2350000,
    city: 'Vitória',
    neighborhood: 'Praia do Canto',
    areaSqm: 173,
    bedrooms: 4,
    bathrooms: 4,
    parking: 2,
    imageUrl:
      'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=900&q=80'
  },
  {
    id: 'imobilit-04',
    title: 'Fazenda Vale do Café — CAR Ativo & Reserva Legal',
    type: 'Fazenda / Agro',
    category: 'agro',
    badge: 'Agro / ESG',
    price: 12800000,
    city: 'Domingos Martins',
    neighborhood: 'Pedra Azul • Zona Rural',
    areaSqm: 1850000,
    areaLabel: '185 ha',
    bedrooms: 6,
    bathrooms: 7,
    parking: 8,
    imageUrl:
      'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=900&q=80'
  },
  {
    id: 'imobilit-05',
    title: 'Apartamento Vista Mar com 4 suítes na Orla',
    type: 'Apartamento',
    category: 'lancamentos',
    badge: 'Lançamento',
    price: 4455000,
    city: 'Vila Velha',
    neighborhood: 'Praia da Costa',
    areaSqm: 284,
    bedrooms: 4,
    bathrooms: 5,
    parking: 4,
    imageUrl:
      'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=900&q=80'
  },
  {
    id: 'imobilit-06',
    title: 'Fazenda Rio Doce — Pecuária, Irrigação & Silos',
    type: 'Fazenda / Agro',
    category: 'agro',
    badge: 'Agro / ESG',
    price: 18500000,
    city: 'Linhares',
    neighborhood: 'Vale do Rio Doce',
    areaSqm: 3400000,
    areaLabel: '340 ha',
    bedrooms: 5,
    bathrooms: 5,
    parking: 10,
    imageUrl:
      'https://images.unsplash.com/photo-1500076656116-558758c991c1?auto=format&fit=crop&w=900&q=80'
  },
  {
    id: 'imobilit-07',
    title: 'Cobertura Linear 3 quartos no Barro Vermelho',
    type: 'Apartamento',
    category: 'urbano',
    badge: 'À venda',
    price: 1890000,
    city: 'Vitória',
    neighborhood: 'Barro Vermelho',
    areaSqm: 195,
    bedrooms: 3,
    bathrooms: 4,
    parking: 3,
    imageUrl:
      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=900&q=80'
  },
  {
    id: 'imobilit-08',
    title: 'Residencial Morar Jardins — Torre Horizon',
    type: 'Apartamento',
    category: 'lancamentos',
    badge: 'Lançamento',
    price: 1150000,
    city: 'Vila Velha',
    neighborhood: 'Itaparica',
    areaSqm: 112,
    bedrooms: 3,
    bathrooms: 3,
    parking: 2,
    imageUrl:
      'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&w=900&q=80'
  }
])

const citiesList = computed(() => {
  const unique = new Set(mockProperties.value.map((p) => p.city))
  return Array.from(unique)
})

const filteredProperties = computed(() => {
  return mockProperties.value.filter((item) => {
    const matchesCategory =
      activeCategory.value === 'all' || item.category === activeCategory.value
    const matchesCity =
      selectedCity.value === 'all' || item.city === selectedCity.value
    const q = searchQuery.value.trim().toLowerCase()
    const matchesSearch =
      !q ||
      item.title.toLowerCase().includes(q) ||
      item.neighborhood.toLowerCase().includes(q) ||
      item.city.toLowerCase().includes(q) ||
      item.type.toLowerCase().includes(q)

    return matchesCategory && matchesCity && matchesSearch
  })
})

function resetFilters() {
  searchQuery.value = ''
  selectedCity.value = 'all'
  activeCategory.value = 'all'
}
</script>

<template>
  <div class="min-h-screen bg-[#F4F7F9] text-slate-900 flex flex-col">
    <!-- 1. Navbar Institucional Fixa no Topo (marca ImobiLit by LIT Capital) -->
    <header
      :class="[
        'sticky top-0 z-40 bg-gradient-to-b from-[#003040] to-[#002936] transition-all duration-200',
        isScrolled ? 'shadow-[0_8px_24px_-12px_rgba(0,0,0,0.55)] backdrop-blur-md' : ''
      ]"
    >
      <!-- Fio institucional laranja -->
      <div class="absolute inset-x-0 top-0 h-0.5 bg-gradient-to-r from-[#D96826] via-[#F28C28] to-[#D96826]" />
      <div class="absolute inset-x-0 bottom-0 h-px bg-white/[0.08]" />

      <div
        :class="[
          'max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center gap-4 transition-all duration-200',
          isScrolled ? 'h-14' : 'h-16'
        ]"
      >
        <!-- Esquerda: marca -->
        <BrandLockup />

        <!-- Centro: busca (vidro escuro, foco laranja, atalho "/") -->
        <div class="flex-1 min-w-0 max-w-lg mx-auto hidden sm:block">
          <label class="relative block">
            <span class="sr-only">Buscar imóveis</span>
            <Search class="w-4 h-4 text-slate-300/80 absolute left-4 top-1/2 -translate-y-1/2 pointer-events-none" />
            <input
              ref="searchInput"
              v-model="searchQuery"
              type="text"
              placeholder="Buscar bairro, rua, condomínio ou fazenda…"
              class="w-full rounded-full pl-11 pr-14 py-2.5 text-sm text-white placeholder-slate-300/70 bg-white/[0.07] hover:bg-white/10 border border-white/[0.12] focus:outline-none focus:bg-white/[0.12] focus:border-[#F28C28] focus:ring-[3px] focus:ring-[#F28C28]/25 transition"
            />
            <kbd
              class="hidden lg:block absolute right-3 top-1/2 -translate-y-1/2 text-xs rounded-md px-1.5 py-0.5 text-slate-300/70 border border-white/[0.14]"
            >/</kbd>
          </label>
        </div>

        <!-- Direita: ações -->
        <div class="flex items-center gap-2 shrink-0 ml-auto sm:ml-0">
          <button
            type="button"
            class="sm:hidden w-10 h-10 rounded-full flex items-center justify-center text-slate-200 hover:text-white hover:bg-white/[0.07] transition focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white"
            aria-label="Buscar"
            @click="searchInput?.focus()"
          >
            <Search class="w-[18px] h-[18px]" />
          </button>

          <NuxtLink
            to="/cadastro"
            class="hidden lg:inline-flex rounded-full px-4 py-2 text-sm font-semibold text-slate-200/85 hover:text-white hover:bg-white/[0.07] transition focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white"
          >
            Anunciar ativo
          </NuxtLink>

          <NuxtLink
            v-if="user"
            to="/dashboard"
            class="inline-flex items-center gap-2 px-4 sm:px-5 py-2.5 rounded-full bg-gradient-to-b from-[#E7762D] to-[#D96826] text-white text-sm font-bold shadow-[0_6px_16px_-6px_rgba(217,104,38,0.8),inset_0_1px_0_rgba(255,255,255,0.25)] hover:brightness-110 hover:-translate-y-px transition focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white"
          >
            <ShieldCheck class="w-4 h-4" />
            <span>Meu Painel</span>
          </NuxtLink>

          <NuxtLink
            v-else
            to="/login"
            class="inline-flex items-center gap-2 px-4 sm:px-5 py-2.5 rounded-full bg-gradient-to-b from-[#E7762D] to-[#D96826] text-white text-sm font-bold shadow-[0_6px_16px_-6px_rgba(217,104,38,0.8),inset_0_1px_0_rgba(255,255,255,0.25)] hover:brightness-110 hover:-translate-y-px transition focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white"
          >
            <Lock class="w-[15px] h-[15px]" />
            <span>Acessar <span class="hidden sm:inline">Portal</span></span>
          </NuxtLink>
        </div>
      </div>
    </header>

    <!-- Conteúdo Principal da Vitrine -->
    <main class="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-6">
      <!-- 2. Barra de Filtros Superior + Chips -->
      <section class="space-y-4">
        <!-- Linha 1: Seletor de Cidade + Contador "Exibindo X ativos" + Botão "Limpar filtros" -->
        <div class="flex flex-wrap items-center justify-between gap-4">
          <div class="flex flex-wrap items-center gap-3">
            <select
              v-model="selectedCity"
              class="px-4 py-2 rounded-xl bg-white border border-slate-200 text-xs sm:text-sm font-semibold text-[#002936] shadow-2xs focus:outline-none focus:border-[#D96826] cursor-pointer"
            >
              <option value="all">Todas as cidades (ES)</option>
              <option v-for="city in citiesList" :key="city" :value="city">
                {{ city }} (ES)
              </option>
            </select>

            <span class="text-xs sm:text-sm font-medium text-slate-600">
              Exibindo <strong class="text-[#002936] font-bold">{{ filteredProperties.length }}</strong> ativos
            </span>
          </div>

          <button
            type="button"
            @click="resetFilters"
            class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-[#002936] hover:bg-[#00384A] text-white text-xs font-bold shadow-xs transition cursor-pointer"
          >
            <RotateCcw class="w-3.5 h-3.5" />
            <span>Limpar filtros</span>
          </button>
        </div>

        <!-- Linha 2: Chips de Categoria ("Todos", "Urbano", "Fazendas/Agro", "Lançamentos") -->
        <div class="flex flex-wrap items-center gap-2.5">
          <button
            v-for="chip in filterChips"
            :key="chip.id"
            type="button"
            @click="activeCategory = chip.id"
            :class="[
              'px-4 py-2 rounded-full text-xs sm:text-sm font-bold transition-all cursor-pointer',
              activeCategory === chip.id
                ? 'bg-[#002936] text-white shadow-sm ring-2 ring-[#D96826]/60'
                : 'bg-white text-slate-700 border border-slate-200 hover:border-[#002936]/40 hover:text-[#002936]'
            ]"
          >
            {{ chip.label }}
          </button>
        </div>
      </section>

      <!-- 3. Grid Responsivo de Imóveis (grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4) -->
      <section v-if="filteredProperties.length > 0">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          <PropertyCard
            v-for="item in filteredProperties"
            :key="item.id"
            :property="item"
          />
        </div>
      </section>

      <!-- Estado Vazio se a busca não encontrar resultados -->
      <section
        v-else
        class="bg-white rounded-2xl border border-slate-200 p-12 text-center space-y-3"
      >
        <SlidersHorizontal class="w-8 h-8 text-[#D96826] mx-auto" />
        <h3 class="text-base font-bold text-[#002936]">
          Nenhum ativo encontrado para este filtro
        </h3>
        <p class="text-xs text-slate-500 max-w-md mx-auto">
          Tente buscar por outro bairro, cidade ou clique em "Limpar filtros" para visualizar todo o portfólio homologado da ImobiLit.
        </p>
      </section>
    </main>

    <!-- Rodapé Institucional Clean -->
    <footer class="bg-white border-t border-slate-200 mt-12 py-6">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-slate-500">
        <div class="flex items-center gap-2">
          <span class="font-extrabold text-[#002936]">
            Imobi<span class="text-[#D96826]">Lit</span>
          </span>
          <span>• Uma plataforma LIT Capital® Asset &amp; Capital Management</span>
        </div>
        <div class="flex items-center gap-4">
          <NuxtLink to="/login" class="font-semibold text-[#002936] hover:text-[#D96826]">
            Acesso Institucional
          </NuxtLink>
          <NuxtLink to="/cadastro" class="font-semibold text-[#D96826] hover:underline">
            Anunciar Ativo (PF / Corretor / B2B)
          </NuxtLink>
        </div>
      </div>
    </footer>
  </div>
</template>
