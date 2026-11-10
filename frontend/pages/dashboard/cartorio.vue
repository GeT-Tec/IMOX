<script setup lang="ts">
import {
  FileText,
  Scroll,
  Landmark,
  ShieldCheck,
  CheckCircle2,
  Search,
  ArrowUpRight,
  Clock,
  AlertCircle,
  Loader2,
  RefreshCw
} from 'lucide-vue-next'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const supabase = useSupabaseClient()
const session = useSupabaseSession()
const config = useRuntimeConfig()

// Estado reativo da esteira de pedidos
const orders = ref<any[]>([])
const loading = ref(false)
const submitting = ref(false)
const feedback = ref<{ type: 'success' | 'error'; message: string } | null>(null)

// Carrega pedidos da tabela cartorio_orders no Supabase
const fetchOrders = async () => {
  loading.value = true
  try {
    const { data, error } = await supabase
      .from('cartorio_orders')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) throw error
    orders.value = data || []
  } catch (err: any) {
    console.error('Erro ao carregar esteira de cartório:', err)
  } finally {
    loading.value = false
  }
}

// Disparo para o backend FastAPI
const solicitarMatricula = async () => {
  submitting.value = true
  feedback.value = null
  try {
    let token = session.value?.access_token
    if (!token) {
      const { data } = await supabase.auth.getSession()
      token = data.session?.access_token
    }

    if (!token) {
      throw new Error('Sessão expirada. Faça login novamente.')
    }

    const apiBaseUrl = config.public.apiBaseUrl || 'http://localhost:8000'
    const matriculaAleatoria = Math.floor(10000 + Math.random() * 90000).toString()

    const payload = {
      matricula: matriculaAleatoria,
      rgi: '1º Ofício do Registro de Imóveis de Vitória, ES',
      cartorio_cns: '02.123-4',
      tipo_certidao: 'matricula_inteiro_teor'
    }

    const response = await $fetch<{ order_id: string; transaction_id: string; status: string; protocolo_onr?: string }>(
      `${apiBaseUrl}/api/cartorio/solicitar`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`
        },
        body: payload
      }
    )

    feedback.value = {
      type: 'success',
      message: `Solicitação da Matrícula nº ${payload.matricula} registrada no ONR! Protocolo: ${response.protocolo_onr || 'Gerado'}`
    }

    await fetchOrders()
  } catch (err: any) {
    console.error('Erro ao solicitar matrícula:', err)
    feedback.value = {
      type: 'error',
      message: err.data?.detail || err.message || 'Falha ao solicitar matrícula no ONR.'
    }
  } finally {
    submitting.value = false
  }
}

// Download/Visualização de PDF assinado
const baixarDocumento = async (order: any) => {
  if (!order.documento_path) return
  try {
    const { data, error } = await supabase.storage
      .from('documentos_oficiais')
      .createSignedUrl(order.documento_path, 60)

    if (error) throw error
    if (data?.signedUrl) {
      window.open(data.signedUrl, '_blank')
    }
  } catch (err: any) {
    console.error('Erro ao abrir documento:', err)
    alert('Erro ao resgatar documento oficial: ' + (err.message || 'Acesso negado'))
  }
}

// Formatação amigável de data
const formatDate = (dateStr: string) => {
  if (!dateStr) return '-'
  const d = new Date(dateStr)
  return d.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' })
}

// Métricas dinâmicas
const cartorioStats = computed(() => {
  const total = orders.value.length
  const concluidos = orders.value.filter(o => o.status === 'concluido').length
  const emAndamento = orders.value.filter(o => o.status === 'processando' || o.status === 'solicitado').length

  return [
    {
      label: 'Matrículas na Esteira',
      value: String(total),
      sub: `${emAndamento} em processamento no ONR`,
      icon: FileText
    },
    {
      label: 'Certidões Emitidas',
      value: String(concluidos),
      sub: 'Download oficial liberado',
      icon: Scroll
    },
    {
      label: 'Conexão ONR / SREI',
      value: '100% Online',
      sub: 'API FastAPI & Webhook ativos',
      icon: Landmark
    }
  ]
})

onMounted(() => {
  fetchOrders()
})
</script>

<template>
  <div class="space-y-8">
    <!-- Cabeçalho da Página -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <div class="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#F28C28] mb-1">
          <FileText class="w-4 h-4" />
          <span>Vertical 03 • Serviços Notariais & Registrais</span>
        </div>
        <h1 class="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
          Cartório & Integração Registral (ONR)
        </h1>
        <p class="text-xs sm:text-sm text-slate-300 mt-1 max-w-2xl leading-relaxed">
          Emissão eletrônica de matrículas, certidões vintenárias sem hiatos e conexão oficial com o Operador Nacional do Registro de Imóveis.
        </p>
      </div>

      <div class="flex items-center gap-3">
        <button
          type="button"
          :disabled="loading"
          @click="fetchOrders"
          title="Atualizar Esteira"
          class="p-2.5 rounded-xl bg-[#0D2230] border border-white/10 hover:border-white/20 text-slate-300 hover:text-white transition cursor-pointer"
        >
          <RefreshCw :class="['w-4 h-4', loading ? 'animate-spin' : '']" />
        </button>

        <button
          type="button"
          :disabled="submitting"
          @click="solicitarMatricula"
          class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] text-white text-xs sm:text-sm font-bold shadow-md shadow-[#D96826]/20 hover:brightness-110 transition cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <Loader2 v-if="submitting" class="w-4 h-4 animate-spin" />
          <FileText v-else class="w-4 h-4" />
          <span>{{ submitting ? 'Enviando ao ONR...' : 'Solicitar Matrícula 24h' }}</span>
        </button>
      </div>
    </div>

    <!-- Banner de Feedback -->
    <div
      v-if="feedback"
      :class="[
        'p-4 rounded-xl border text-xs sm:text-sm flex items-center justify-between gap-3 transition',
        feedback.type === 'success'
          ? 'bg-emerald-500/10 border-emerald-500/30 text-emerald-200'
          : 'bg-rose-500/10 border-rose-500/30 text-rose-200'
      ]"
    >
      <div class="flex items-center gap-2.5">
        <CheckCircle2 v-if="feedback.type === 'success'" class="w-4 h-4 text-emerald-400 shrink-0" />
        <AlertCircle v-else class="w-4 h-4 text-rose-400 shrink-0" />
        <span>{{ feedback.message }}</span>
      </div>
      <button
        type="button"
        @click="feedback = null"
        class="text-xs opacity-70 hover:opacity-100 transition cursor-pointer"
      >
        ✕
      </button>
    </div>

    <!-- Cards de Métricas Registrais -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <div
        v-for="stat in cartorioStats"
        :key="stat.label"
        class="p-5 rounded-2xl bg-[#0D2230] border border-white/10 flex items-center justify-between shadow-lg"
      >
        <div>
          <p class="text-xs text-slate-400 font-medium">
            {{ stat.label }}
          </p>
          <p class="text-2xl font-black text-white mt-1">
            {{ stat.value }}
          </p>
          <p class="text-[11px] text-slate-400 mt-0.5">
            {{ stat.sub }}
          </p>
        </div>
        <div class="w-11 h-11 rounded-xl bg-[#00384A] border border-white/10 flex items-center justify-center text-[#F28C28]">
          <component :is="stat.icon" class="w-5 h-5" />
        </div>
      </div>
    </div>

    <!-- Tabela de Solicitações Notariais Recentes (Reativa) -->
    <div class="p-6 rounded-2xl bg-[#0D2230] border border-white/10 space-y-4 shadow-xl">
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h3 class="text-base font-bold text-white flex items-center gap-2">
            <span>Esteira de Pedidos de Certidões & Matrículas</span>
            <span
              v-if="loading"
              class="text-xs font-normal text-slate-400 inline-flex items-center gap-1"
            >
              <Loader2 class="w-3 h-3 animate-spin" /> Atualizando...
            </span>
          </h3>
          <p class="text-xs text-slate-400">
            Acompanhe o protocolo em tempo real junto aos Registros de Imóveis integrados ao ONR / SAEC.
          </p>
        </div>
        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-xs font-medium">
          <ShieldCheck class="w-3.5 h-3.5" />
          Conexão ONR Homologada
        </span>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs text-slate-300">
          <thead class="text-[11px] uppercase font-bold text-slate-400 bg-white/[0.03] border-b border-white/10">
            <tr>
              <th class="py-3 px-4">Matrícula / Protocolo</th>
              <th class="py-3 px-4">Ofício de Registro</th>
              <th class="py-3 px-4">Tipo de Certidão</th>
              <th class="py-3 px-4">Data Solicitação</th>
              <th class="py-3 px-4">Status ONR</th>
              <th class="py-3 px-4 text-right">Documento</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-white/5">
            <tr v-if="orders.length === 0" class="text-center">
              <td colspan="6" class="py-12 px-4 text-slate-400">
                <div class="flex flex-col items-center justify-center gap-2">
                  <FileText class="w-8 h-8 text-slate-500 opacity-50" />
                  <p class="font-medium text-slate-300">Nenhum pedido de certidão registrado ainda.</p>
                  <p class="text-xs text-slate-400 max-w-sm">
                    Clique em <strong>"Solicitar Matrícula 24h"</strong> para disparar a primeira solicitação integrada ao ONR.
                  </p>
                </div>
              </td>
            </tr>

            <tr v-for="item in orders" :key="item.id" class="hover:bg-white/[0.02] transition">
              <td class="py-3.5 px-4 font-mono font-bold text-white">
                <p>#{{ item.matricula }}</p>
                <p class="text-[10px] text-slate-400 font-mono">
                  {{ item.protocolo_onr ? 'Prot: ' + item.protocolo_onr : 'Aguardando protocolo' }}
                </p>
              </td>
              <td class="py-3.5 px-4 font-medium text-slate-200">
                <p>{{ item.rgi }}</p>
                <p v-if="item.cartorio_cns" class="text-[10px] text-slate-400">CNS: {{ item.cartorio_cns }}</p>
              </td>
              <td class="py-3.5 px-4 text-slate-300">
                {{ item.tipo_certidao?.replace(/_/g, ' ') }}
              </td>
              <td class="py-3.5 px-4 text-slate-300 font-mono">
                {{ formatDate(item.requested_at || item.created_at) }}
              </td>
              <td class="py-3.5 px-4">
                <span
                  :class="[
                    'px-2.5 py-1 rounded-full text-[11px] font-bold uppercase tracking-wider inline-flex items-center gap-1.5',
                    item.status === 'concluido'
                      ? 'bg-emerald-500/15 text-emerald-300 border border-emerald-500/30'
                      : item.status === 'erro'
                        ? 'bg-rose-500/15 text-rose-300 border border-rose-500/30'
                        : 'bg-[#D96826]/15 text-[#F28C28] border border-[#D96826]/30'
                  ]"
                >
                  <CheckCircle2 v-if="item.status === 'concluido'" class="w-3 h-3" />
                  <AlertCircle v-else-if="item.status === 'erro'" class="w-3 h-3" />
                  <Clock v-else class="w-3 h-3 animate-pulse" />
                  {{ item.status }}
                </span>
              </td>
              <td class="py-3.5 px-4 text-right">
                <button
                  v-if="item.status === 'concluido' && item.documento_path"
                  type="button"
                  @click="baixarDocumento(item)"
                  class="inline-flex items-center gap-1 text-xs font-semibold text-[#F28C28] hover:text-[#d96826] hover:underline cursor-pointer transition"
                >
                  <span>Visualizar PDF</span>
                  <ArrowUpRight class="w-3.5 h-3.5" />
                </button>
                <span
                  v-else-if="item.status === 'erro'"
                  class="text-xs text-rose-400"
                  :title="item.error_message || 'Falha no processamento'"
                >
                  Falha
                </span>
                <span v-else class="text-xs text-slate-400 italic">
                  Processando...
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
