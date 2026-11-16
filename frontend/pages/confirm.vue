<script setup lang="ts">
import { ShieldCheck, AlertCircle, ArrowLeft } from 'lucide-vue-next'

definePageMeta({
  middleware: ['auth'],
  layout: false
})

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const session = useSupabaseSession()
const route = useRoute()

const errorMessage = ref('')
const statusMessage = ref('Validando token OAuth e sincronizando credenciais de governança...')
let isRedirecting = false

async function redirectAuthenticatedUser(userId: string, userEmail?: string) {
  if (isRedirecting) return
  isRedirecting = true
  statusMessage.value = 'Sessão autenticada com sucesso! Redirecionando para o portal...'

  try {
    const { data: userProfile } = await supabase
      .from('user_profiles')
      .select('role')
      .eq('id', userId)
      .maybeSingle<{ role: string }>()

    const isAdmin =
      userProfile?.role === 'admin' ||
      userEmail === 'master@litcapital.com.br'

    await navigateTo(isAdmin ? '/admin/dashboard' : '/dashboard', { replace: true })
  } catch {
    await navigateTo('/dashboard', { replace: true })
  }
}

watch(
  user,
  async (currentUser) => {
    const userId = currentUser?.id || (currentUser as { sub?: string } | null)?.sub
    if (userId) {
      await redirectAuthenticatedUser(userId, currentUser?.email)
    }
  },
  { immediate: true }
)

onMounted(async () => {
  if (route.query.error_description || route.query.error) {
    errorMessage.value = String(
      route.query.error_description ||
        route.query.error ||
        'Não foi possível concluir a autenticação social.'
    )
    return
  }

  try {
    // Aguarda a inicialização do cliente Supabase (que processa automaticamente o ?code= PKCE na URL)
    const { data, error } = await supabase.auth.getSession()

    if (error) {
      errorMessage.value = error.message
      return
    }

    if (data?.session?.user) {
      if (!session.value) session.value = data.session
      if (!user.value) user.value = data.session.user
      await redirectAuthenticatedUser(data.session.user.id, data.session.user.email)
      return
    }

    // Fallback explícito caso o código PKCE ainda precise ser trocado manualmente
    const code = typeof route.query.code === 'string' ? route.query.code : null
    if (code) {
      const { data: exchangeData, error: exchangeError } =
        await supabase.auth.exchangeCodeForSession(code)

      if (exchangeError) {
        const { data: retryData } = await supabase.auth.getSession()
        if (retryData?.session?.user) {
          if (!session.value) session.value = retryData.session
          if (!user.value) user.value = retryData.session.user
          await redirectAuthenticatedUser(retryData.session.user.id, retryData.session.user.email)
          return
        }
        errorMessage.value = exchangeError.message
        return
      }

      if (exchangeData?.session?.user) {
        session.value = exchangeData.session
        user.value = exchangeData.session.user
        await redirectAuthenticatedUser(
          exchangeData.session.user.id,
          exchangeData.session.user.email
        )
        return
      }
    }

    // Se acessar /confirm sem código e sem sessão ativa, retorna ao login após aguardar eventos pendentes
    setTimeout(async () => {
      if (!isRedirecting && !user.value && !errorMessage.value) {
        await navigateTo('/login', { replace: true })
      }
    }, 4000)
  } catch (err: any) {
    errorMessage.value = err?.message || 'Erro inesperado ao validar sessão corporativa.'
  }
})
</script>

<template>
  <div class="min-h-screen flex flex-col items-center justify-center bg-[#07161F] text-slate-100 px-6 relative overflow-hidden">
    <div class="absolute top-0 left-0 right-0 h-0.5 bg-gradient-to-r from-[#D96826] via-[#F28C28] to-[#D96826]" />
    <div class="absolute -bottom-32 -left-32 w-96 h-96 rounded-full bg-[#D96826]/10 blur-3xl pointer-events-none" />
    <div class="absolute top-1/4 right-0 w-80 h-80 rounded-full bg-[#005A78]/20 blur-3xl pointer-events-none" />

    <div class="relative z-10 w-full max-w-md p-8 rounded-2xl bg-[#0D2230]/90 border border-white/10 shadow-2xl backdrop-blur-xl text-center space-y-6">
      <div class="flex justify-center">
        <BrandLockup size="lg" to="/" />
      </div>

      <div v-if="!errorMessage" class="space-y-4 py-4">
        <div class="relative w-14 h-14 mx-auto flex items-center justify-center">
          <div class="absolute inset-0 rounded-full border-2 border-[#D96826]/20" />
          <div class="absolute inset-0 rounded-full border-2 border-[#F28C28] border-t-transparent animate-spin" />
          <ShieldCheck class="w-6 h-6 text-[#F28C28]" />
        </div>

        <div class="space-y-1.5">
          <h1 class="text-lg font-bold text-white">
            Autenticando Credencial Corporativa
          </h1>
          <p class="text-xs text-slate-400 leading-relaxed">
            {{ statusMessage }}
          </p>
        </div>
      </div>

      <div v-else class="space-y-5 py-2">
        <div class="flex items-start gap-3 p-4 rounded-xl bg-red-500/10 border border-red-500/30 text-red-200 text-xs text-left">
          <AlertCircle class="w-5 h-5 text-red-400 shrink-0 mt-0.5" />
          <div class="space-y-1">
            <p class="font-semibold text-red-300">Falha na Autenticação Social</p>
            <p>{{ errorMessage }}</p>
          </div>
        </div>

        <NuxtLink
          to="/login"
          class="w-full inline-flex items-center justify-center gap-2 py-3 px-4 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] text-white font-semibold text-xs shadow-lg transition hover:opacity-95"
        >
          <ArrowLeft class="w-4 h-4" />
          <span>Voltar para o Login</span>
        </NuxtLink>
      </div>

      <div class="pt-4 border-t border-white/10 flex items-center justify-center gap-2 text-[11px] text-slate-400">
        <span>Ambiente Criptografado • LIT Capital®</span>
      </div>
    </div>
  </div>
</template>
