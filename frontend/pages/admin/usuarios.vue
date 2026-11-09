<script setup lang="ts">
import {
  Users,
  ShieldCheck,
  Save,
  RefreshCw,
  CheckCircle2,
  AlertCircle,
  Search
} from 'lucide-vue-next'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const supabase = useSupabaseClient()

type UserRole = 'admin' | 'b2b_partner' | 'broker' | 'customer'

interface UserProfileItem {
  id: string
  email: string | null
  full_name: string
  role: UserRole
  company_name: string | null
  created_at: string | null
  updated_at: string | null
}

const usersList = ref<UserProfileItem[]>([])
const selectedRoles = reactive<Record<string, UserRole>>({})
const savingUserId = ref<string | null>(null)
const loading = ref(false)
const searchQuery = ref('')
const feedbackMessage = ref<{ type: 'success' | 'error'; text: string } | null>(null)

const roleOptions: Array<{ value: UserRole; label: string }> = [
  { value: 'admin', label: 'Admin Master' },
  { value: 'b2b_partner', label: 'Parceiro B2B' },
  { value: 'broker', label: 'Corretor' },
  { value: 'customer', label: 'Usuário / Proprietário PF' }
]

function formatRoleName(role: UserRole | string): string {
  const found = roleOptions.find((r) => r.value === role)
  return found ? found.label : role
}

async function fetchUsers() {
  loading.value = true
  try {
    const { data, error } = await supabase
      .from('user_profiles')
      .select('id, email, full_name, role, company_name, created_at, updated_at')
      .order('created_at', { ascending: false })

    if (error) {
      feedbackMessage.value = {
        type: 'error',
        text: `Erro ao carregar perfis: ${error.message}`
      }
      return
    }

    if (data) {
      usersList.value = data as UserProfileItem[]
      for (const row of usersList.value) {
        selectedRoles[row.id] = row.role
      }
    }
  } finally {
    loading.value = false
  }
}

async function handleSaveRole(userRow: UserProfileItem) {
  const newRole = selectedRoles[userRow.id]
  if (!newRole) return

  feedbackMessage.value = null
  savingUserId.value = userRow.id

  try {
    const { error } = await supabase.rpc('admin_change_user_role', {
      target_user_id: userRow.id,
      new_role: newRole
    })

    if (error) {
      feedbackMessage.value = {
        type: 'error',
        text: `Falha ao alterar perfil de "${userRow.full_name}": ${error.message}`
      }
      return
    }

    feedbackMessage.value = {
      type: 'success',
      text: `Perfil de "${userRow.full_name}" atualizado com sucesso para "${formatRoleName(newRole)}".`
    }

    await fetchUsers()
  } catch (err: any) {
    feedbackMessage.value = {
      type: 'error',
      text: err?.message || 'Erro inesperado ao atualizar o perfil do usuário.'
    }
  } finally {
    savingUserId.value = null
  }
}

const filteredUsers = computed(() => {
  const q = searchQuery.value.trim().toLowerCase()
  if (!q) return usersList.value
  return usersList.value.filter(
    (u) =>
      u.full_name?.toLowerCase().includes(q) ||
      u.email?.toLowerCase().includes(q) ||
      u.role?.toLowerCase().includes(q)
  )
})

onMounted(() => {
  fetchUsers()
})
</script>

<template>
  <div class="space-y-8">
    <!-- Cabeçalho Corporativo -->
    <section class="rounded-2xl bg-gradient-to-r from-[#00384A] via-[#002936] to-[#0D2230] border border-[#D96826]/40 p-6 sm:p-8 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4 shadow-xl">
      <div class="space-y-1.5">
        <div class="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#F28C28]">
          <ShieldCheck class="w-4 h-4" />
          <span>Super Admin • Governança de Identidade & RBAC</span>
        </div>
        <h2 class="text-2xl font-extrabold text-white">
          Gestão de Acessos e Governança
        </h2>
        <p class="text-xs text-slate-300 max-w-2xl">
          Administre os níveis de credencial da plataforma. A elevação de perfil (ex: promover a Admin Master) concede acesso irrestrito ao ecossistema de moderação e configuração corporativa.
        </p>
      </div>

      <button
        type="button"
        @click="fetchUsers"
        class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white/10 hover:bg-white/15 border border-white/15 text-xs font-semibold text-white transition cursor-pointer shrink-0"
      >
        <RefreshCw :class="['w-4 h-4', loading ? 'animate-spin' : '']" />
        <span>Recarregar Usuários</span>
      </button>
    </section>

    <!-- Banner de Feedback da RPC -->
    <div
      v-if="feedbackMessage"
      :class="[
        'flex items-start gap-3 p-4 rounded-xl border text-sm',
        feedbackMessage.type === 'success'
          ? 'bg-emerald-500/10 border-emerald-500/30 text-emerald-200'
          : 'bg-red-500/10 border-red-500/30 text-red-200'
      ]"
    >
      <CheckCircle2
        v-if="feedbackMessage.type === 'success'"
        class="w-5 h-5 text-emerald-400 shrink-0 mt-0.5"
      />
      <AlertCircle v-else class="w-5 h-5 text-red-400 shrink-0 mt-0.5" />
      <span>{{ feedbackMessage.text }}</span>
    </div>

    <!-- Barra de Filtro -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div class="relative max-w-md w-full">
        <Search class="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Filtrar por nome, e-mail ou role..."
          class="w-full pl-10 pr-4 py-2.5 rounded-xl bg-[#0D2230] border border-white/10 text-xs sm:text-sm text-white placeholder-slate-500 focus:outline-none focus:border-[#D96826]"
        />
      </div>

      <span class="text-xs text-slate-400">
        Total listado: <strong class="text-white">{{ filteredUsers.length }}</strong> usuário(s)
      </span>
    </div>

    <!-- Tabela Corporativa de Usuários -->
    <div class="rounded-2xl bg-[#0D2230] border border-white/10 overflow-hidden shadow-lg">
      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="bg-[#002936] border-b border-white/10 text-[11px] font-bold uppercase tracking-wider text-slate-300">
              <th class="py-4 px-6">Nome / Identificação</th>
              <th class="py-4 px-6">E-mail</th>
              <th class="py-4 px-6">Perfil Atual</th>
              <th class="py-4 px-6">Novo Nível de Acesso</th>
              <th class="py-4 px-6 text-right">Ação</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-white/10 text-sm">
            <tr
              v-for="u in filteredUsers"
              :key="u.id"
              class="hover:bg-white/[0.02] transition"
            >
              <td class="py-4 px-6">
                <p class="font-bold text-white">{{ u.full_name }}</p>
                <p class="text-[11px] font-mono text-slate-400">
                  ID: {{ u.id.slice(0, 12) }}...
                  <span v-if="u.company_name" class="text-[#F28C28]"> • {{ u.company_name }}</span>
                </p>
              </td>

              <td class="py-4 px-6 text-slate-300">
                {{ u.email || 'Sincronizado via Auth' }}
              </td>

              <td class="py-4 px-6">
                <span
                  :class="[
                    'inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold',
                    u.role === 'admin'
                      ? 'bg-[#D96826]/20 text-[#F28C28] border border-[#D96826]/40'
                      : 'bg-white/[0.06] text-slate-200 border border-white/10'
                  ]"
                >
                  {{ formatRoleName(u.role) }}
                </span>
              </td>

              <td class="py-4 px-6">
                <select
                  v-model="selectedRoles[u.id]"
                  class="w-full min-w-[230px] px-3 py-2 rounded-xl bg-[#07161F] border border-white/15 text-xs text-white focus:outline-none focus:border-[#D96826]"
                >
                  <option
                    v-for="opt in roleOptions"
                    :key="opt.value"
                    :value="opt.value"
                    class="bg-[#07161F] text-white"
                  >
                    {{ opt.label }}
                  </option>
                </select>
              </td>

              <td class="py-4 px-6 text-right">
                <button
                  type="button"
                  :disabled="savingUserId === u.id || selectedRoles[u.id] === u.role"
                  @click="handleSaveRole(u)"
                  class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-[#D96826] hover:bg-[#c35a1d] disabled:opacity-40 text-white text-xs font-semibold transition cursor-pointer"
                >
                  <Save class="w-3.5 h-3.5" />
                  <span>
                    {{ savingUserId === u.id ? 'Salvando...' : 'Salvar Perfil' }}
                  </span>
                </button>
              </td>
            </tr>

            <tr v-if="filteredUsers.length === 0 && !loading">
              <td colspan="5" class="py-10 text-center text-xs text-slate-400">
                Nenhum usuário encontrado para a busca informada.
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
