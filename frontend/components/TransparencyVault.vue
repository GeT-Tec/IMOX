<script setup lang="ts">
// Cofre de Transparência — lista os documentos públicos homologados do imóvel.
// Recebe a lista já higienizada por sanitizePublicDocuments(); oculta-se se estiver vazia.
import {
  Lock,
  FileText,
  FileCheck2,
  Sprout,
  Receipt,
  File,
  ExternalLink,
  Landmark
} from 'lucide-vue-next'
import type { PublicDocumentItem } from '~/types'

const props = defineProps<{
  documents: PublicDocumentItem[]
}>()

const categoryMeta: Record<PublicDocumentItem['category'], { icon: unknown; label: string }> = {
  matricula: { icon: FileText, label: 'Matrícula' },
  certidao: { icon: FileCheck2, label: 'Certidão' },
  car: { icon: Sprout, label: 'CAR' },
  iptu: { icon: Receipt, label: 'IPTU' },
  outros: { icon: File, label: 'Documento' }
}

function formatVerifiedAt(value?: string) {
  if (!value) return ''
  const date = new Date(value)
  return Number.isNaN(date.getTime()) ? '' : date.toLocaleDateString('pt-BR')
}
</script>

<template>
  <section
    v-if="props.documents.length > 0"
    aria-labelledby="transparency-vault-title"
    class="rounded-2xl bg-white/[0.04] backdrop-blur-md border border-white/10 p-5 sm:p-6 shadow-xl space-y-4"
  >
    <header class="flex items-start justify-between gap-3">
      <div class="flex items-center gap-3">
        <div
          class="w-10 h-10 rounded-xl bg-[#00384A] border border-[#F28C28]/30 flex items-center justify-center text-[#F28C28] shrink-0"
        >
          <Lock class="w-5 h-5" />
        </div>
        <div>
          <h2 id="transparency-vault-title" class="text-sm sm:text-base font-bold text-white">
            Cofre de Transparência
          </h2>
          <p class="text-[11px] text-slate-400">Documentos públicos validados pela curadoria</p>
        </div>
      </div>
      <span
        class="text-[10px] font-bold px-2 py-0.5 rounded-full bg-[#D96826]/15 border border-[#D96826]/30 text-[#F28C28] shrink-0"
      >
        {{ props.documents.length }} {{ props.documents.length === 1 ? 'item' : 'itens' }}
      </span>
    </header>

    <ul class="space-y-2.5">
      <li v-for="doc in props.documents" :key="doc.id">
        <component
          :is="doc.documentUrl ? 'a' : 'div'"
          :href="doc.documentUrl || undefined"
          :target="doc.documentUrl ? '_blank' : undefined"
          :rel="doc.documentUrl ? 'noopener noreferrer' : undefined"
          :class="[
            'group flex items-center gap-3 p-3 rounded-xl border border-white/10 bg-[#0D2230]/70 transition',
            doc.documentUrl ? 'hover:border-[#F28C28]/50 hover:bg-[#0D2230] cursor-pointer' : ''
          ]"
        >
          <div
            class="w-9 h-9 rounded-lg bg-white/5 border border-white/10 flex items-center justify-center text-[#F28C28] shrink-0"
          >
            <component :is="categoryMeta[doc.category].icon" class="w-4 h-4" />
          </div>

          <div class="min-w-0 flex-1">
            <p class="text-xs sm:text-sm font-semibold text-white truncate">
              {{ doc.title }}
            </p>
            <p class="text-[11px] text-slate-400 truncate flex items-center gap-1">
              <Landmark v-if="doc.issuedBy" class="w-3 h-3 shrink-0" />
              <span>{{ doc.issuedBy || categoryMeta[doc.category].label }}</span>
              <span v-if="formatVerifiedAt(doc.verifiedAt)" class="text-slate-500">
                • verificado em {{ formatVerifiedAt(doc.verifiedAt) }}
              </span>
            </p>
          </div>

          <ExternalLink
            v-if="doc.documentUrl"
            class="w-4 h-4 text-slate-500 group-hover:text-[#F28C28] transition shrink-0"
          />
        </component>
      </li>
    </ul>
  </section>
</template>
