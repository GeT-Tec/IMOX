<script setup lang="ts">
import { Lock, Mail, ArrowRight, ShieldCheck, AlertCircle, Globe } from 'lucide-vue-next'

definePageMeta({
  middleware: ['auth'],
  layout: false
})

const supabase = useSupabaseClient()

const email = ref('')
const password = ref('')
const loading = ref(false)
const oauthLoading = ref<'google' | 'linkedin_oidc' | null>(null)
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
          ? 'Credenciais inválidas. Verifique seu e-mail e senha.'
          : error.message
      return
    }

    if (data.session) {
      const isMaster =
        data.user?.email === 'master@litcapital.com.br' ||
        data.user?.user_metadata?.role === 'admin'
      await navigateTo(isMaster ? '/admin/dashboard' : '/dashboard')
    }
  } catch (err: any) {
    errorMessage.value = err?.message || 'Erro inesperado ao autenticar na plataforma ImobiLit.'
  } finally {
    loading.value = false
  }
}

async function handleOAuthLogin(provider: 'google' | 'linkedin_oidc') {
  errorMessage.value = ''
  oauthLoading.value = provider

  try {
    const redirectTo =
      typeof window !== 'undefined' ? `${window.location.origin}/dashboard` : undefined

    const { error } = await supabase.auth.signInWithOAuth({
      provider,
      options: {
        redirectTo
      }
    })

    if (error) {
      errorMessage.value = error.message
    }
  } catch (err: any) {
    errorMessage.value =
      err?.message || `Não foi possível iniciar a autenticação social (${provider}).`
  } finally {
    oauthLoading.value = null
  }
}
</script>

<template>
  <div class="min-h-screen grid lg:grid-cols-12 bg-[#07161F] text-slate-100">
    <!-- Painel Institucional Esquerdo (LIT Capital Branding) -->
    <div class="hidden lg:flex lg:col-span-7 relative flex-col justify-between p-12 bg-gradient-to-br from-[#00384A] via-[#002936] to-[#07161F] border-r border-white/10 overflow-hidden">
      <div class="absolute top-0 left-0 right-0 h-0.5 bg-gradient-to-r from-[#D96826] via-[#F28C28] to-[#D96826]" />
      <div class="absolute -bottom-32 -left-32 w-96 h-96 rounded-full bg-[#D96826]/10 blur-3xl pointer-events-none" />
      <div class="absolute top-1/4 right-0 w-80 h-80 rounded-full bg-[#005A78]/20 blur-3xl pointer-events-none" />

      <div class="relative z-10 flex items-center justify-between">
        <BrandLockup size="lg" to="/" />

        <NuxtLink
          to="/"
          class="inline-flex items-center gap-2 px-3.5 py-2 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-xs font-semibold text-slate-200 transition"
        >
          <Globe class="w-4 h-4 text-[#F28C28]" />
          <span>Ver Vitrine Pública</span>
        </NuxtLink>
      </div>

      <div class="relative z-10 max-w-xl my-auto space-y-6">
        <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#D96826]/15 border border-[#D96826]/40 text-[#F28C28] text-xs font-semibold tracking-wide uppercase">
          <ShieldCheck class="w-4 h-4" />
          Ecossistema Integrado LIT Capital • RBAC 4 Níveis
        </div>

        <h1 class="text-4xl font-bold tracking-tight text-white leading-tight">
          Vitrine Pública Marketplace & Governança Institucional de Ativos.
        </h1>

        <p class="text-slate-300 text-base leading-relaxed">
          A plataforma <strong class="text-white">ImobiLit</strong> conecta investidores, anunciantes pessoa física, corretores autônomos, imobiliárias parceiras B2B e a curadoria Master da <strong class="text-white">LIT Capital</strong>.
        </p>

        <div class="grid grid-cols-2 gap-4 pt-4">
          <div class="p-4 rounded-xl bg-white/[0.04] border border-white/10">
            <p class="text-xs font-semibold uppercase tracking-wider text-[#F28C28]">Trava de Compliance</p>
            <p class="text-sm text-slate-300 mt-1">Anúncios publicados passam por aprovação antes de irem à vitrine pública.</p>
          </div>
          <div class="p-4 rounded-xl bg-white/[0.04] border border-white/10">
            <p class="text-xs font-semibold uppercase tracking-wider text-[#F28C28]">Multi-Serviços</p>
            <p class="text-sm text-slate-300 mt-1">Urbano, Agro/ESG, Cartório/RGI e Estruturação de Financiamento.</p>
          </div>
        </div>
      </div>

      <div class="relative z-10 flex items-center justify-between text-xs text-slate-400 border-t border-white/10 pt-6">
        <span>© {{ new Date().getFullYear() }} LIT Capital® — Todos os direitos reservados.</span>
        <span>Ambiente Criptografado • RLS Ativo</span>
      </div>
    </div>

    <!-- Painel Direito: Formulário Corporativo de Login -->
    <div class="lg:col-span-5 flex flex-col justify-center px-6 py-12 sm:px-12 xl:px-16 bg-[#07161F]">
      <div class="w-full max-w-md mx-auto space-y-6">
        <div class="space-y-3">
          <div class="lg:hidden flex items-center justify-between pb-3 border-b border-white/10">
            <BrandLockup size="md" to="/" />

            <NuxtLink
              to="/"
              class="text-xs font-semibold text-[#F28C28] hover:underline"
            >
              ← Vitrine Pública
            </NuxtLink>
          </div>

          <h2 class="text-2xl font-bold tracking-tight text-white pt-2">
            Acesso ao Portal Institucional
          </h2>
          <p class="text-sm text-slate-400">
            Insira suas credenciais ou utilize seu provedor corporativo para acessar a ImobiLit.
          </p>
        </div>

        <div
          v-if="errorMessage"
          class="flex items-start gap-3 p-4 rounded-xl bg-red-500/10 border border-red-500/30 text-red-200 text-sm"
        >
          <AlertCircle class="w-5 h-5 text-red-400 shrink-0 mt-0.5" />
          <span>{{ errorMessage }}</span>
        </div>

        <!-- Botões de Social Login (Google & LinkedIn OIDC) -->
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <button
            type="button"
            :disabled="oauthLoading !== null || loading"
            @click="handleOAuthLogin('google')"
            class="flex items-center justify-center gap-2.5 py-3 px-4 rounded-xl bg-[#0D2230] hover:bg-[#132E40] border border-white/15 text-xs sm:text-sm font-semibold text-white transition cursor-pointer disabled:opacity-60"
          >
            <svg class="w-4 h-4 shrink-0" viewBox="0 0 24 24">
              <path
                fill="#EA4335"
                d="M12 5c1.6 0 3 .6 4.1 1.7l3.1-3.1C17.3 1.8 14.8 1 12 1 7.4 1 3.5 3.6 1.6 7.4l3.7 2.8C6.2 7.2 8.9 5 12 5z"
              />
              <path
                fill="#4285F4"
                d="M23.5 12.3c0-.8-.1-1.6-.2-2.3H12v4.5h6.5c-.3 1.5-1.1 2.8-2.4 3.6l3.7 2.9c2.2-2 3.7-5 3.7-8.7z"
              />
              <path
                fill="#FBBC05"
                d="M5.3 14.8c-.2-.8-.4-1.8-.4-2.8s.2-2 .4-2.8L1.6 6.4C.6 8.4 0 10.6 0 12s.6 3.6 1.6 5.6l3.7-2.8z"
              />
              <path
                fill="#34A853"
                d="M12 23c3.2 0 6-1.1 8-3l-3.7-2.9c-1.1.7-2.5 1.2-4.3 1.2-3.1 0-5.8-2.1-6.7-5l-3.7 2.8C3.5 19.9 7.4 23 12 23z"
              />
            </svg>
            <span>{{ oauthLoading === 'google' ? 'Conectando...' : 'Entrar com Google' }}</span>
          </button>

          <button
            type="button"
            :disabled="oauthLoading !== null || loading"
            @click="handleOAuthLogin('linkedin_oidc')"
            class="flex items-center justify-center gap-2.5 py-3 px-4 rounded-xl bg-[#0D2230] hover:bg-[#132E40] border border-white/15 text-xs sm:text-sm font-semibold text-white transition cursor-pointer disabled:opacity-60"
          >
            <svg class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="#0A66C2">
              <path
                d="M19 3a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h14m-.5 15.5v-5.3a3.26 3.26 0 0 0-3.26-3.26c-.85 0-1.84.52-2.28 1.3v-1.11h-2.79v8.37h2.79v-4.93c0-.77.62-1.4 1.39-1.4a1.4 1.4 0 0 1 1.4 1.4v4.93h2.75M6.88 8.56a1.68 1.68 0 0 0 1.68-1.68c0-.93-.75-1.69-1.68-1.69a1.69 1.69 0 0 0-1.69 1.69c0 .93.76 1.68 1.69 1.68m1.39 9.94v-8.37H5.5v8.37h2.77z"
              />
            </svg>
            <span>{{ oauthLoading === 'linkedin_oidc' ? 'Conectando...' : 'Entrar com LinkedIn' }}</span>
          </button>
        </div>

        <!-- Separador Visual -->
        <div class="relative flex items-center py-1">
          <div class="flex-grow border-t border-white/10" />
          <span class="shrink-0 px-3 text-[11px] uppercase tracking-widest text-slate-400 font-semibold">
            ou continue com e-mail
          </span>
          <div class="flex-grow border-t border-white/10" />
        </div>

        <form class="space-y-5" @submit.prevent="handleLogin">
          <div class="space-y-1.5">
            <label for="email" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              E-mail de Acesso
            </label>
            <div class="relative">
              <Mail class="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
              <input
                id="email"
                v-model="email"
                type="email"
                required
                autocomplete="email"
                placeholder="master@litcapital.com.br"
                class="w-full pl-10 pr-4 py-3 rounded-xl bg-[#0D2230] border border-white/10 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-[#D96826] focus:ring-1 focus:ring-[#D96826] transition"
              />
            </div>
          </div>

          <div class="space-y-1.5">
            <label for="password" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              Senha de Acesso
            </label>
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
            class="w-full flex items-center justify-center gap-2 py-3.5 px-5 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] hover:from-[#c35a1d] hover:to-[#e07b1d] disabled:opacity-60 text-white font-semibold text-sm shadow-[0_8px_20px_-6px_rgba(217,104,38,0.5)] transition-all cursor-pointer"
          >
            <span v-if="!loading">Acessar Plataforma ImobiLit</span>
            <span v-else>Autenticando sessão segura...</span>
            <ArrowRight v-if="!loading" class="w-4 h-4" />
          </button>
        </form>

        <div class="pt-5 border-t border-white/10 text-center">
          <p class="text-sm text-slate-400">
            Ainda não possui credencial na plataforma?
            <NuxtLink
              to="/cadastro"
              class="font-semibold text-[#F28C28] hover:text-[#D96826] underline-offset-4 hover:underline ml-1"
            >
              Criar Conta (Usuário, Corretor ou B2B)
            </NuxtLink>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>
