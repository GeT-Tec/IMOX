<script setup lang="ts">
import {
  UserCheck,
  Briefcase,
  Mail,
  Lock,
  User,
  Building2,
  ArrowRight,
  AlertCircle,
  CheckCircle2
} from 'lucide-vue-next'

definePageMeta({
  middleware: ['auth'],
  layout: false
})

const supabase = useSupabaseClient()

type AccessProfileType = 'B2C' | 'B2B'

const fullName = ref('')
const email = ref('')
const password = ref('')
const companyOrCreci = ref('')
const accessProfile = ref<AccessProfileType>('B2C')

const loading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

// Mapeia o seletor B2C / B2B para a coluna role (user_role_enum) da tabela public.user_profiles
const mappedDatabaseRole = computed(() => {
  return accessProfile.value === 'B2B' ? 'broker' : 'customer'
})

async function handleSignUp() {
  errorMessage.value = ''
  successMessage.value = ''
  loading.value = true

  try {
    const { data, error } = await supabase.auth.signUp({
      email: email.value.trim(),
      password: password.value,
      options: {
        data: {
          full_name: fullName.value.trim(),
          role: mappedDatabaseRole.value,
          access_profile: accessProfile.value,
          company_name: accessProfile.value === 'B2B' ? companyOrCreci.value.trim() : null
        }
      }
    })

    if (error) {
      errorMessage.value = error.message
      return
    }

    if (data.session) {
      await navigateTo('/dashboard')
      return
    }

    successMessage.value =
      'Cadastro registrado com sucesso na ImobiLit! Verifique seu e-mail caso a confirmação esteja ativa ou acesse a tela de login.'
  } catch (err: any) {
    errorMessage.value = err?.message || 'Não foi possível concluir o cadastro neste momento.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen grid lg:grid-cols-12 bg-[#07161F] text-slate-100">
    <!-- Painel Institucional Esquerdo -->
    <div class="hidden lg:flex lg:col-span-6 relative flex-col justify-between p-12 bg-gradient-to-br from-[#00384A] via-[#002936] to-[#07161F] border-r border-white/10 overflow-hidden">
      <div class="absolute top-0 left-0 right-0 h-2 bg-gradient-to-r from-[#D96826] via-[#F28C28] to-[#D96826]" />

      <div class="relative z-10 flex items-center gap-4">
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
            Credenciamento de Investidores & Parceiros
          </p>
        </div>
      </div>

      <div class="relative z-10 max-w-lg my-auto space-y-6">
        <h1 class="text-3xl font-bold tracking-tight text-white leading-snug">
          Uma conta única para operar todas as verticais de Ativos e Capital.
        </h1>
        <p class="text-slate-300 text-sm leading-relaxed">
          Selecione seu perfil operacional para configurar automaticamente suas permissões na base de dados da <strong class="text-white">LIT Capital</strong>:
        </p>

        <div class="space-y-3 pt-2">
          <div class="p-4 rounded-xl bg-white/[0.04] border border-white/10">
            <p class="text-xs font-bold uppercase tracking-wider text-[#F28C28]">
              1. Cliente / Investidor (B2C)
            </p>
            <p class="text-xs text-slate-300 mt-1">
              Acesso a portfólios imobiliários urbanos, ativos rurais/ESG, simulação de financiamento e acompanhamento jurídico de aquisições.
            </p>
          </div>
          <div class="p-4 rounded-xl bg-white/[0.04] border border-white/10">
            <p class="text-xs font-bold uppercase tracking-wider text-[#F28C28]">
              2. Parceiro / Corretor (B2B)
            </p>
            <p class="text-xs text-slate-300 mt-1">
              Originação de negócios, gestão de estoque, estruturação com construtoras, esteira de cartório (RGI) e originação de crédito.
            </p>
          </div>
        </div>
      </div>

      <div class="relative z-10 flex items-center justify-between text-xs text-slate-400 border-t border-white/10 pt-6">
        <span>© {{ new Date().getFullYear() }} LIT Capital®</span>
        <span>Provisionamento Automático via Supabase Auth Trigger</span>
      </div>
    </div>

    <!-- Painel Direito: Formulário de Cadastro -->
    <div class="lg:col-span-6 flex flex-col justify-center px-6 py-10 sm:px-12 xl:px-16 bg-[#07161F]">
      <div class="w-full max-w-lg mx-auto space-y-6">
        <div class="space-y-2">
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

          <h2 class="text-2xl font-bold tracking-tight text-white pt-1">
            Criar Conta Institucional
          </h2>
          <p class="text-sm text-slate-400">
            Preencha os dados abaixo e escolha seu perfil de acesso na plataforma.
          </p>
        </div>

        <!-- Feedback de Erro ou Sucesso -->
        <div
          v-if="errorMessage"
          class="flex items-start gap-3 p-4 rounded-xl bg-red-500/10 border border-red-500/30 text-red-200 text-sm"
        >
          <AlertCircle class="w-5 h-5 text-red-400 shrink-0 mt-0.5" />
          <span>{{ errorMessage }}</span>
        </div>

        <div
          v-if="successMessage"
          class="flex items-start gap-3 p-4 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-200 text-sm"
        >
          <CheckCircle2 class="w-5 h-5 text-emerald-400 shrink-0 mt-0.5" />
          <div>
            <p>{{ successMessage }}</p>
            <NuxtLink
              to="/login"
              class="inline-block mt-2 font-semibold text-[#F28C28] underline"
            >
              Ir para o Login agora →
            </NuxtLink>
          </div>
        </div>

        <form class="space-y-5" @submit.prevent="handleSignUp">
          <!-- Seletor de Perfil de Acesso (B2C vs B2B) -->
          <div class="space-y-2">
            <label class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              Perfil de Acesso
            </label>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <button
                type="button"
                @click="accessProfile = 'B2C'"
                :class="[
                  'flex items-start gap-3 p-3.5 rounded-xl border text-left transition cursor-pointer',
                  accessProfile === 'B2C'
                    ? 'bg-[#00384A]/80 border-[#D96826] ring-1 ring-[#D96826] text-white'
                    : 'bg-[#0D2230] border-white/10 text-slate-300 hover:border-white/25'
                ]"
              >
                <UserCheck
                  :class="[
                    'w-5 h-5 shrink-0 mt-0.5',
                    accessProfile === 'B2C' ? 'text-[#F28C28]' : 'text-slate-400'
                  ]"
                />
                <div>
                  <p class="text-sm font-semibold">Cliente / Investidor (B2C)</p>
                  <p class="text-[11px] text-slate-400 mt-0.5">
                    Alocação patrimonial, compra e financiamento
                  </p>
                </div>
              </button>

              <button
                type="button"
                @click="accessProfile = 'B2B'"
                :class="[
                  'flex items-start gap-3 p-3.5 rounded-xl border text-left transition cursor-pointer',
                  accessProfile === 'B2B'
                    ? 'bg-[#00384A]/80 border-[#D96826] ring-1 ring-[#D96826] text-white'
                    : 'bg-[#0D2230] border-white/10 text-slate-300 hover:border-white/25'
                ]"
              >
                <Briefcase
                  :class="[
                    'w-5 h-5 shrink-0 mt-0.5',
                    accessProfile === 'B2B' ? 'text-[#F28C28]' : 'text-slate-400'
                  ]"
                />
                <div>
                  <p class="text-sm font-semibold">Parceiro / Corretor (B2B)</p>
                  <p class="text-[11px] text-slate-400 mt-0.5">
                    Originação comercial, imobiliárias e assessoria
                  </p>
                </div>
              </button>
            </div>
          </div>

          <!-- Nome Completo -->
          <div class="space-y-1.5">
            <label for="fullName" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              Nome Completo / Representante Legal
            </label>
            <div class="relative">
              <User class="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
              <input
                id="fullName"
                v-model="fullName"
                type="text"
                required
                placeholder="Ex: Gustavo Lago"
                class="w-full pl-10 pr-4 py-3 rounded-xl bg-[#0D2230] border border-white/10 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-[#D96826] focus:ring-1 focus:ring-[#D96826] transition"
              />
            </div>
          </div>

          <!-- Campo Condicional B2B (Empresa / CRECI) -->
          <div v-if="accessProfile === 'B2B'" class="space-y-1.5">
            <label for="companyOrCreci" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              Razão Social / Escritório ou Registro CRECI
            </label>
            <div class="relative">
              <Building2 class="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
              <input
                id="companyOrCreci"
                v-model="companyOrCreci"
                type="text"
                placeholder="Ex: LIT Partner Advisory / CRECI-ES"
                class="w-full pl-10 pr-4 py-3 rounded-xl bg-[#0D2230] border border-white/10 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-[#D96826] focus:ring-1 focus:ring-[#D96826] transition"
              />
            </div>
          </div>

          <!-- E-mail -->
          <div class="space-y-1.5">
            <label for="email" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              E-mail
            </label>
            <div class="relative">
              <Mail class="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
              <input
                id="email"
                v-model="email"
                type="email"
                required
                autocomplete="email"
                placeholder="investidor@empresa.com.br"
                class="w-full pl-10 pr-4 py-3 rounded-xl bg-[#0D2230] border border-white/10 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-[#D96826] focus:ring-1 focus:ring-[#D96826] transition"
              />
            </div>
          </div>

          <!-- Senha -->
          <div class="space-y-1.5">
            <label for="password" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              Senha (mínimo 6 caracteres)
            </label>
            <div class="relative">
              <Lock class="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
              <input
                id="password"
                v-model="password"
                type="password"
                minlength="6"
                required
                autocomplete="new-password"
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
            <span v-if="!loading">
              Concluir Cadastro como {{ accessProfile === 'B2C' ? 'Cliente / Investidor' : 'Parceiro / Corretor' }}
            </span>
            <span v-else>Provisionando credencial no Supabase...</span>
            <ArrowRight v-if="!loading" class="w-4 h-4" />
          </button>
        </form>

        <div class="pt-5 border-t border-white/10 text-center">
          <p class="text-sm text-slate-400">
            Já possui uma conta ativa na ImobiLit?
            <NuxtLink
              to="/login"
              class="font-semibold text-[#F28C28] hover:text-[#D96826] underline-offset-4 hover:underline ml-1"
            >
              Entrar no Portal
            </NuxtLink>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>
