<script setup lang="ts">
import { Building2, Lock, Mail, ArrowRight, ShieldCheck, AlertCircle } from 'lucide-vue-next'

definePageMeta({
  middleware: ['auth'],
  layout: false
})

const supabase = useSupabaseClient()

const email = ref('')
const password = ref('')
const loading = ref(false)
const errorMessage = ref('')

async function handleLogin() {
  errorMessage.value = ''
  loading.value = true

  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email: email.value.trim(),
      password: password.value
    })

    if (error) {
      errorMessage.value =
        error.message === 'Invalid login credentials'
          ? 'Credenciais inválidas. Verifique seu e-mail corporativo e senha.'
          : error.message
      return
    }

    if (data.session) {
      await navigateTo('/dashboard')
    }
  } catch (err: any) {
    errorMessage.value = err?.message || 'Erro inesperado ao autenticar na plataforma ImobiLit.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen grid lg:grid-cols-12 bg-[#07161F] text-slate-100">
    <!-- Painel Institucional Esquerdo (LIT Capital Branding) -->
    <div class="hidden lg:flex lg:col-span-7 relative flex-col justify-between p-12 bg-gradient-to-br from-[#00384A] via-[#002936] to-[#07161F] border-r border-white/10 overflow-hidden">
      <!-- Faixa Superior Laranja Institucional LIT Capital -->
      <div class="absolute top-0 left-0 right-0 h-2 bg-gradient-to-r from-[#D96826] via-[#F28C28] to-[#D96826]" />

      <!-- Efeito de Luz de Fundo -->
      <div class="absolute -bottom-32 -left-32 w-96 h-96 rounded-full bg-[#D96826]/10 blur-3xl pointer-events-none" />
      <div class="absolute top-1/4 right-0 w-80 h-80 rounded-full bg-[#005A78]/20 blur-3xl pointer-events-none" />

      <!-- Topo: Identidade ImobiLit + LIT Capital -->
      <div class="relative z-10 flex items-center justify-between">
        <div class="flex items-center gap-4">
          <div class="bg-white px-4 py-2 rounded-lg shadow-md flex items-center">
            <img
              src="/images/lit-capital-logo.png"
              alt="LIT Capital"
              class="h-8 w-auto object-contain"
            />
          </div>
          <div class="h-8 w-[1px] bg-white/20" />
          <div>
            <span class="text-2xl font-extrabold tracking-tight text-white">
              Imobi<span class="text-[#F28C28]">Lit</span>
            </span>
            <p class="text-[11px] uppercase tracking-widest text-slate-300 font-medium">
              Multi-Service Asset Platform
            </p>
          </div>
        </div>
      </div>

      <!-- Conteúdo Central: Proposta de Valor Multi-Serviços -->
      <div class="relative z-10 max-w-xl my-auto space-y-6">
        <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#D96826]/15 border border-[#D96826]/40 text-[#F28C28] text-xs font-semibold tracking-wide uppercase">
          <ShieldCheck class="w-4 h-4" />
          Ecossistema Integrado LIT Capital
        </div>

        <h1 class="text-4xl font-bold tracking-tight text-white leading-tight">
          Gestão Inteligente de Ativos Imobiliários, Agro/ESG, Cartório e Capital.
        </h1>

        <p class="text-slate-300 text-base leading-relaxed">
          A plataforma <strong class="text-white">ImobiLit</strong> conecta originação, inteligência geográfica, regularização registral e estruturação financeira em um único ambiente institucional.
        </p>

        <div class="grid grid-cols-2 gap-4 pt-4">
          <div class="p-4 rounded-xl bg-white/[0.04] border border-white/10">
            <p class="text-xs font-semibold uppercase tracking-wider text-[#F28C28]">Ativos Urbanos & Agro</p>
            <p class="text-sm text-slate-300 mt-1">Monitoramento geoespacial, CAR, reserva legal e lançamentos.</p>
          </div>
          <div class="p-4 rounded-xl bg-white/[0.04] border border-white/10">
            <p class="text-xs font-semibold uppercase tracking-wider text-[#F28C28]">Cartório & Funding</p>
            <p class="text-sm text-slate-300 mt-1">Due diligence de matrículas RGI e viabilidade de crédito estruturado.</p>
          </div>
        </div>
      </div>

      <!-- Rodapé Institucional -->
      <div class="relative z-10 flex items-center justify-between text-xs text-slate-400 border-t border-white/10 pt-6">
        <span>© {{ new Date().getFullYear() }} LIT Capital® — Todos os direitos reservados.</span>
        <span>Ambiente Criptografado • RLS Ativo</span>
      </div>
    </div>

    <!-- Painel Direito: Formulário Corporativo de Login -->
    <div class="lg:col-span-5 flex flex-col justify-center px-6 py-12 sm:px-12 xl:px-16 bg-[#07161F]">
      <div class="w-full max-w-md mx-auto space-y-8">
        <!-- Cabeçalho Mobile / Identidade -->
        <div class="space-y-3">
          <div class="flex items-center gap-3">
            <div class="bg-white px-3 py-1.5 rounded-md shadow-sm inline-flex items-center">
              <img
                src="/images/lit-capital-logo.png"
                alt="LIT Capital"
                class="h-6 w-auto object-contain"
              />
            </div>
            <span class="text-xl font-bold text-white tracking-tight">
              Imobi<span class="text-[#F28C28]">Lit</span>
            </span>
          </div>

          <h2 class="text-2xl font-bold tracking-tight text-white pt-2">
            Acesso ao Portal Institucional
          </h2>
          <p class="text-sm text-slate-400">
            Insira suas credenciais para acessar o terminal Multi-Serviços da LIT Capital.
          </p>
        </div>

        <!-- Alerta de Erro -->
        <div
          v-if="errorMessage"
          class="flex items-start gap-3 p-4 rounded-xl bg-red-500/10 border border-red-500/30 text-red-200 text-sm"
        >
          <AlertCircle class="w-5 h-5 text-red-400 shrink-0 mt-0.5" />
          <span>{{ errorMessage }}</span>
        </div>

        <!-- Formulário de Login -->
        <form class="space-y-5" @submit.prevent="handleLogin">
          <div class="space-y-1.5">
            <label for="email" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              E-mail Corporativo ou Pessoal
            </label>
            <div class="relative">
              <Mail class="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
              <input
                id="email"
                v-model="email"
                type="email"
                required
                autocomplete="email"
                placeholder="nome@litcapital.com.br"
                class="w-full pl-10 pr-4 py-3 rounded-xl bg-[#0D2230] border border-white/10 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-[#D96826] focus:ring-1 focus:ring-[#D96826] transition"
              />
            </div>
          </div>

          <div class="space-y-1.5">
            <div class="flex items-center justify-between">
              <label for="password" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
                Senha de Acesso
              </label>
            </div>
            <div class="relative">
              <Lock class="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
              <input
                id="password"
                v-model="password"
                type="password"
                required
                autocomplete="current-password"
                placeholder="••••••••"
                class="w-full pl-10 pr-4 py-3 rounded-xl bg-[#0D2230] border border-white/10 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-[#D96826] focus:ring-1 focus:ring-[#D96826] transition"
              />
            </div>
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full flex items-center justify-center gap-2 py-3.5 px-5 rounded-xl bg-[#D96826] hover:bg-[#c35a1d] disabled:opacity-60 text-white font-semibold text-sm shadow-lg shadow-[#D96826]/20 transition cursor-pointer"
          >
            <span v-if="!loading">Acessar Plataforma ImobiLit</span>
            <span v-else>Autenticando sessão segura...</span>
            <ArrowRight v-if="!loading" class="w-4 h-4" />
          </button>
        </form>

        <!-- Link para Cadastro -->
        <div class="pt-6 border-t border-white/10 text-center">
          <p class="text-sm text-slate-400">
            Ainda não possui credencial na plataforma?
            <NuxtLink
              to="/cadastro"
              class="font-semibold text-[#F28C28] hover:text-[#D96826] underline-offset-4 hover:underline ml-1"
            >
              Solicitar Credenciamento (B2C / B2B)
            </NuxtLink>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>
