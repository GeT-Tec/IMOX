<script setup lang="ts">
import {
  Landmark,
  Calculator,
  ShieldCheck,
  TrendingUp,
  Percent,
  Clock,
  ArrowRight,
  CheckCircle2,
  DollarSign
} from 'lucide-vue-next'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const operationType = ref('home_equity')
const requestedAmount = ref(1500000)
const termMonths = ref(120)
const gracePeriodMonths = ref(6)

const calculatedMonthlyRate = computed(() => {
  if (operationType.value === 'home_equity') return 0.0099
  if (operationType.value === 'incorporacao') return 0.0115
  return 0.0105
})

const formattedRateText = computed(() => {
  return (calculatedMonthlyRate.value * 100).toFixed(2).replace('.', ',') + '% a.m. + IPCA'
})

const estimatedMonthlyPayment = computed(() => {
  const p = requestedAmount.value
  const i = calculatedMonthlyRate.value
  const n = termMonths.value
  if (n <= 0) return 0
  // Standard Price Table formula: PMT = P * (i * (1+i)^n) / ((1+i)^n - 1)
  const factor = Math.pow(1 + i, n)
  const pmt = p * (i * factor) / (factor - 1)
  return pmt
})

const formattedPayment = computed(() => {
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
    maximumFractionDigits: 0
  }).format(estimatedMonthlyPayment.value)
})

const formattedAmount = computed(() => {
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
    maximumFractionDigits: 0
  }).format(requestedAmount.value)
})

const simulationSuccess = ref(false)

function handleRequestFunding() {
  simulationSuccess.value = true
}
</script>

<template>
  <div class="space-y-8">
    <!-- Cabeçalho -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <div class="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#F28C28] mb-1">
          <Landmark class="w-4 h-4" />
          <span>Vertical 04 • Estruturação de Capital & Financiamento</span>
        </div>
        <h1 class="text-2xl font-bold text-white tracking-tight">Crédito & Funding Imobiliário</h1>
        <p class="text-xs sm:text-sm text-slate-400 mt-0.5">
          Simulador de crédito com garantia real, funding para incorporação e antecipação de recebíveis.
        </p>
      </div>

      <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/30 text-xs font-semibold text-emerald-300 shrink-0">
        <CheckCircle2 class="w-3.5 h-3.5" />
        <span>Mesa de Operações LIT Capital Ativa</span>
      </div>
    </div>

    <!-- Mini KPIs -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-5">
      <div class="p-5 rounded-2xl bg-[#0D2230] border border-white/10 space-y-2 shadow-lg">
        <div class="flex items-center justify-between text-slate-400 text-xs font-semibold uppercase">
          <span>Crédito Estruturado</span>
          <DollarSign class="w-4 h-4 text-[#F28C28]" />
        </div>
        <p class="text-3xl font-extrabold text-white">R$ 18,5M</p>
        <p class="text-[11px] text-slate-400">Volume aprovado em 2026</p>
      </div>

      <div class="p-5 rounded-2xl bg-[#0D2230] border border-white/10 space-y-2 shadow-lg">
        <div class="flex items-center justify-between text-slate-400 text-xs font-semibold uppercase">
          <span>Taxa Referencial</span>
          <Percent class="w-4 h-4 text-emerald-400" />
        </div>
        <p class="text-3xl font-extrabold text-white">0,99% a.m.</p>
        <p class="text-[11px] text-slate-400">+ IPCA anualizado</p>
      </div>

      <div class="p-5 rounded-2xl bg-[#0D2230] border border-white/10 space-y-2 shadow-lg">
        <div class="flex items-center justify-between text-slate-400 text-xs font-semibold uppercase">
          <span>Prazo Máximo</span>
          <Clock class="w-4 h-4 text-[#F28C28]" />
        </div>
        <p class="text-3xl font-extrabold text-white">240 Meses</p>
        <p class="text-[11px] text-slate-400">Amortização Tabela Price ou SAC</p>
      </div>
    </div>

    <!-- Simulador / Calculadora Interativa -->
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">
      <!-- Formulário de Parâmetros -->
      <div class="lg:col-span-7 rounded-2xl bg-[#0D2230] border border-white/10 p-6 sm:p-8 space-y-6 shadow-xl">
        <div class="flex items-center gap-2.5 pb-4 border-b border-white/10">
          <Calculator class="w-5 h-5 text-[#F28C28]" />
          <h2 class="text-lg font-bold text-white">Parâmetros da Operação</h2>
        </div>

        <div class="space-y-4">
          <!-- Tipo de Operação -->
          <div class="space-y-1.5">
            <label class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              Modalidade de Funding
            </label>
            <select
              v-model="operationType"
              class="w-full px-4 py-3 rounded-xl bg-[#07161F] border border-white/15 text-sm text-white focus:outline-none focus:border-[#D96826]"
            >
              <option value="home_equity">Home Equity (Crédito com Garantia Imobiliária)</option>
              <option value="incorporacao">Funding para Loteamentos & Incorporação</option>
              <option value="rural">Crédito Rural Estruturado (CPR / Safra)</option>
            </select>
          </div>

          <!-- Valor Solicitado (com slider interativo) -->
          <div class="space-y-2">
            <div class="flex items-center justify-between">
              <label class="text-xs font-semibold uppercase tracking-wider text-slate-300">
                Valor Solicitado
              </label>
              <span class="text-base font-extrabold text-[#F28C28]">
                {{ formattedAmount }}
              </span>
            </div>
            <input
              type="range"
              v-model.number="requestedAmount"
              min="200000"
              max="10000000"
              step="50000"
              class="w-full accent-[#D96826] cursor-pointer"
            />
            <div class="flex justify-between text-[11px] text-slate-400 font-mono">
              <span>R$ 200 mil</span>
              <span>R$ 5 milhões</span>
              <span>R$ 10 milhões</span>
            </div>
          </div>

          <!-- Prazo de Pagamento -->
          <div class="space-y-2 pt-2">
            <div class="flex items-center justify-between">
              <label class="text-xs font-semibold uppercase tracking-wider text-slate-300">
                Prazo de Amortização
              </label>
              <span class="text-sm font-bold text-white">
                {{ termMonths }} meses ({{ (termMonths / 12).toFixed(1) }} anos)
              </span>
            </div>
            <input
              type="range"
              v-model.number="termMonths"
              min="12"
              max="240"
              step="12"
              class="w-full accent-[#D96826] cursor-pointer"
            />
            <div class="flex justify-between text-[11px] text-slate-400 font-mono">
              <span>12 meses</span>
              <span>120 meses</span>
              <span>240 meses</span>
            </div>
          </div>

          <!-- Carência -->
          <div class="space-y-1.5 pt-2">
            <label class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              Carência para Início das Parcelas
            </label>
            <div class="grid grid-cols-4 gap-2">
              <button
                v-for="c in [0, 3, 6, 12]"
                :key="c"
                type="button"
                @click="gracePeriodMonths = c"
                :class="[
                  'py-2 px-3 rounded-xl border text-xs font-semibold transition cursor-pointer',
                  gracePeriodMonths === c
                    ? 'bg-[#00384A] border-[#D96826] text-[#F28C28]'
                    : 'bg-[#07161F] border-white/10 text-slate-300 hover:border-white/20'
                ]"
              >
                {{ c === 0 ? 'Sem carência' : `${c} meses` }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Resumo da Simulação (Lado Direito) -->
      <div class="lg:col-span-5 rounded-2xl bg-gradient-to-br from-[#00384A] via-[#002936] to-[#0D2230] border border-[#D96826]/40 p-6 sm:p-8 flex flex-col justify-between space-y-6 shadow-xl">
        <div class="space-y-4">
          <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#D96826]/20 border border-[#D96826]/40 text-[#F28C28] text-xs font-semibold">
            <TrendingUp class="w-3.5 h-3.5" />
            <span>Condição Pré-Aprovada LIT Capital</span>
          </div>

          <div>
            <p class="text-xs text-slate-300 uppercase tracking-wider font-semibold">
              Parcela Estimada Inicial
            </p>
            <p class="text-3xl sm:text-4xl font-extrabold text-white mt-1">
              {{ formattedPayment }}
              <span class="text-sm font-normal text-slate-400">/mês</span>
            </p>
          </div>

          <div class="space-y-3 pt-3 border-t border-white/10 text-xs text-slate-300">
            <div class="flex justify-between">
              <span class="text-slate-400">Taxa Estimada:</span>
              <span class="font-bold text-white">{{ formattedRateText }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-400">LTV Máximo Permitido:</span>
              <span class="font-bold text-white">Até 60% do valor do ativo</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-400">Carência Selecionada:</span>
              <span class="font-bold text-white">{{ gracePeriodMonths }} meses</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-400">Tempo Médio de Liquidação:</span>
              <span class="font-bold text-emerald-400">15 a 21 dias úteis</span>
            </div>
          </div>
        </div>

        <div class="space-y-3 pt-4 border-t border-white/10">
          <div
            v-if="simulationSuccess"
            class="p-3.5 rounded-xl bg-emerald-500/15 border border-emerald-500/30 text-emerald-200 text-xs flex items-start gap-2"
          >
            <CheckCircle2 class="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
            <span>Simulação enviada com sucesso! Um especialista da mesa de crédito entrará em contato em breve.</span>
          </div>

          <button
            type="button"
            @click="handleRequestFunding"
            class="w-full flex items-center justify-center gap-2 py-3.5 px-5 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] hover:from-[#c35a1d] hover:to-[#e07b1d] text-white font-bold text-sm shadow-lg shadow-[#D96826]/25 transition cursor-pointer"
          >
            <span>Submeter Análise de Crédito</span>
            <ArrowRight class="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
