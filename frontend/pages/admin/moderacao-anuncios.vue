<script setup lang="ts">
import {
  ClipboardCheck,
  CheckCircle2,
  XCircle,
  Clock,
  ShieldAlert,
  RefreshCw
} from 'lucide-vue-next'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const supabase = useSupabaseClient()

interface PropertyModerationItem {
  id: string
  source_id: string
  address: string
  city: string
  state: string
  price: number
  property_type: string
  approval_status: 'pending' | 'approved' | 'rejected'
  matricula: string | null
  numero_car: string | null
}

const propertiesList = ref<PropertyModerationItem[]>([])
const loading = ref(false)
const filterStatus = ref<'all' | 'pending' | 'approved' | 'rejected'>('all')

async function fetchModerationQueue() {
  loading.value = true
  try {
    const { data } = await supabase
      .from('properties')
      .select('id, source_id, address, city, state, price, property_type, approval_status, matricula, numero_car')
      .order('created_at', { ascending: false })

    if (data) {
      propertiesList.value = data as PropertyModerationItem[]
    }
  } finally {
    loading.value = false
  }
}

async function updateStatus(propertyId: string, status: 'approved' | 'rejected' | 'pending') {
  const { error } = await supabase
    .from('properties')
    .update({ approval_status: status })
    .eq('id', propertyId)

  if (!error) {
    await fetchModerationQueue()
  }
}

const filteredProperties = computed(() => {
  if (filterStatus.value === 'all') return propertiesList.value
  return propertiesList.value.filter((p) => p.approval_status === filterStatus.value)
})

onMounted(() => {
  fetchModerationQueue()
})
</script>

<template>
  <div class="space-y-8">
    <!-- Cabeçalho da Esteira de Moderação -->
    <section class="rounded-2xl bg-[#0D2230] border border-white/10 p-6 sm:p-8 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div class="space-y-1.5">
        <div class="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#F28C28]">
          <ClipboardCheck class="w-4 h-4" />
          <span>Compliance & Curadoria LIT Capital</span>
        </div>
        <h2 class="text-2xl font-bold text-white">
          Fila de Moderação e Curadoria de Ativos
        </h2>
        <p class="text-xs text-slate-400">
          Gerencie a esteira de aprovação de novos ativos. Apenas imóveis revisados pela curadoria da LIT Capital são exibidos na Vitrine Pública. Alterações contratuais exigem nova validação.
        </p>
      </div>

      <button
        type="button"
        @click="fetchModerationQueue"
        class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-xs font-semibold text-slate-200 transition cursor-pointer shrink-0"
      >
        <RefreshCw :class="['w-4 h-4', loading ? 'animate-spin' : '']" />
        <span>Atualizar Fila</span>
      </button>
    </section>

    <!-- Filtros de Status -->
    <div class="flex flex-wrap gap-2">
      <button
        v-for="tab in [
          { id: 'all', label: 'Todos os Registros' },
          { id: 'pending', label: 'Pendentes de Revisão' },
          { id: 'approved', label: 'Aprovados' },
          { id: 'rejected', label: 'Rejeitados' }
        ]"
        :key="tab.id"
        type="button"
        @click="filterStatus = tab.id as any"
        :class="[
          'px-4 py-2 rounded-xl text-xs font-bold transition cursor-pointer',
          filterStatus === tab.id
            ? 'bg-[#D96826] text-white'
            : 'bg-[#0D2230] text-slate-300 border border-white/10 hover:border-white/25'
        ]"
      >
        {{ tab.label }}
      </button>
    </div>

    <!-- Lista / Estado Vazio -->
    <div
      v-if="filteredProperties.length === 0"
      class="rounded-2xl bg-[#0D2230] border border-white/10 p-12 text-center space-y-3"
    >
      <ShieldAlert class="w-10 h-10 text-[#F28C28] mx-auto" />
      <h3 class="text-base font-bold text-white">
        Nenhum anúncio encontrado para o filtro selecionado
      </h3>
      <p class="text-xs text-slate-400 max-w-md mx-auto">
        Nenhum ativo aguardando revisão no momento. Novos cadastros realizados por Corretores Parceiros ou Proprietários aparecerão automaticamente nesta fila.
      </p>
    </div>

    <div v-else class="space-y-4">
      <div
        v-for="item in filteredProperties"
        :key="item.id"
        class="rounded-2xl bg-[#0D2230] border border-white/10 p-6 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4"
      >
        <div class="space-y-1.5">
          <div class="flex items-center gap-2">
            <span
              :class="[
                'px-2.5 py-0.5 rounded-full text-[11px] font-bold uppercase',
                item.approval_status === 'approved'
                  ? 'bg-emerald-500/15 text-emerald-300 border border-emerald-500/30'
                  : item.approval_status === 'rejected'
                  ? 'bg-red-500/15 text-red-300 border border-red-500/30'
                  : 'bg-amber-500/15 text-amber-300 border border-amber-500/30'
              ]"
            >
              {{ item.approval_status === 'approved' ? 'Aprovado' : item.approval_status === 'rejected' ? 'Rejeitado' : 'Pendente de Revisão' }}
            </span>
            <span class="text-xs text-slate-400 font-mono">
              {{ item.property_type }} • {{ item.city }}/{{ item.state }}
            </span>
          </div>

          <h4 class="text-base font-bold text-white">{{ item.address }}</h4>
          <p class="text-xs text-slate-400">
            Matrícula RGI: {{ item.matricula || 'Não informada' }} • CAR: {{ item.numero_car || 'N/A' }}
          </p>
        </div>

        <div class="flex items-center gap-2 shrink-0">
          <button
            type="button"
            @click="updateStatus(item.id, 'approved')"
            class="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold transition cursor-pointer"
          >
            <CheckCircle2 class="w-4 h-4" />
            <span>Aprovar</span>
          </button>

          <button
            type="button"
            @click="updateStatus(item.id, 'pending')"
            class="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-amber-600/80 hover:bg-amber-600 text-white text-xs font-semibold transition cursor-pointer"
          >
            <Clock class="w-4 h-4" />
            <span>Pendente</span>
          </button>

          <button
            type="button"
            @click="updateStatus(item.id, 'rejected')"
            class="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-red-600/80 hover:bg-red-600 text-white text-xs font-semibold transition cursor-pointer"
          >
            <XCircle class="w-4 h-4" />
            <span>Rejeitar</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
