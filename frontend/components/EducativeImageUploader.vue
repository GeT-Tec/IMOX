<script setup lang="ts">
import { ref, computed, onBeforeUnmount } from 'vue'
import {
  UploadCloud,
  Image as ImageIcon,
  AlertCircle,
  Trash2,
  CheckCircle2,
  Sparkles,
  Camera,
  Info,
  X,
  FileWarning
} from 'lucide-vue-next'

export interface UploadedImageItem {
  id: string
  file: File
  previewUrl: string
  name: string
  sizeFormatted: string
  sizeBytes: number
  description: string
}

const props = withDefaults(
  defineProps<{
    maxFiles?: number
    modelValue?: UploadedImageItem[]
  }>(),
  {
    maxFiles: 10,
    modelValue: () => []
  }
)

const emit = defineEmits<{
  (e: 'update:modelValue', value: UploadedImageItem[]): void
  (e: 'change', value: UploadedImageItem[]): void
}>()

// Constantes de validação institucional
const MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024 // 5MB
const ALLOWED_EXTENSIONS = ['jpg', 'jpeg', 'png', 'webp']
const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp']

const fileInputRef = ref<HTMLInputElement | null>(null)
const isDragging = ref(false)
const validationError = ref<string | null>(null)
const items = ref<UploadedImageItem[]>([...props.modelValue])

// Sincronização e emissão para o pai
function notifyChange() {
  emit('update:modelValue', items.value)
  emit('change', items.value)
}

function formatBytes(bytes: number): string {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(1))} ${sizes[i]}`
}

function validateFile(file: File): { valid: boolean; reason?: string } {
  const extension = file.name.split('.').pop()?.toLowerCase() || ''

  // Validação de formato (extensão + MIME)
  const isValidFormat =
    ALLOWED_EXTENSIONS.includes(extension) &&
    (ALLOWED_MIME_TYPES.includes(file.type) || !file.type)

  if (!isValidFormat) {
    return {
      valid: false,
      reason: `O arquivo "${file.name}" não é um formato aceito. Utilize apenas imagens nos formatos JPG, PNG ou WEBP.`
    }
  }

  // Validação de tamanho (máximo 5MB)
  if (file.size > MAX_FILE_SIZE_BYTES) {
    return {
      valid: false,
      reason: `O arquivo "${file.name}" ultrapassa o limite de 5MB (${formatBytes(file.size)}). Reduza o tamanho ou selecione outra imagem para garantir o padrão premium da vitrine.`
    }
  }

  return { valid: true }
}

function processFiles(files: FileList | File[]) {
  validationError.value = null
  const fileArray = Array.from(files)

  if (fileArray.length === 0) return

  // Limite total de arquivos
  const availableSlots = props.maxFiles - items.value.length
  if (availableSlots <= 0) {
    validationError.value = `Limite de fotos atingido. Você pode cadastrar no máximo ${props.maxFiles} imagens por anúncio.`
    return
  }

  const acceptedFiles: UploadedImageItem[] = []
  const rejectionReasons: string[] = []

  for (const file of fileArray) {
    if (acceptedFiles.length >= availableSlots) {
      rejectionReasons.push(`Limite máximo de ${props.maxFiles} fotos excedido. As imagens extras foram ignoradas.`)
      break
    }

    const validation = validateFile(file)
    if (!validation.valid) {
      rejectionReasons.push(validation.reason!)
      continue
    }

    const id = `img-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`
    const previewUrl = URL.createObjectURL(file)

    acceptedFiles.push({
      id,
      file,
      previewUrl,
      name: file.name,
      sizeFormatted: formatBytes(file.size),
      sizeBytes: file.size,
      description: ''
    })
  }

  if (rejectionReasons.length > 0) {
    validationError.value = rejectionReasons.join(' ')
  }

  if (acceptedFiles.length > 0) {
    items.value = [...items.value, ...acceptedFiles]
    notifyChange()
  }

  // Reseta input
  if (fileInputRef.value) {
    fileInputRef.value.value = ''
  }
}

function handleFileInputChange(event: Event) {
  const target = event.target as HTMLInputElement
  if (target.files) {
    processFiles(target.files)
  }
}

function handleDrop(event: DragEvent) {
  isDragging.value = false
  if (event.dataTransfer?.files) {
    processFiles(event.dataTransfer.files)
  }
}

function triggerFilePicker() {
  fileInputRef.value?.click()
}

function removeImage(index: number) {
  const [removed] = items.value.splice(index, 1)
  if (removed?.previewUrl) {
    URL.revokeObjectURL(removed.previewUrl)
  }
  notifyChange()
}

function onDescriptionChange(index: number, newDesc: string) {
  items.value[index].description = newDesc
  notifyChange()
}

// Limpeza de URLs temporárias ao desmontar
onBeforeUnmount(() => {
  for (const item of items.value) {
    if (item.previewUrl) {
      URL.revokeObjectURL(item.previewUrl)
    }
  }
})

// Métricas de progresso das descrições
const filledDescriptionsCount = computed(() => {
  return items.value.filter((i) => i.description.trim().length > 0).length
})

const isAllDescriptionsFilled = computed(() => {
  return items.value.length > 0 && filledDescriptionsCount.value === items.value.length
})
</script>

<template>
  <div class="space-y-6">
    <!-- 1. Guia Educativo de Fotografia Imobiliária & Agro (LIT Capital) -->
    <div class="rounded-2xl bg-[#002936] border border-[#00384A] p-5 shadow-lg space-y-3">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#F28C28]">
          <Camera class="w-4 h-4" />
          <span>Curadoria Visual & Padrão Institucional LIT Capital</span>
        </div>
        <span class="text-[11px] font-semibold text-slate-300">
          Até {{ maxFiles }} imagens em alta resolução
        </span>
      </div>

      <p class="text-xs text-slate-300 leading-relaxed">
        Imóveis e ativos do agronegócio com fotografias profissionais recebem até <strong class="text-white">4x mais visualizações e celeridade na aprovação de compliance</strong>.
      </p>

      <div class="grid grid-cols-1 sm:grid-cols-3 gap-2.5 pt-1 text-xs text-slate-300">
        <div class="flex items-start gap-2 p-2.5 rounded-xl bg-white/[0.03] border border-white/5">
          <Sparkles class="w-4 h-4 text-[#F28C28] shrink-0 mt-0.5" />
          <div>
            <p class="font-bold text-white text-[11px]">Resolução Recomendada</p>
            <p class="text-[10px] text-slate-400">Mínimo 1920x1080px (Full HD) na horizontal.</p>
          </div>
        </div>

        <div class="flex items-start gap-2 p-2.5 rounded-xl bg-white/[0.03] border border-white/5">
          <Info class="w-4 h-4 text-[#F28C28] shrink-0 mt-0.5" />
          <div>
            <p class="font-bold text-white text-[11px]">Iluminação Natural</p>
            <p class="text-[10px] text-slate-400">Fotos claras, sem distorção e sem ângulos inclinados.</p>
          </div>
        </div>

        <div class="flex items-start gap-2 p-2.5 rounded-xl bg-white/[0.03] border border-white/5">
          <CheckCircle2 class="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
          <div>
            <p class="font-bold text-white text-[11px]">Sem Marcas d'Água</p>
            <p class="text-[10px] text-slate-400">Evite logos de outros portais, placas ou números de contato.</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 2. Alerta Visual Educativo de Validação (Caso ocorra erro de formato ou tamanho) -->
    <Transition
      enter-active-class="transition duration-200 ease-out"
      enter-from-class="opacity-0 -translate-y-2"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition duration-150 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 -translate-y-2"
    >
      <div
        v-if="validationError"
        class="p-4 rounded-xl bg-red-500/10 border border-red-500/30 text-red-200 flex items-start justify-between gap-3 shadow-lg"
      >
        <div class="flex items-start gap-3">
          <FileWarning class="w-5 h-5 text-red-400 shrink-0 mt-0.5" />
          <div class="space-y-1">
            <p class="text-xs font-bold text-red-300 uppercase tracking-wider">
              Aviso Educativo de Conformidade
            </p>
            <p class="text-xs leading-relaxed text-red-200">
              {{ validationError }}
            </p>
            <p class="text-[11px] text-red-300/80">
              Apenas imagens <strong>JPG, PNG ou WEBP de até 5MB</strong> são permitidas para garantir a qualidade premium do seu anúncio.
            </p>
          </div>
        </div>

        <button
          type="button"
          @click="validationError = null"
          class="p-1 rounded-lg hover:bg-white/10 text-red-300 hover:text-white transition cursor-pointer"
          aria-label="Dispensar alerta"
        >
          <X class="w-4 h-4" />
        </button>
      </div>
    </Transition>

    <!-- 3. Área de Dropzone Educativa -->
    <div
      :class="[
        'relative rounded-2xl border-2 border-dashed p-8 sm:p-10 text-center transition-all duration-200 flex flex-col items-center justify-center gap-3 cursor-pointer select-none',
        isDragging
          ? 'border-[#F28C28] bg-[#D96826]/10 scale-[1.005]'
          : 'border-white/15 hover:border-[#D96826]/50 bg-[#0D2230]/70 hover:bg-[#0D2230]'
      ]"
      @dragover.prevent="isDragging = true"
      @dragleave.prevent="isDragging = false"
      @drop.prevent="handleDrop"
      @click="triggerFilePicker"
    >
      <input
        ref="fileInputRef"
        type="file"
        multiple
        accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp"
        class="hidden"
        @change="handleFileInputChange"
      />

      <div
        :class="[
          'w-14 h-14 rounded-2xl flex items-center justify-center transition-all',
          isDragging
            ? 'bg-[#D96826] text-white scale-110 shadow-lg shadow-[#D96826]/30'
            : 'bg-[#00384A] text-[#F28C28] border border-white/10'
        ]"
      >
        <UploadCloud class="w-7 h-7" />
      </div>

      <div class="space-y-1 max-w-md">
        <h4 class="text-sm sm:text-base font-bold text-white">
          Arraste fotos em alta resolução aqui
        </h4>
        <p class="text-xs text-slate-300">
          Mínimo recomendado: <strong class="text-white font-semibold">1920x1080px</strong> (JPG, PNG ou WEBP até 5MB).
        </p>
      </div>

      <div class="pt-2">
        <span
          class="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] hover:from-[#c35a1d] hover:to-[#e07b1d] text-white text-xs sm:text-sm font-bold shadow-md shadow-[#D96826]/20 transition"
        >
          <ImageIcon class="w-4 h-4" />
          <span>Selecionar Fotos do Computador</span>
        </span>
      </div>

      <p class="text-[11px] text-slate-400">
        {{ items.length }} de {{ maxFiles }} fotos adicionadas
      </p>
    </div>

    <!-- 4. Lista de Fotos & Descrição Individualizada Obrigatória -->
    <div v-if="items.length > 0" class="space-y-4 pt-2">
      <!-- Barra de Resumo e Conformidade da Lista -->
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2 p-3.5 rounded-xl bg-white/[0.02] border border-white/10">
        <div class="flex items-center gap-2">
          <span class="text-xs font-bold text-white">
            Fotos Carregadas ({{ items.length }})
          </span>
          <span
            :class="[
              'px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider',
              isAllDescriptionsFilled
                ? 'bg-emerald-500/15 text-emerald-300 border border-emerald-500/30'
                : 'bg-amber-500/15 text-amber-300 border border-amber-500/30'
            ]"
          >
            {{ isAllDescriptionsFilled ? 'Descrições completas' : `${filledDescriptionsCount} de ${items.length} descritas` }}
          </span>
        </div>

        <p class="text-[11px] text-slate-400">
          A primeira imagem será exibida como a <strong class="text-[#F28C28]">Foto de Capa</strong> principal.
        </p>
      </div>

      <!-- Grid de Itens com Miniatura e Input de Descrição Obrigatória -->
      <div class="space-y-3">
        <div
          v-for="(item, index) in items"
          :key="item.id"
          class="group p-4 rounded-2xl bg-[#0D2230] border border-white/10 hover:border-[#D96826]/40 transition flex flex-col md:flex-row md:items-center gap-4 shadow-md"
        >
          <!-- Miniatura / Thumbnail -->
          <div class="relative w-full md:w-32 h-36 md:h-24 rounded-xl overflow-hidden bg-black/40 border border-white/10 shrink-0">
            <img
              :src="item.previewUrl"
              :alt="item.description || item.name"
              class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-200"
            />

            <!-- Badge de Ordem / Capa -->
            <div class="absolute top-2 left-2">
              <span
                v-if="index === 0"
                class="px-2 py-0.5 rounded-md text-[9px] font-extrabold uppercase tracking-wider bg-[#D96826] text-white shadow"
              >
                Capa
              </span>
              <span
                v-else
                class="px-1.5 py-0.5 rounded-md text-[9px] font-bold bg-black/60 text-slate-200 backdrop-blur-xs"
              >
                #{{ String(index + 1).padStart(2, '0') }}
              </span>
            </div>

            <!-- Badge de Tamanho -->
            <div class="absolute bottom-1.5 right-1.5 px-1.5 py-0.5 rounded text-[9px] font-mono bg-black/70 text-slate-300">
              {{ item.sizeFormatted }}
            </div>
          </div>

          <!-- Campos de Dados: Nome do Arquivo + Input de Descrição Individualizada -->
          <div class="flex-1 min-w-0 space-y-2">
            <div class="flex items-center justify-between gap-2">
              <p class="text-xs font-semibold text-slate-300 truncate font-mono">
                {{ item.name }}
              </p>
              <span
                :class="[
                  'text-[10px] font-bold uppercase tracking-wider flex items-center gap-1 shrink-0',
                  item.description.trim() ? 'text-emerald-400' : 'text-amber-400'
                ]"
              >
                <CheckCircle2 v-if="item.description.trim()" class="w-3.5 h-3.5" />
                <AlertCircle v-else class="w-3.5 h-3.5" />
                {{ item.description.trim() ? 'Descrita' : 'Descrição necessária' }}
              </span>
            </div>

            <!-- Input de Descrição Obrigatória -->
            <div class="relative">
              <input
                :value="item.description"
                type="text"
                required
                maxlength="120"
                placeholder="Descreva esta imagem (ex: Vista da Fachada, Trator Modelo X, Área de Pastagem)"
                @input="onDescriptionChange(index, ($event.target as HTMLInputElement).value)"
                class="w-full px-3.5 py-2.5 rounded-xl bg-[#07161F] border border-white/10 hover:border-white/20 focus:border-[#D96826] focus:ring-2 focus:ring-[#D96826]/20 text-xs sm:text-sm text-white placeholder-slate-500 focus:outline-none transition"
              />
            </div>
          </div>

          <!-- Botão de Remoção -->
          <div class="flex md:flex-col items-center justify-end md:justify-center shrink-0">
            <button
              type="button"
              @click="removeImage(index)"
              title="Remover imagem da lista"
              class="inline-flex items-center gap-1.5 px-3 py-2 rounded-xl bg-white/[0.04] hover:bg-red-500/15 border border-white/10 hover:border-red-500/30 text-xs font-semibold text-slate-400 hover:text-red-300 transition cursor-pointer"
            >
              <Trash2 class="w-4 h-4" />
              <span class="md:hidden">Remover</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
