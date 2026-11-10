<script setup lang="ts">
import {
  Building2,
  Building,
  Sprout,
  Scale,
  Landmark,
  Shield,
  ShieldCheck,
  CheckCircle2,
  BadgeCheck,
  TrendingUp,
  FileText,
  FileCheck2,
  Scroll,
  MapPin,
  Globe,
  Sparkles,
  ChevronDown,
  ArrowRight,
  Menu,
  X,
  Lock,
  UserCheck
} from 'lucide-vue-next'

const user = useSupabaseUser()
const route = useRoute()

const isScrolled = ref(false)
const activeVerticalId = ref<string | null>(null)
const mobileMenuOpen = ref(false)
const mobileActiveVerticalId = ref<string>('urbanos')

let closeTimer: ReturnType<typeof setTimeout> | null = null

function handleScroll() {
  isScrolled.value = window.scrollY > 10
}

function openVertical(id: string) {
  if (closeTimer) {
    clearTimeout(closeTimer)
    closeTimer = null
  }
  activeVerticalId.value = id
}

function scheduleClose() {
  closeTimer = setTimeout(() => {
    activeVerticalId.value = null
  }, 220)
}

function cancelClose() {
  if (closeTimer) {
    clearTimeout(closeTimer)
    closeTimer = null
  }
}

function closeMegaMenu() {
  activeVerticalId.value = null
  mobileMenuOpen.value = false
}

// Fechar com ESC
function handleKeydown(event: KeyboardEvent) {
  if (event.key === 'Escape') {
    closeMegaMenu()
  }
}

onMounted(() => {
  handleScroll()
  window.addEventListener('scroll', handleScroll, { passive: true })
  window.addEventListener('keydown', handleKeydown)
})

onBeforeUnmount(() => {
  window.removeEventListener('scroll', handleScroll)
  window.removeEventListener('keydown', handleKeydown)
})

watch(
  () => route.fullPath,
  () => {
    closeMegaMenu()
  }
)

interface PlatformService {
  title: string
  description: string
  icon: any
  tag?: string
  to: string
}

interface B2BPartnerItem {
  title: string
  description: string
}

interface VerticalItem {
  id: string
  name: string
  shortName: string
  categoryBadge: string
  headline: string
  description: string
  to: string
  hubText: string
  icon: any
  platformServices: PlatformService[]
  b2bPartners: {
    badge: string
    title: string
    description: string
    ctaText: string
    ctaTo: string
    items: B2BPartnerItem[]
  }
}

const verticals: VerticalItem[] = [
  {
    id: 'urbanos',
    name: 'Ativos Urbanos',
    shortName: 'Urbanos',
    categoryBadge: 'Lançamentos & Alto Padrão',
    headline: 'Curadoria de Imóveis Urbanos & Estoque B2B',
    description:
      'Empreendimentos na planta, condomínios fechados, coberturas de alto padrão e permutas corporativas com valor de m² homologado.',
    to: '/dashboard/urbanos',
    hubText: 'Acessar Hub de Urbanos',
    icon: Building2,
    platformServices: [
      {
        title: 'Lançamentos & Plantas Inteligentes',
        description:
          'Projetos na planta com fluxo de pagamento direto com incorporadora e potencial de valorização.',
        icon: Building2,
        to: '/dashboard/urbanos'
      },
      {
        title: 'Alto Padrão Residencial',
        description:
          'Mansões em condomínios fechados e coberturas lineares nas localizações mais nobres do ES.',
        icon: Sparkles,
        to: '/dashboard/urbanos'
      },
      {
        title: 'Estoque & Permutas B2B',
        description:
          'Carteira fechada para incorporadoras, fundos imobiliários e estruturação de permutas corporativas.',
        icon: Building,
        to: '/dashboard/urbanos'
      },
      {
        title: 'Valuation & Inteligência de m²',
        description:
          'Precificação analítica por micromercado, histórico real de transações e liquidez estimada.',
        icon: TrendingUp,
        to: '/dashboard/urbanos'
      }
    ],
    b2bPartners: {
      badge: 'Curadoria LIT Capital • Homologado',
      title: 'Parceiros Homologados LIT',
      description:
        'Rede credenciada de imobiliárias private, estúdios de arquitetura e tecnologia audiovisual sob auditoria contínua.',
      ctaText: 'Homologar Imobiliária Parceira B2B',
      ctaTo: '/cadastro',
      items: [
        {
          title: 'Imobiliárias Boutique Credenciadas',
          description:
            'Corretores de elite com foco exclusivo em compradores e investidores de alto patrimônio líquido.'
        },
        {
          title: 'Fotografia & Tour Virtual 3D (Matterport)',
          description:
            'Produção audiovisual imersiva e captação aérea em 4K para aceleração do ciclo de venda.'
        },
        {
          title: 'Home Staging & Interiores',
          description:
            'Ambientação estética e cenografia pré-venda com arquitetura de alta conversão.'
        }
      ]
    }
  },
  {
    id: 'rurais',
    name: 'Ativos Rurais & Agro',
    shortName: 'Rurais & Agro',
    categoryBadge: 'Fazendas & Agronegócio',
    headline: 'Fazendas Produtivas, Inteligência PostGIS & Compliance ESG',
    description:
      'Glebas agropecuárias, áreas de expansão, polígonos georreferenciados e conformidade ambiental rigorosa com o CAR.',
    to: '/dashboard/rurais',
    hubText: 'Acessar Hub do Agro',
    icon: Sprout,
    platformServices: [
      {
        title: 'Fazendas Produtivas & Pecuária',
        description:
          'Propriedades estruturadas com pastagens formadas, pivôs centrais e aptidão agrícola confirmada.',
        icon: Sprout,
        to: '/dashboard/rurais'
      },
      {
        title: 'Inteligência PostGIS & Satélite',
        description:
          'Perímetros poligonais georreferenciados sobrepostos a bases cartográficas e curvas de nível.',
        icon: Globe,
        to: '/dashboard/rurais'
      },
      {
        title: 'Auditoria CAR & Reserva Legal',
        description:
          'Verificação de conformidade ambiental, APPs, recursos hídricos e selo ESG para crédito verde.',
        icon: CheckCircle2,
        to: '/dashboard/rurais'
      },
      {
        title: 'Glebas & Loteamentos de Campo',
        description:
          'Estruturação de condomínios rurais, chácaras de lazer e expansão imobiliária agropecuária.',
        icon: MapPin,
        to: '/dashboard/rurais'
      }
    ],
    b2bPartners: {
      badge: 'ESG & Agro Certified',
      title: 'Parceiros Homologados LIT',
      description:
        'Engenharia agronômica, topografia RTK de precisão e monetização de ativos ambientais credenciados.',
      ctaText: 'Originar Ativos do Agro na Plataforma',
      ctaTo: '/cadastro',
      items: [
        {
          title: 'Engenharia Agronômica & Perícia de Solo',
          description:
            'Laudos técnicos de capacidade produtiva, solo e suporte de pastagem para bancos e investidores.'
        },
        {
          title: 'Topografia RTK & Georreferenciamento INCRA',
          description:
            'Levantamentos planialtimétricos de alta acurácia para retificações de matrícula e desmembramentos.'
        },
        {
          title: 'Créditos de Carbono & Silvicultura',
          description:
            'Monetização e estruturação de excedentes de reserva florestal com certificados rastreáveis.'
        }
      ]
    }
  },
  {
    id: 'cartorio',
    name: 'Cartório',
    shortName: 'Cartório',
    categoryBadge: 'RGI & Registros Públicos',
    headline: 'Emissão de Matrículas, Certidões Vintenárias & Integração ONR',
    description:
      'Plataforma integrada de solicitação, consulta e auditoria de certidões registrais e notariais em escala nacional.',
    to: '/dashboard/cartorio',
    hubText: 'Acessar Serviços de Cartório',
    icon: FileText,
    platformServices: [
      {
        title: 'Emissão Digital de Matrículas',
        description:
          'Busca eletrônica e certidões digitalizadas de Registro de Imóveis em 100% das comarcas brasileiras.',
        icon: FileText,
        to: '/dashboard/cartorio'
      },
      {
        title: 'Certidões Vintenárias & Quinzenárias',
        description:
          'Rastreamento ininterrupto de 20 anos da cadeia dominial para segurança absoluta da transação.',
        icon: Scroll,
        to: '/dashboard/cartorio'
      },
      {
        title: 'Integração ONR & SREI',
        description:
          'Conexão direta com o Operador Nacional do Registro de Imóveis Eletrônico para prenotações ágeis.',
        icon: Landmark,
        to: '/dashboard/cartorio'
      },
      {
        title: 'Certidão de Ônus & Ações Reipersecutórias',
        description:
          'Varredura de hipotecas, alienações fiduciárias, penhoras e gravames averbados no fólio real.',
        icon: ShieldCheck,
        to: '/dashboard/cartorio'
      }
    ],
    b2bPartners: {
      badge: 'Segurança Registral Garantida',
      title: 'Parceiros Homologados LIT',
      description:
        'Despachantorias imobiliárias private e tabelionatos de notas credenciados para tramitação prioritária.',
      ctaText: 'Solicitar Matrícula Online em 24h',
      ctaTo: '/dashboard/cartorio',
      items: [
        {
          title: 'Despachantoria Notarial Express',
          description:
            'Protocolos físicos rápidos, cumprimento de exigências e averbações de escrituras complexas.'
        },
        {
          title: 'Escrituras Públicas no e-Notariado',
          description:
            'Tabelionatos parceiros para lavratura de escrituras 100% online por videoconferência oficial.'
        },
        {
          title: 'Regularização Fundiária & REURB',
          description:
            'Assessoria técnica e urbanística para titulação definitiva de imóveis urbanos e rurais.'
        }
      ]
    }
  },
  {
    id: 'juridico',
    name: 'Jurídico & Compliance',
    shortName: 'Jurídico',
    categoryBadge: 'Due Diligence & Contratos',
    headline: 'Due Diligence Imobiliária 360º, Análise de Risco & Blindagem Contratual',
    description:
      'Compliance jurídico automatizado, análise de certidões forenses, prevenção de passivos e mitigação de risco transacional.',
    to: '/dashboard/juridico',
    hubText: 'Acessar Hub Jurídico',
    icon: Scale,
    platformServices: [
      {
        title: 'Due Diligence Imobiliária 360º',
        description:
          'Auditoria minuciosa de apontamentos cíveis, fiscais, trabalhistas e criminais dos proprietários e antecessores.',
        icon: Scale,
        to: '/dashboard/juridico'
      },
      {
        title: 'Matriz de Risco LIT Score',
        description:
          'Classificação algorítmica de vulnerabilidade jurídica com semáforo de conformidade para aprovação.',
        icon: Shield,
        to: '/dashboard/juridico'
      },
      {
        title: 'Minutas Contratuais Blindadas',
        description:
          'Contratos de compra e venda com cláusulas resolutivas, garantias específicas e blindagem contra evicção.',
        icon: FileCheck2,
        to: '/dashboard/juridico'
      },
      {
        title: 'Compliance PLD/CFT & COAF',
        description:
          'Checagem de origem lícita de recursos, listas restritivas internacionais e conformidade regulatória.',
        icon: CheckCircle2,
        to: '/dashboard/juridico'
      }
    ],
    b2bPartners: {
      badge: 'Auditoria Jurídica Independente',
      title: 'Parceiros Homologados LIT',
      description:
        'Bancas de advocacia corporativa e câmaras de arbitragem especializadas em Direito Imobiliário e Sucessório.',
      ctaText: 'Emitir Parecer Jurídico de Due Diligence',
      ctaTo: '/dashboard/juridico',
      items: [
        {
          title: 'Bancas Especializadas em Direito Imobiliário',
          description:
            'Advogados com notória especialização para estruturação de negócios de alta complexidade e pareceres de risco.'
        },
        {
          title: 'Holding Patrimonial & Planejamento Sucessório',
          description:
            'Estruturação de pessoas jurídicas patrimoniais para proteção familiar e eficiência tributária na transmissão.'
        },
        {
          title: 'Câmara de Arbitragem & Mediação',
          description:
            'Celeridade processual e confidencialidade homologada para solução de controvérsias imobiliárias.'
        }
      ]
    }
  },
  {
    id: 'credito',
    name: 'Funding & Crédito',
    shortName: 'Funding & Crédito',
    categoryBadge: 'Capital & Estruturação',
    headline: 'Home Equity, Antecipação de Recebíveis & Estruturação de Funding',
    description:
      'Simulação multibancos, crédito com garantia real a taxas competitivas e originação de recursos via LIT Capital.',
    to: '/dashboard/credito',
    hubText: 'Acessar Hub de Crédito',
    icon: Landmark,
    platformServices: [
      {
        title: 'Simulador Multibancos em Tempo Real',
        description:
          'Comparação simultânea de taxas de juros, amortização SAC/Price e prazos entre os maiores bancos do país.',
        icon: Landmark,
        to: '/dashboard/credito'
      },
      {
        title: 'Home Equity (Garantia Imobiliária)',
        description:
          'Crédito com imóvel em garantia com taxas a partir de 0,99% a.m. e prazos de até 240 meses mantendo a posse.',
        icon: TrendingUp,
        to: '/dashboard/credito'
      },
      {
        title: 'Antecipação de Recebíveis & Locações',
        description:
          'Desconto ágil de fluxos de aluguel e carteiras de parcelamento direto com taxas competitivas.',
        icon: Sparkles,
        to: '/dashboard/credito'
      },
      {
        title: 'Estruturação de CRI & Fundos Imobiliários',
        description:
          'Empacotamento de recebíveis em Certificados de Recebíveis Imobiliários e captação no mercado de capitais.',
        icon: Building2,
        to: '/dashboard/credito'
      }
    ],
    b2bPartners: {
      badge: 'Mesas de Crédito & Family Offices',
      title: 'Parceiros Homologados LIT',
      description:
        'Correspondentes bancários autorizados, fintechs de liquidez e investidores institucionais parceiros.',
      ctaText: 'Simular Funding & Linhas de Crédito',
      ctaTo: '/dashboard/credito',
      items: [
        {
          title: 'Correspondentes Bancários Autorizados',
          description:
            'Esteiras prioritárias junto à Caixa Econômica, Itaú, Santander, Bradesco e Banco Inter.'
        },
        {
          title: 'Fintechs de Crédito com Garantia',
          description:
            'Aprovação de crédito em esteiras 100% digitais com resposta de viabilidade preliminar em 48h.'
        },
        {
          title: 'Mesa de Originação LIT Capital',
          description:
            'Acesso a family offices e investidores qualificados para operações de equity e dívida estruturada.'
        }
      ]
    }
  },
  {
    id: 'garantias',
    name: 'Segurança & Garantias',
    shortName: 'Segurança',
    categoryBadge: 'Seguros & Avaliações',
    headline: 'Seguros Imobiliários, Fiança Locatícia & Laudos Patrimoniais',
    description:
      'Mitigação integral de riscos com apólices corporativas, garantia de término de obra e avaliações segundo a NBR 14.653.',
    to: '/dashboard/garantias',
    hubText: 'Acessar Hub de Garantias',
    icon: Shield,
    platformServices: [
      {
        title: 'Laudos de Avaliação Patrimonial (NBR 14.653)',
        description:
          'Avaliações mercadológicas e técnicas periciais com rigor metodológico para fins fiscais, judiciais e contábeis.',
        icon: Scale,
        to: '/dashboard/garantias'
      },
      {
        title: 'Seguro Fiança Sem Fiador',
        description:
          'Garantia locatícia completa com análise instantânea de CPF/CNPJ, dispensando fiador ou caução em dinheiro.',
        icon: ShieldCheck,
        to: '/dashboard/garantias'
      },
      {
        title: 'Garantia de Entrega de Obra',
        description:
          'Monitoramento e apólices de performance para empreendimentos com Patrimônio de Afetação constituído.',
        icon: Building2,
        to: '/dashboard/garantias'
      },
      {
        title: 'Cofre Digital de Documentos (RLS Seguro)',
        description:
          'Arquivamento perpétuo de escrituras, contratos e laudos sob criptografia de chave dupla e permissões granulares.',
        icon: Shield,
        to: '/dashboard/garantias'
      }
    ],
    b2bPartners: {
      badge: 'Seguradoras SUSEP Homologadas',
      title: 'Parceiros Homologados LIT',
      description:
        'Seguradoras de primeira linha e empresas de engenharia diagnóstica com credenciamento no IBAPE.',
      ctaText: 'Cotar Seguro ou Laudo Técnico Homologado',
      ctaTo: '/dashboard/garantias',
      items: [
        {
          title: 'Seguradoras Globais Reguladas SUSEP',
          description:
            'Porto Seguro, Tokio Marine e Mapfre com condições negociadas em apólices prediais e residenciais.'
        },
        {
          title: 'Engenharia Diagnóstica & Vistoria Cautelar',
          description:
            'Laudos de recebimento de obras, vistorias de vizinhança e perícias preventivas com registro fotográfico.'
        },
        {
          title: 'Peritos Avaliadores Credenciados IBAPE',
          description:
            'Engenheiros e arquitetos periciais para emissão de laudos de avaliação com ART/RRT oficial.'
        }
      ]
    }
  }
]

const activeVertical = computed(() => {
  return verticals.find((v) => v.id === activeVerticalId.value) || null
})

const mobileActiveVertical = computed(() => {
  return verticals.find((v) => v.id === mobileActiveVerticalId.value) || verticals[0]
})
</script>

<template>
  <header
    :class="[
      'sticky top-0 z-50 bg-gradient-to-b from-[#003040] to-[#002936] transition-all duration-200 border-b border-white/[0.08]',
      isScrolled ? 'shadow-[0_12px_32px_-12px_rgba(0,0,0,0.7)] backdrop-blur-md' : ''
    ]"
    @mouseleave="scheduleClose"
  >
    <!-- Fio institucional laranja premium -->
    <div class="absolute inset-x-0 top-0 h-0.5 bg-gradient-to-r from-[#D96826] via-[#F28C28] to-[#D96826]" />

    <!-- Barra Principal do Header -->
    <div
      :class="[
        'max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-between gap-2 sm:gap-4 transition-all duration-200',
        isScrolled ? 'h-16' : 'h-18'
      ]"
    >
      <!-- Lado Esquerdo: Marca Oficial -->
      <div class="shrink-0 flex items-center">
        <BrandLockup />
      </div>

      <!-- Centro: Navegação das 6 Verticais com Hover Mega Menu (Desktop) -->
      <nav class="hidden xl:flex items-center gap-1 shrink-0" aria-label="Navegação das Verticais">
        <button
          v-for="vertical in verticals"
          :key="vertical.id"
          type="button"
          @mouseenter="openVertical(vertical.id)"
          @focus="openVertical(vertical.id)"
          :class="[
            'inline-flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-semibold tracking-tight transition-all duration-150 cursor-pointer',
            activeVerticalId === vertical.id
              ? 'text-white bg-white/[0.12] shadow-xs ring-1 ring-[#D96826]/50'
              : 'text-slate-300 hover:text-white hover:bg-white/[0.06]'
          ]"
        >
          <span>{{ vertical.name }}</span>
          <ChevronDown
            :class="[
              'w-3.5 h-3.5 text-slate-400 transition-transform duration-200',
              activeVerticalId === vertical.id ? 'rotate-180 text-[#F28C28]' : ''
            ]"
          />
        </button>
      </nav>

      <!-- Centro Intermediário (Para telas entre lg e xl): Versão condensada das 6 verticais -->
      <nav class="hidden lg:flex xl:hidden items-center gap-1 shrink-0" aria-label="Navegação Compacta">
        <button
          v-for="vertical in verticals"
          :key="vertical.id"
          type="button"
          @mouseenter="openVertical(vertical.id)"
          @focus="openVertical(vertical.id)"
          :class="[
            'inline-flex items-center gap-1 px-2.5 py-1.5 rounded-lg text-[11px] font-semibold tracking-tight transition cursor-pointer',
            activeVerticalId === vertical.id
              ? 'text-white bg-white/[0.12] ring-1 ring-[#D96826]/50'
              : 'text-slate-300 hover:text-white hover:bg-white/[0.06]'
          ]"
        >
          <span>{{ vertical.shortName }}</span>
          <ChevronDown
            :class="[
              'w-3 h-3 text-slate-400 transition-transform duration-200',
              activeVerticalId === vertical.id ? 'rotate-180 text-[#F28C28]' : ''
            ]"
          />
        </button>
      </nav>

      <!-- Lado Direito: Ações de Conversão & Auth -->
      <div class="flex items-center gap-2 sm:gap-3 shrink-0">
        <!-- Usuário Logado -->
        <template v-if="user">
          <NuxtLink
            to="/dashboard/meus-anuncios"
            class="hidden sm:inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs sm:text-sm font-semibold text-slate-200 hover:text-white hover:bg-white/[0.08] border border-white/10 transition cursor-pointer"
          >
            <Building class="w-4 h-4 text-[#F28C28]" />
            <span>Meus Anúncios</span>
          </NuxtLink>

          <NuxtLink
            to="/dashboard"
            class="inline-flex items-center gap-2 px-4 sm:px-5 py-2 sm:py-2.5 rounded-full bg-gradient-to-r from-[#D96826] to-[#F28C28] text-white text-xs sm:text-sm font-bold shadow-md shadow-[#D96826]/30 hover:brightness-110 hover:-translate-y-px transition cursor-pointer"
          >
            <ShieldCheck class="w-4 h-4" />
            <span>Meu Painel</span>
          </NuxtLink>
        </template>

        <!-- Usuário Deslogado -->
        <template v-else>
          <NuxtLink
            to="/login"
            class="px-3.5 sm:px-4 py-2 rounded-xl text-xs sm:text-sm font-semibold text-slate-200 hover:text-white hover:bg-white/[0.08] transition cursor-pointer"
          >
            Entrar
          </NuxtLink>

          <NuxtLink
            to="/cadastro"
            class="inline-flex items-center gap-2 px-4 sm:px-5 py-2 sm:py-2.5 rounded-full bg-gradient-to-r from-[#D96826] to-[#F28C28] text-white text-xs sm:text-sm font-bold shadow-md shadow-[#D96826]/30 hover:brightness-110 hover:-translate-y-px transition cursor-pointer"
          >
            <span>Criar Conta / Anunciar</span>
          </NuxtLink>
        </template>

        <!-- Botão Menu Mobile (Telas < lg) -->
        <button
          type="button"
          @click="mobileMenuOpen = !mobileMenuOpen"
          class="lg:hidden p-2 rounded-xl text-slate-300 hover:text-white hover:bg-white/[0.08] border border-white/10 transition cursor-pointer"
          aria-label="Abrir Menu de Navegação"
        >
          <Menu v-if="!mobileMenuOpen" class="w-5 h-5" />
          <X v-else class="w-5 h-5" />
        </button>
      </div>
    </div>

    <!-- PASSO 2: PAINEL TRANSLÚCIDO DO MEGA MENU (Desktop Hover Experience) -->
    <Transition
      enter-active-class="transition duration-200 ease-out"
      enter-from-class="opacity-0 -translate-y-2"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition duration-150 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 -translate-y-2"
    >
      <div
        v-if="activeVertical"
        class="absolute top-full inset-x-0 w-full z-50 backdrop-blur-xl bg-[#002936]/95 border-b border-slate-700/50 shadow-2xl"
        @mouseenter="cancelClose"
        @mouseleave="scheduleClose"
      >
        <div class="max-w-7xl mx-auto px-6 lg:px-8 py-8 space-y-7">
          <!-- Cabeçalho do Mega Menu: Identidade da Vertical & Link Direto para o Hub -->
          <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 pb-5 border-b border-white/10">
            <div class="space-y-1.5">
              <div class="flex items-center gap-2.5">
                <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#D96826]/20 border border-[#D96826]/40 text-[#F28C28] text-xs font-bold uppercase tracking-wider">
                  <component :is="activeVertical.icon" class="w-3.5 h-3.5" />
                  {{ activeVertical.categoryBadge }}
                </span>
                <span class="text-xs font-medium text-slate-400">Ecossistema Corporativo LIT Capital</span>
              </div>
              <h3 class="text-xl sm:text-2xl font-extrabold text-white tracking-tight">
                {{ activeVertical.headline }}
              </h3>
              <p class="text-xs sm:text-sm text-slate-300 max-w-3xl leading-relaxed">
                {{ activeVertical.description }}
              </p>
            </div>

            <NuxtLink
              :to="activeVertical.to"
              class="inline-flex items-center gap-2 self-start sm:self-center px-4 py-2.5 rounded-xl bg-white/[0.08] hover:bg-white/[0.14] border border-white/15 text-xs sm:text-sm font-bold text-white hover:text-[#F28C28] transition group shrink-0 cursor-pointer"
            >
              <span>{{ activeVertical.hubText }}</span>
              <ArrowRight class="w-4 h-4 group-hover:translate-x-1 transition-transform" />
            </NuxtLink>
          </div>

          <!-- Grid de Duas Colunas: Serviços Nativos vs Marketplace B2B Homologado -->
          <div class="grid grid-cols-1 lg:grid-cols-12 gap-8">
            <!-- COLUNA 1: Serviços da Plataforma (Nativo ImobiLit) -->
            <div class="lg:col-span-7 space-y-4">
              <div class="flex items-center justify-between">
                <div>
                  <h4 class="text-xs font-bold uppercase tracking-wider text-slate-300 flex items-center gap-2">
                    <Sparkles class="w-3.5 h-3.5 text-[#F28C28]" />
                    Serviços da Plataforma (Nativo ImobiLit)
                  </h4>
                  <p class="text-[11px] text-slate-400 mt-0.5">
                    Funcionalidades integradas, esteiras digitais e inteligência transacional nativa.
                  </p>
                </div>
              </div>

              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                <NuxtLink
                  v-for="service in activeVertical.platformServices"
                  :key="service.title"
                  :to="service.to"
                  class="group p-4 rounded-2xl bg-white/[0.03] hover:bg-white/[0.07] border border-white/10 hover:border-[#D96826]/40 transition flex flex-col justify-between space-y-2.5 cursor-pointer"
                >
                  <div class="flex items-start gap-3">
                    <div class="w-9 h-9 rounded-xl bg-[#00384A] border border-white/10 flex items-center justify-center text-[#F28C28] shrink-0 group-hover:scale-105 transition-transform">
                      <component :is="service.icon" class="w-4 h-4" />
                    </div>
                    <div class="min-w-0 flex-1">
                      <h5 class="text-sm font-bold text-white group-hover:text-[#F28C28] transition-colors line-clamp-1">
                        {{ service.title }}
                      </h5>
                      <p class="text-xs text-slate-300 mt-1 leading-relaxed line-clamp-2">
                        {{ service.description }}
                      </p>
                    </div>
                  </div>

                  <div class="flex items-center justify-end text-[11px] font-semibold text-slate-400 group-hover:text-white pt-1">
                    <span class="inline-flex items-center gap-1 group-hover:translate-x-0.5 transition-transform">
                      Acessar funcionalidade →
                    </span>
                  </div>
                </NuxtLink>
              </div>
            </div>

            <!-- COLUNA 2: Marketplace B2B Curado (Parceiros Homologados LIT) -->
            <div class="lg:col-span-5">
              <div class="h-full rounded-2xl bg-gradient-to-br from-[#001D27] to-[#07161F] border border-[#D96826]/35 p-6 shadow-xl flex flex-col justify-between space-y-5 relative overflow-hidden">
                <!-- Efeito sutil de brilho no fundo -->
                <div class="absolute top-0 right-0 w-48 h-48 bg-[#D96826]/10 rounded-full blur-2xl pointer-events-none" />

                <div class="space-y-4 relative z-10">
                  <div class="flex items-center justify-between">
                    <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#D96826]/15 border border-[#D96826]/35 text-[#F28C28] text-xs font-bold">
                      <BadgeCheck class="w-4 h-4 text-[#F28C28]" />
                      {{ activeVertical.b2bPartners.badge }}
                    </span>
                    <span class="text-[11px] text-emerald-400 font-semibold flex items-center gap-1">
                      <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                      Auditoria Ativa
                    </span>
                  </div>

                  <div>
                    <h4 class="text-base font-bold text-white">
                      {{ activeVertical.b2bPartners.title }}
                    </h4>
                    <p class="text-xs text-slate-300 mt-1 leading-relaxed">
                      {{ activeVertical.b2bPartners.description }}
                    </p>
                  </div>

                  <!-- Lista de Serviços B2B Homologados -->
                  <div class="space-y-3 pt-2">
                    <div
                      v-for="(partner, idx) in activeVertical.b2bPartners.items"
                      :key="idx"
                      class="flex items-start gap-3 p-2.5 rounded-xl bg-white/[0.04] border border-white/5"
                    >
                      <CheckCircle2 class="w-4 h-4 text-[#F28C28] shrink-0 mt-0.5" />
                      <div class="min-w-0">
                        <p class="text-xs font-bold text-white">
                          {{ partner.title }}
                        </p>
                        <p class="text-[11px] text-slate-300 mt-0.5 leading-snug">
                          {{ partner.description }}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Ação da Coluna B2B -->
                <div class="pt-2 relative z-10 border-t border-white/10">
                  <NuxtLink
                    :to="activeVertical.b2bPartners.ctaTo"
                    class="w-full inline-flex items-center justify-center gap-2 py-2.5 px-4 rounded-xl bg-[#00384A] hover:bg-[#00485E] border border-white/10 hover:border-[#D96826]/40 text-xs sm:text-sm font-bold text-white hover:text-[#F28C28] transition cursor-pointer shadow-md"
                  >
                    <span>{{ activeVertical.b2bPartners.ctaText }}</span>
                    <ArrowRight class="w-4 h-4" />
                  </NuxtLink>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Transition>

    <!-- MENU MOBILE / GAVETA RESPONSIVA (Telas < lg) -->
    <Transition
      enter-active-class="transition duration-200 ease-out"
      enter-from-class="opacity-0 translate-y-2"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition duration-150 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 translate-y-2"
    >
      <div
        v-if="mobileMenuOpen"
        class="lg:hidden bg-[#002430] border-b border-slate-700 max-h-[85vh] overflow-y-auto p-4 space-y-6 shadow-2xl"
      >
        <!-- Seletor de Verticais Mobile -->
        <div class="space-y-2">
          <p class="text-xs font-bold uppercase tracking-wider text-slate-400">
            6 Verticais de Negócio LIT Capital
          </p>
          <div class="grid grid-cols-2 gap-2">
            <button
              v-for="v in verticals"
              :key="v.id"
              type="button"
              @click="mobileActiveVerticalId = v.id"
              :class="[
                'p-2.5 rounded-xl text-left text-xs font-bold transition flex items-center gap-2',
                mobileActiveVerticalId === v.id
                  ? 'bg-gradient-to-r from-[#D96826] to-[#F28C28] text-white shadow-md'
                  : 'bg-white/5 text-slate-300 hover:bg-white/10'
              ]"
            >
              <component :is="v.icon" class="w-4 h-4 shrink-0" />
              <span class="truncate">{{ v.shortName }}</span>
            </button>
          </div>
        </div>

        <!-- Conteúdo da Vertical Selecionada no Mobile -->
        <div class="space-y-4 pt-2 border-t border-white/10">
          <div>
            <span class="text-[11px] font-bold text-[#F28C28] uppercase">
              {{ mobileActiveVertical.categoryBadge }}
            </span>
            <h4 class="text-base font-bold text-white">
              {{ mobileActiveVertical.headline }}
            </h4>
            <p class="text-xs text-slate-300 mt-1">
              {{ mobileActiveVertical.description }}
            </p>
          </div>

          <!-- Serviços Nativos Mobile -->
          <div class="space-y-2">
            <p class="text-[11px] font-bold uppercase text-slate-400">
              Serviços da Plataforma
            </p>
            <div class="space-y-2">
              <NuxtLink
                v-for="service in mobileActiveVertical.platformServices"
                :key="service.title"
                :to="service.to"
                @click="mobileMenuOpen = false"
                class="block p-3 rounded-xl bg-white/5 border border-white/5 hover:border-[#D96826]/40"
              >
                <div class="flex items-center gap-2 text-xs font-bold text-white">
                  <component :is="service.icon" class="w-3.5 h-3.5 text-[#F28C28]" />
                  <span>{{ service.title }}</span>
                </div>
                <p class="text-[11px] text-slate-400 mt-1">
                  {{ service.description }}
                </p>
              </NuxtLink>
            </div>
          </div>

          <!-- Marketplace B2B Mobile -->
          <div class="p-4 rounded-xl bg-[#001D27] border border-[#D96826]/30 space-y-3">
            <div class="flex items-center gap-1.5 text-xs font-bold text-[#F28C28]">
              <BadgeCheck class="w-4 h-4" />
              <span>{{ mobileActiveVertical.b2bPartners.title }}</span>
            </div>
            <p class="text-xs text-slate-300">
              {{ mobileActiveVertical.b2bPartners.description }}
            </p>
            <NuxtLink
              :to="mobileActiveVertical.b2bPartners.ctaTo"
              @click="mobileMenuOpen = false"
              class="w-full inline-flex items-center justify-center gap-2 py-2 px-3 rounded-lg bg-[#00384A] text-xs font-bold text-white hover:text-[#F28C28]"
            >
              <span>{{ mobileActiveVertical.b2bPartners.ctaText }}</span>
              <ArrowRight class="w-3.5 h-3.5" />
            </NuxtLink>
          </div>
        </div>

        <!-- Ações de Conta no Rodapé Mobile -->
        <div class="pt-4 border-t border-white/10 space-y-2">
          <template v-if="user">
            <NuxtLink
              to="/dashboard"
              @click="mobileMenuOpen = false"
              class="w-full py-2.5 px-4 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] text-white text-xs font-bold text-center flex items-center justify-center gap-2"
            >
              <ShieldCheck class="w-4 h-4" />
              <span>Acessar Meu Painel</span>
            </NuxtLink>
            <NuxtLink
              to="/dashboard/meus-anuncios"
              @click="mobileMenuOpen = false"
              class="w-full py-2.5 px-4 rounded-xl bg-white/5 border border-white/10 text-white text-xs font-bold text-center block"
            >
              Meus Anúncios
            </NuxtLink>
          </template>
          <template v-else>
            <NuxtLink
              to="/cadastro"
              @click="mobileMenuOpen = false"
              class="w-full py-2.5 px-4 rounded-xl bg-gradient-to-r from-[#D96826] to-[#F28C28] text-white text-xs font-bold text-center block"
            >
              Criar Conta / Anunciar
            </NuxtLink>
            <NuxtLink
              to="/login"
              @click="mobileMenuOpen = false"
              class="w-full py-2.5 px-4 rounded-xl bg-white/5 border border-white/10 text-white text-xs font-bold text-center block"
            >
              Acessar com E-mail e Senha
            </NuxtLink>
          </template>
        </div>
      </div>
    </Transition>
  </header>
</template>
