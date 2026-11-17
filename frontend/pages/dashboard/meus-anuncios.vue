<script setup lang="ts">
import {
  Building2,
  PlusCircle,
  Clock,
  Eye,
  CheckCircle2,
  ShieldCheck,
  Home,
  X,
  Sparkles,
  Camera,
  ArrowRight
} from 'lucide-vue-next'
import type { UploadedImageItem } from '~/components/EducativeImageUploader.vue'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const isModalOpen = ref(false)
const uploadedImages = ref<UploadedImageItem[]>([])
const submissionFeedback = ref<{ type: 'success' | 'warning'; message: string } | null>(null)

function handleImagesChange(newImages: UploadedImageItem[]) {
  uploadedImages.value = newImages
  if (submissionFeedback.value) {
    submissionFeedback.value = null
  }
}

function handleSaveAsset() {
  if (uploadedImages.value.length === 0) {
    submissionFeedback.value = {
      type: 'warning',
      message: 'Selecione e envie pelo menos 1 imagem em alta resolução para compor a ficha técnica do ativo.'
    }
    return
  }

  const missingDescriptions = uploadedImages.value.filter((i) => !i.description.trim())
  if (missingDescriptions.length > 0) {
    submissionFeedback.value = {
      type: 'warning',
      message: `Atenção: ${missingDescriptions.length} imagem(ns) ainda não possuem descrição. Preencha todos os campos para aprovação célere na curadoria.`
    }
    return
  }

  submissionFeedback.value = {
    type: 'success',
    message: `${uploadedImages.value.length} imagem(ns) validadas e prontas para sincronização com a esteira de compliance!`
  }
}
</script>

<template>
  <div class="space-y-8">
    <!-- Cabeçalho -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h1 class="text-2xl font-bold text-white tracking-tight">Meus Anúncios</h1>
        <p class="text-xs sm:text-sm text-slate-400 mt-1">
          Gerencie seu portfólio de ativos imobiliários, esteira de curadoria e métricas de visualização.
        </p>
      </div>

      <button
        type="button"
        @click="isModalOpen = true"
        class="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] hover:from-[#c35a1d] hover:to-[#e07b1d] text-white text-xs sm:text-sm font-bold shadow-md shadow-[#D96826]/20 transition cursor-pointer shrink-0"
      >
        <PlusCircle class="w-4 h-4" />
        <span>Cadastrar Novo Ativo</span>
      </button>
    </div>

    <!-- Mini KPIs do Usuário -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <div class="p-5 rounded-2xl bg-[#0D2230] border border-white/10 space-y-1.5 shadow-lg">
        <div class="flex items-center justify-between text-slate-400 text-xs font-semibold uppercase">
          <span>Ativos Publicados</span>
          <CheckCircle2 class="w-4 h-4 text-emerald-400" />
        </div>
        <p class="text-2xl font-extrabold text-white">0</p>
        <p class="text-[11px] text-slate-400">Visíveis na Vitrine Pública</p>
      </div>

      <div class="p-5 rounded-2xl bg-[#0D2230] border border-white/10 space-y-1.5 shadow-lg">
        <div class="flex items-center justify-between text-slate-400 text-xs font-semibold uppercase">
          <span>Em Curadoria</span>
          <Clock class="w-4 h-4 text-amber-400" />
        </div>
        <p class="text-2xl font-extrabold text-white">0</p>
        <p class="text-[11px] text-slate-400">Aguardando validação compliance</p>
      </div>

      <div class="p-5 rounded-2xl bg-[#0D2230] border border-white/10 space-y-1.5 shadow-lg">
        <div class="flex items-center justify-between text-slate-400 text-xs font-semibold uppercase">
          <span>Interesses Recebidos</span>
          <Eye class="w-4 h-4 text-[#F28C28]" />
        </div>
        <p class="text-2xl font-extrabold text-white">0</p>
        <p class="text-[11px] text-slate-400">Contatos de investidores</p>
      </div>
    </div>

    <!-- Empty State Elegante -->
    <div class="rounded-2xl bg-[#0D2230] border border-white/10 p-12 text-center max-w-2xl mx-auto space-y-4 shadow-xl">
      <div class="w-16 h-16 rounded-2xl bg-[#00384A]/60 border border-white/10 flex items-center justify-center text-[#F28C28] mx-auto shadow-inner">
        <Home class="w-8 h-8" />
      </div>

      <div class="space-y-2">
        <h3 class="text-xl font-bold text-white">
          Você ainda não possui ativos na vitrine
        </h3>
        <p class="text-xs sm:text-sm text-slate-400 leading-relaxed max-w-md mx-auto">
          Cadastre seu imóvel urbano ou gleba rural para ser analisado pela curadoria e compliance da LIT Capital e exibido para investidores qualificados.
        </p>
      </div>

      <div class="pt-2">
        <button
          type="button"
          @click="isModalOpen = true"
          class="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-5 py-3 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] hover:from-[#c35a1d] hover:to-[#e07b1d] text-white text-xs sm:text-sm font-bold shadow-lg shadow-[#D96826]/25 transition cursor-pointer"
        >
          <PlusCircle class="w-4 h-4" />
          <span>Cadastrar Novo Ativo</span>
        </button>
      </div>
    </div>

    <!-- Modal Educativo de Cadastro de Novo Ativo & Upload -->
    <Transition
      enter-active-class="transition duration-200 ease-out"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition duration-150 ease-in"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-if="isModalOpen"
        class="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 bg-black/80 backdrop-blur-sm overflow-y-auto"
      >
        <div
          class="relative w-full max-w-3xl rounded-2xl bg-[#07161F] border border-white/15 p-6 sm:p-8 space-y-6 shadow-2xl my-8 max-h-[90vh] overflow-y-auto"
        >
          <!-- Cabeçalho do Modal -->
          <div class="flex items-start justify-between pb-4 border-b border-white/10">
            <div class="space-y-1">
              <div class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-[#D96826]/15 text-[#F28C28] border border-[#D96826]/30">
                <Sparkles class="w-3.5 h-3.5" />
                <span>Etapa 3 • Curadoria Visual de Ativos</span>
              </div>
              <h2 class="text-xl sm:text-2xl font-bold text-white">
                Upload Educativo de Fotografias
              </h2>
              <p class="text-xs text-slate-400">
                Imagens em alta definição, sem marcas d'água e devidamente descritas são essenciais para aprovação pela curadoria LIT Capital.
              </p>
            </div>

            <button
              type="button"
              @click="isModalOpen = false"
              class="p-2 rounded-xl bg-white/5 hover:bg-white/10 text-slate-300 hover:text-white transition cursor-pointer"
              aria-label="Fechar modal"
            >
              <X class="w-5 h-5" />
            </button>
          </div>

          <!-- Componente de Upload Educativo -->
          <EducativeImageUploader
            :max-files="8"
            v-model="uploadedImages"
            @change="handleImagesChange"
          />

          <!-- Feedback de Validação / Salvar -->
          <div
            v-if="submissionFeedback"
            :class="[
              'p-4 rounded-xl text-xs sm:text-sm flex items-start gap-3 shadow-md',
              submissionFeedback.type === 'success'
                ? 'bg-emerald-500/15 border border-emerald-500/30 text-emerald-200'
                : 'bg-amber-500/15 border border-amber-500/30 text-amber-200'
            ]"
          >
            <CheckCircle2 v-if="submissionFeedback.type === 'success'" class="w-5 h-5 text-emerald-400 shrink-0 mt-0.5" />
            <Clock v-else class="w-5 h-5 text-amber-400 shrink-0 mt-0.5" />
            <p>{{ submissionFeedback.message }}</p>
          </div>

          <!-- Rodapé de Ações com Autoadaptação Responsiva -->
          <div class="flex flex-col-reverse sm:flex-row items-stretch sm:items-center justify-end gap-3 pt-4 border-t border-white/10">
            <button
              type="button"
              @click="isModalOpen = false"
              class="w-full sm:w-auto px-5 py-2.5 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-xs sm:text-sm font-semibold text-slate-300 hover:text-white transition cursor-pointer text-center"
            >
              Cancelar
            </button>

            <button
              type="button"
              @click="handleSaveAsset"
              class="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-6 py-2.5 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] hover:from-[#c35a1d] hover:to-[#e07b1d] text-white text-xs sm:text-sm font-bold shadow-md shadow-[#D96826]/25 transition cursor-pointer"
            >
              <span>Salvar Fotos & Prosseguir</span>
              <ArrowRight class="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>
