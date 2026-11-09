<script setup lang="ts">
import {
  User,
  UserCheck,
  BadgeCheck,
  Building2,
  Camera,
  Mail,
  Phone,
  FileText,
  Globe,
  Lock,
  CheckCircle2,
  Save,
  Sparkles,
  Clock,
  ArrowRight,
  ShieldCheck,
  Upload
} from 'lucide-vue-next'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const user = useSupabaseUser()
const supabase = useSupabaseClient()

type SimulationRole = 'customer' | 'broker' | 'b2b_partner'

// Seletor de Simulação para a Vitrine Viva (PoC)
const simulatedRole = ref<SimulationRole>('customer')

// 1. Dados Comuns
const avatarUrl = ref<string>('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80')
const fullName = ref('')
const whatsapp = ref('')

// 2. Dados Customer
const customerCpf = ref('')
const contactPreference = ref('whatsapp')

// 3. Dados Broker
const brokerCpf = ref('')
const creciNumber = ref('')
const brokerSpecialty = ref('alto_padrao')
const affiliatedAgency = ref('')

// 4. Dados B2B Partner
const cnpj = ref('')
const tradeName = ref('')
const creciJuridico = ref('')
const legalRepresentative = ref('')
const websiteUrl = ref('')

// Feedback de submissão
const saving = ref(false)
const saveSuccess = ref(false)

// Carregar dados existentes
onMounted(async () => {
  if (!user.value?.id) return

  fullName.value = (user.value.user_metadata?.full_name as string) || ''

  const { data } = await supabase
    .from('user_profiles')
    .select('role, full_name, company_name')
    .eq('id', user.value.id)
    .maybeSingle()

  if (data) {
    if (data.full_name) fullName.value = data.full_name
    if (data.company_name) {
      affiliatedAgency.value = data.company_name
      tradeName.value = data.company_name
    }
    if (data.role === 'broker' || data.role === 'b2b_partner' || data.role === 'customer') {
      simulatedRole.value = data.role as SimulationRole
    }
  }
})

// Simulação de upload de foto
function handleAvatarUpload(event: Event) {
  const target = event.target as HTMLInputElement
  if (target.files && target.files[0]) {
    const file = target.files[0]
    const reader = new FileReader()
    reader.onload = (e) => {
      if (e.target?.result) {
        avatarUrl.value = e.target.result as string
      }
    }
    reader.readAsDataURL(file)
  }
}

async function handleSaveProfile() {
  saving.value = true
  saveSuccess.value = false

  try {
    if (user.value?.id) {
      await supabase
        .from('user_profiles')
        .update({
          full_name: fullName.value,
          company_name: simulatedRole.value === 'b2b_partner' ? tradeName.value : (affiliatedAgency.value || null)
        })
        .eq('id', user.value.id)
    }

    saveSuccess.value = true
    setTimeout(() => {
      saveSuccess.value = false
    }, 4000)
  } catch (err) {
    console.error('Erro ao salvar:', err)
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div class="space-y-8 max-w-4xl mx-auto">
    <!-- Cabeçalho -->
    <div class="space-y-1.5">
      <div class="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#F28C28]">
        <Sparkles class="w-4 h-4" />
        <span>Ecossistema Multilateral • Onboarding Dinâmico</span>
      </div>
      <h1 class="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
        Meu Perfil & Credenciamento
      </h1>
      <p class="text-xs sm:text-sm text-slate-400">
        Preencha os dados cadastrais e documentação necessária para ativação da sua esteira na LIT Capital.
      </p>
    </div>

    <!-- Seletor de Simulação de Perfil (Vitrine Viva / Apresentação PoC) -->
    <section class="rounded-2xl bg-gradient-to-r from-[#00384A] via-[#002B3A] to-[#0D2230] border border-[#D96826]/40 p-5 sm:p-6 shadow-xl space-y-3.5">
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2">
        <div class="flex items-center gap-2">
          <ShieldCheck class="w-4 h-4 text-[#F28C28]" />
          <span class="text-xs font-bold uppercase tracking-wider text-white">
            Simulador de Perfil (Vitrine Viva PoC)
          </span>
        </div>
        <span class="text-[11px] text-slate-300">
          Alterne o perfil para testar a adaptação dinâmica dos campos
        </span>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
        <!-- 1. Customer -->
        <button
          type="button"
          @click="simulatedRole = 'customer'"
          :class="[
            'flex items-center gap-3 p-3.5 rounded-xl border text-left transition cursor-pointer',
            simulatedRole === 'customer'
              ? 'bg-[#002936] border-[#D96826] ring-1 ring-[#D96826] text-white shadow-md'
              : 'bg-[#07161F] border-slate-700/60 text-slate-400 hover:text-white hover:border-slate-600'
          ]"
        >
          <div :class="['w-9 h-9 rounded-lg flex items-center justify-center shrink-0', simulatedRole === 'customer' ? 'bg-[#D96826] text-white' : 'bg-white/5 text-slate-400']">
            <UserCheck class="w-4.5 h-4.5" />
          </div>
          <div class="min-w-0">
            <p class="text-xs font-bold leading-tight">Usuário / PF</p>
            <p class="text-[10px] text-slate-400 truncate mt-0.5">Proprietário / Comprador</p>
          </div>
        </button>

        <!-- 2. Broker -->
        <button
          type="button"
          @click="simulatedRole = 'broker'"
          :class="[
            'flex items-center gap-3 p-3.5 rounded-xl border text-left transition cursor-pointer',
            simulatedRole === 'broker'
              ? 'bg-[#002936] border-[#D96826] ring-1 ring-[#D96826] text-white shadow-md'
              : 'bg-[#07161F] border-slate-700/60 text-slate-400 hover:text-white hover:border-slate-600'
          ]"
        >
          <div :class="['w-9 h-9 rounded-lg flex items-center justify-center shrink-0', simulatedRole === 'broker' ? 'bg-[#D96826] text-white' : 'bg-white/5 text-slate-400']">
            <BadgeCheck class="w-4.5 h-4.5" />
          </div>
          <div class="min-w-0">
            <p class="text-xs font-bold leading-tight">Corretor</p>
            <p class="text-[10px] text-slate-400 truncate mt-0.5">Autônomo com CRECI</p>
          </div>
        </button>

        <!-- 3. B2B Partner -->
        <button
          type="button"
          @click="simulatedRole = 'b2b_partner'"
          :class="[
            'flex items-center gap-3 p-3.5 rounded-xl border text-left transition cursor-pointer',
            simulatedRole === 'b2b_partner'
              ? 'bg-[#002936] border-[#D96826] ring-1 ring-[#D96826] text-white shadow-md'
              : 'bg-[#07161F] border-slate-700/60 text-slate-400 hover:text-white hover:border-slate-600'
          ]"
        >
          <div :class="['w-9 h-9 rounded-lg flex items-center justify-center shrink-0', simulatedRole === 'b2b_partner' ? 'bg-[#D96826] text-white' : 'bg-white/5 text-slate-400']">
            <Building2 class="w-4.5 h-4.5" />
          </div>
          <div class="min-w-0">
            <p class="text-xs font-bold leading-tight">Parceiro B2B</p>
            <p class="text-[10px] text-slate-400 truncate mt-0.5">Imobiliária / Incorporadora</p>
          </div>
        </button>
      </div>
    </section>

    <!-- Formulário Dinâmico -->
    <form class="space-y-6" @submit.prevent="handleSaveProfile">
      <!-- 1. Bloco Comum (Para todos os perfis) -->
      <section class="rounded-2xl bg-[#0D2230] border border-white/10 p-6 sm:p-8 space-y-6 shadow-xl">
        <h2 class="text-base font-bold text-white flex items-center gap-2 pb-3 border-b border-white/10">
          <User class="w-4 h-4 text-[#F28C28]" />
          <span>Informações de Identificação (Comum)</span>
        </h2>

        <!-- Avatar / Foto com Upload -->
        <div class="flex flex-col sm:flex-row sm:items-center gap-5">
          <div class="relative group w-20 h-20 rounded-2xl overflow-hidden bg-[#07161F] border-2 border-[#D96826]/40 shrink-0 shadow-lg">
            <img
              :src="avatarUrl"
              alt="Foto do Perfil"
              class="w-full h-full object-cover"
            />
            <label
              for="avatarInput"
              class="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 flex flex-col items-center justify-center text-white cursor-pointer transition-opacity"
            >
              <Camera class="w-5 h-5 text-[#F28C28]" />
              <span class="text-[9px] font-semibold mt-1">Alterar</span>
            </label>
            <input
              id="avatarInput"
              type="file"
              accept="image/*"
              class="hidden"
              @change="handleAvatarUpload"
            />
          </div>

          <div class="space-y-1">
            <div class="flex items-center gap-2">
              <label
                for="avatarInput"
                class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-white/5 hover:bg-white/10 border border-slate-700 text-xs font-semibold text-white transition cursor-pointer"
              >
                <Upload class="w-3.5 h-3.5 text-[#F28C28]" />
                <span>Substituir Foto / Logo</span>
              </label>
            </div>
            <p class="text-[11px] text-slate-400">
              Formatos recomendados: JPG, PNG ou WEBP até 5MB.
            </p>
          </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-5 pt-2">
          <!-- Nome / Razão Social -->
          <div class="space-y-1.5">
            <label for="fullName" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              {{ simulatedRole === 'b2b_partner' ? 'Razão Social' : 'Nome Completo' }}
            </label>
            <input
              id="fullName"
              v-model="fullName"
              type="text"
              required
              :placeholder="simulatedRole === 'b2b_partner' ? 'Ex: LIT Gestão Patrimonial Ltda' : 'Ex: Gustavo Lago'"
              class="w-full px-4 py-3 rounded-xl bg-[#07161F] border border-slate-700 text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-[#D96826] focus:border-transparent transition"
            />
          </div>

          <!-- WhatsApp -->
          <div class="space-y-1.5">
            <label for="whatsapp" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              WhatsApp Corporativo / Pessoal
            </label>
            <div class="relative">
              <Phone class="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
              <input
                id="whatsapp"
                v-model="whatsapp"
                type="tel"
                placeholder="(27) 99999-8888"
                class="w-full pl-10 pr-4 py-3 rounded-xl bg-[#07161F] border border-slate-700 text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-[#D96826] focus:border-transparent transition"
              />
            </div>
          </div>

          <!-- E-mail (Desabilitado) -->
          <div class="space-y-1.5 sm:col-span-2">
            <div class="flex items-center justify-between">
              <label for="email" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
                E-mail da Credencial (Autenticação Segura)
              </label>
              <span class="inline-flex items-center gap-1 text-[11px] text-emerald-400">
                <CheckCircle2 class="w-3.5 h-3.5" />
                Validado via Supabase
              </span>
            </div>
            <div class="relative">
              <Lock class="w-4 h-4 text-slate-500 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
              <input
                id="email"
                type="email"
                disabled
                :value="user?.email || 'usuario@litcapital.com.br'"
                class="w-full pl-10 pr-4 py-3 rounded-xl bg-[#040C12] border border-slate-800 text-sm text-slate-400 cursor-not-allowed select-none"
              />
            </div>
          </div>
        </div>
      </section>

      <!-- 2. Bloco Condicional: CUSTOMER (Usuário / Proprietário PF) -->
      <section
        v-if="simulatedRole === 'customer'"
        class="rounded-2xl bg-[#0D2230] border border-white/10 p-6 sm:p-8 space-y-6 shadow-xl"
      >
        <div class="flex items-center justify-between pb-3 border-b border-white/10">
          <h2 class="text-base font-bold text-white flex items-center gap-2">
            <UserCheck class="w-4 h-4 text-[#F28C28]" />
            <span>Dados de Pessoa Física & Preferências</span>
          </h2>
          <span class="text-xs font-semibold text-[#F28C28] uppercase tracking-wider">
            Perfil: Usuário / Proprietário PF
          </span>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-5">
          <!-- CPF -->
          <div class="space-y-1.5">
            <label for="customerCpf" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              CPF do Titular
            </label>
            <input
              id="customerCpf"
              v-model="customerCpf"
              type="text"
              placeholder="000.000.000-00"
              class="w-full px-4 py-3 rounded-xl bg-[#07161F] border border-slate-700 text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-[#D96826] focus:border-transparent transition"
            />
          </div>

          <!-- Preferência de Contato -->
          <div class="space-y-1.5">
            <label for="contactPref" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              Preferência de Horário / Canal
            </label>
            <select
              id="contactPref"
              v-model="contactPreference"
              class="w-full px-4 py-3 rounded-xl bg-[#07161F] border border-slate-700 text-sm text-white focus:outline-none focus:ring-2 focus:ring-[#D96826] focus:border-transparent transition"
            >
              <option value="whatsapp">WhatsApp (Horário comercial)</option>
              <option value="manha">Manhã (08h às 12h)</option>
              <option value="tarde">Tarde (13h às 18h)</option>
              <option value="ligacao">Ligação Telefônica</option>
            </select>
          </div>
        </div>

        <div class="p-4 rounded-xl bg-white/[0.03] border border-white/10 text-xs text-slate-300 space-y-1">
          <p class="font-bold text-white">Trava de Curadoria Automática</p>
          <p class="text-slate-400">
            Como Pessoa Física, os anúncios cadastrados por você passam pela esteira de compliance e due diligence da LIT Capital antes de serem exibidos na vitrine pública.
          </p>
        </div>
      </section>

      <!-- 3. Bloco Condicional: BROKER (Corretor Autônomo) -->
      <section
        v-if="simulatedRole === 'broker'"
        class="rounded-2xl bg-[#0D2230] border border-white/10 p-6 sm:p-8 space-y-6 shadow-xl"
      >
        <div class="flex items-center justify-between pb-3 border-b border-white/10">
          <h2 class="text-base font-bold text-white flex items-center gap-2">
            <BadgeCheck class="w-4 h-4 text-[#F28C28]" />
            <span>Credencial Profissional & Atuação (CRECI)</span>
          </h2>
          <span class="text-xs font-semibold text-[#F28C28] uppercase tracking-wider">
            Perfil: Corretor Autônomo
          </span>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-5">
          <!-- CPF -->
          <div class="space-y-1.5">
            <label for="brokerCpf" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              CPF do Corretor
            </label>
            <input
              id="brokerCpf"
              v-model="brokerCpf"
              type="text"
              placeholder="000.000.000-00"
              class="w-full px-4 py-3 rounded-xl bg-[#07161F] border border-slate-700 text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-[#D96826] focus:border-transparent transition"
            />
          </div>

          <!-- Número do CRECI -->
          <div class="space-y-1.5">
            <label for="creciNumber" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              Registro Profissional CRECI
            </label>
            <input
              id="creciNumber"
              v-model="creciNumber"
              type="text"
              placeholder="Ex: CRECI-ES 12345-F"
              class="w-full px-4 py-3 rounded-xl bg-[#07161F] border border-slate-700 text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-[#D96826] focus:border-transparent transition"
            />
          </div>

          <!-- Área de Atuação -->
          <div class="space-y-1.5">
            <label for="brokerSpecialty" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              Especialidade de Mercado
            </label>
            <select
              id="brokerSpecialty"
              v-model="brokerSpecialty"
              class="w-full px-4 py-3 rounded-xl bg-[#07161F] border border-slate-700 text-sm text-white focus:outline-none focus:ring-2 focus:ring-[#D96826] focus:border-transparent transition"
            >
              <option value="alto_padrao">Alto Padrão Urbano (Vitória e Vila Velha)</option>
              <option value="fazendas">Fazendas e Glebas Produtivas (Agro / ESG)</option>
              <option value="lancamentos">Lançamentos & Incorporação Imobiliária</option>
              <option value="comercial">Comercial, Galpões & Logística</option>
            </select>
          </div>

          <!-- Imobiliária Vinculada (Opcional) -->
          <div class="space-y-1.5">
            <label for="affiliatedAgency" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              Imobiliária Vinculada <span class="text-slate-500 font-normal">(Opcional)</span>
            </label>
            <input
              id="affiliatedAgency"
              v-model="affiliatedAgency"
              type="text"
              placeholder="Ex: Autônomo ou Agência Parceira"
              class="w-full px-4 py-3 rounded-xl bg-[#07161F] border border-slate-700 text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-[#D96826] focus:border-transparent transition"
            />
          </div>
        </div>

        <div class="p-4 rounded-xl bg-white/[0.03] border border-white/10 text-xs text-slate-300 space-y-1">
          <p class="font-bold text-white">Comissões Garantidas & Parcerias</p>
          <p class="text-slate-400">
            Corretores autônomos com CRECI verificado participam da esteira de originação de ativos e funding com segurança jurídica contratual da LIT Capital.
          </p>
        </div>
      </section>

      <!-- 4. Bloco Condicional: B2B_PARTNER (Parceiro B2B / Imobiliária) -->
      <section
        v-if="simulatedRole === 'b2b_partner'"
        class="rounded-2xl bg-[#0D2230] border border-white/10 p-6 sm:p-8 space-y-6 shadow-xl"
      >
        <div class="flex items-center justify-between pb-3 border-b border-white/10">
          <h2 class="text-base font-bold text-white flex items-center gap-2">
            <Building2 class="w-4 h-4 text-[#F28C28]" />
            <span>Dados Corporativos & Governança B2B</span>
          </h2>
          <span class="text-xs font-semibold text-[#F28C28] uppercase tracking-wider">
            Perfil: Parceiro B2B
          </span>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-5">
          <!-- CNPJ -->
          <div class="space-y-1.5">
            <label for="cnpj" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              CNPJ da Empresa
            </label>
            <input
              id="cnpj"
              v-model="cnpj"
              type="text"
              placeholder="00.000.000/0001-00"
              class="w-full px-4 py-3 rounded-xl bg-[#07161F] border border-slate-700 text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-[#D96826] focus:border-transparent transition"
            />
          </div>

          <!-- Nome Fantasia -->
          <div class="space-y-1.5">
            <label for="tradeName" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              Nome Fantasia / Marca
            </label>
            <input
              id="tradeName"
              v-model="tradeName"
              type="text"
              placeholder="Ex: Prime Imóveis Capital"
              class="w-full px-4 py-3 rounded-xl bg-[#07161F] border border-slate-700 text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-[#D96826] focus:border-transparent transition"
            />
          </div>

          <!-- CRECI Jurídico -->
          <div class="space-y-1.5">
            <label for="creciJuridico" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              CRECI Jurídico (Pessoa Jurídica)
            </label>
            <input
              id="creciJuridico"
              v-model="creciJuridico"
              type="text"
              placeholder="Ex: CRECI-ES 9876-J"
              class="w-full px-4 py-3 rounded-xl bg-[#07161F] border border-slate-700 text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-[#D96826] focus:border-transparent transition"
            />
          </div>

          <!-- Responsável Legal -->
          <div class="space-y-1.5">
            <label for="legalRep" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              Nome do Responsável Legal / Sócio
            </label>
            <input
              id="legalRep"
              v-model="legalRepresentative"
              type="text"
              placeholder="Ex: Carlos Drummond"
              class="w-full px-4 py-3 rounded-xl bg-[#07161F] border border-slate-700 text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-[#D96826] focus:border-transparent transition"
            />
          </div>

          <!-- Site / Portfólio (Opcional) -->
          <div class="space-y-1.5 sm:col-span-2">
            <label for="websiteUrl" class="block text-xs font-semibold uppercase tracking-wider text-slate-300">
              Site / Portfólio Digital <span class="text-slate-500 font-normal">(Opcional)</span>
            </label>
            <div class="relative">
              <Globe class="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
              <input
                id="websiteUrl"
                v-model="websiteUrl"
                type="url"
                placeholder="https://www.suaempresa.com.br"
                class="w-full pl-10 pr-4 py-3 rounded-xl bg-[#07161F] border border-slate-700 text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-[#D96826] focus:border-transparent transition"
              />
            </div>
          </div>
        </div>

        <div class="p-4 rounded-xl bg-white/[0.03] border border-white/10 text-xs text-slate-300 space-y-1">
          <p class="font-bold text-white">Ecossistema B2B Integrado</p>
          <p class="text-slate-400">
            Parceiros corporativos contam com esteira de funding estruturado, split de honorários direto em conta e gestão multi-corretores.
          </p>
        </div>
      </section>

      <!-- Feedback de Sucesso -->
      <div
        v-if="saveSuccess"
        class="p-4 rounded-xl bg-emerald-500/15 border border-emerald-500/30 text-emerald-200 text-sm flex items-center gap-3 shadow-lg"
      >
        <CheckCircle2 class="w-5 h-5 text-emerald-400 shrink-0" />
        <span>Perfil e dados de onboarding salvos com sucesso no ecossistema LIT Capital!</span>
      </div>

      <!-- Botão de Ação CTA -->
      <div class="flex items-center justify-end gap-4 pt-2">
        <button
          type="submit"
          :disabled="saving"
          class="inline-flex items-center justify-center gap-2.5 px-6 py-3.5 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] hover:from-[#c35a1d] hover:to-[#e07b1d] disabled:opacity-60 text-white font-bold text-sm shadow-lg shadow-[#D96826]/25 transition cursor-pointer"
        >
          <Save v-if="!saving" class="w-4 h-4" />
          <span v-if="!saving">Salvar Perfil e Concluir Onboarding</span>
          <span v-else>Sincronizando Dados...</span>
          <ArrowRight v-if="!saving" class="w-4 h-4" />
        </button>
      </div>
    </form>
  </div>
</template>
