<script setup lang="ts">
import {
  Heart,
  MapPin,
  Maximize2,
  BedDouble,
  Bath,
  Car,
  ArrowUpRight,
  Sparkles
} from 'lucide-vue-next'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const favoriteProperties = [
  {
    id: 'fav-01',
    title: 'Apartamento Frente Mar na Praia da Costa',
    badge: 'À venda',
    badgeClass: 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30',
    price: 'R$ 2.850.000',
    neighborhood: 'Praia da Costa',
    city: 'Vila Velha, ES',
    areaSqm: 220,
    bedrooms: 4,
    bathrooms: 4,
    parking: 3,
    imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=800&q=80'
  },
  {
    id: 'fav-02',
    title: 'Mansão Suspensa com Vista Panorâmica',
    badge: 'Lançamento',
    badgeClass: 'bg-[#D96826]/20 text-[#F28C28] border border-[#D96826]/40',
    price: 'R$ 4.200.000',
    neighborhood: 'Praia do Canto',
    city: 'Vitória, ES',
    areaSqm: 310,
    bedrooms: 4,
    bathrooms: 5,
    parking: 4,
    imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=800&q=80'
  }
]
</script>

<template>
  <div class="space-y-8">
    <!-- Cabeçalho -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h1 class="text-2xl font-bold text-white tracking-tight">Imóveis Favoritos</h1>
        <p class="text-xs sm:text-sm text-slate-400 mt-1">
          Ativos selecionados em sua carteira de interesse para monitoramento e análise.
        </p>
      </div>

      <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-white/5 border border-white/10 text-xs font-semibold text-slate-300">
        <Heart class="w-3.5 h-3.5 text-red-400 fill-red-400" />
        <span>{{ favoriteProperties.length }} Ativos Salvos</span>
      </div>
    </div>

    <!-- Grid dos Imóveis Favoritados -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <div
        v-for="prop in favoriteProperties"
        :key="prop.id"
        class="group rounded-2xl bg-[#0D2230] border border-white/10 hover:border-[#D96826]/40 overflow-hidden shadow-xl transition-all duration-200 flex flex-col justify-between"
      >
        <div>
          <!-- Imagem + Badges -->
          <div class="relative h-56 w-full overflow-hidden bg-[#07161F]">
            <img
              :src="prop.imageUrl"
              :alt="prop.title"
              class="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
            />
            <div class="absolute inset-0 bg-gradient-to-t from-[#0D2230] via-transparent to-black/30" />

            <div class="absolute top-3.5 left-3.5">
              <span :class="['px-2.5 py-1 rounded-md text-[11px] font-bold uppercase tracking-wider', prop.badgeClass]">
                {{ prop.badge }}
              </span>
            </div>

            <button
              type="button"
              class="absolute top-3.5 right-3.5 w-9 h-9 rounded-full bg-black/50 backdrop-blur-md border border-white/20 flex items-center justify-center text-red-400 transition hover:scale-110 cursor-pointer"
              aria-label="Remover dos favoritos"
            >
              <Heart class="w-4 h-4 fill-red-400" />
            </button>

            <div class="absolute bottom-3 left-3.5">
              <p class="text-xl font-extrabold text-white">
                {{ prop.price }}
              </p>
            </div>
          </div>

          <!-- Informações -->
          <div class="p-5 space-y-3">
            <h3 class="text-base font-bold text-white group-hover:text-[#F28C28] transition-colors line-clamp-1">
              {{ prop.title }}
            </h3>

            <p class="inline-flex items-center gap-1.5 text-xs text-slate-400">
              <MapPin class="w-3.5 h-3.5 text-[#F28C28]" />
              {{ prop.neighborhood }} • {{ prop.city }}
            </p>

            <!-- Atributos -->
            <div class="grid grid-cols-4 gap-2 pt-2 border-t border-white/10 text-xs text-slate-300">
              <div class="flex items-center gap-1.5">
                <Maximize2 class="w-3.5 h-3.5 text-slate-400" />
                <span>{{ prop.areaSqm }} m²</span>
              </div>
              <div class="flex items-center gap-1.5">
                <BedDouble class="w-3.5 h-3.5 text-slate-400" />
                <span>{{ prop.bedrooms }} qtos</span>
              </div>
              <div class="flex items-center gap-1.5">
                <Bath class="w-3.5 h-3.5 text-slate-400" />
                <span>{{ prop.bathrooms }} banh</span>
              </div>
              <div class="flex items-center gap-1.5">
                <Car class="w-3.5 h-3.5 text-slate-400" />
                <span>{{ prop.parking }} vag</span>
              </div>
            </div>
          </div>
        </div>

        <div class="p-5 pt-0">
          <NuxtLink
            to="/"
            class="w-full flex items-center justify-center gap-2 py-2.5 px-4 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-xs font-semibold text-white transition cursor-pointer"
          >
            <span>Ver Ficha Técnica Completa</span>
            <ArrowUpRight class="w-4 h-4 text-[#F28C28]" />
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>
