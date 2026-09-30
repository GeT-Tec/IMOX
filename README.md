# IMOX - Portal Imobiliário Analítico

**Especificação Técnica V1.2 - Sr. Lake Engenharia de Software**

Um portal imobiliário de alta performance, construído sob o paradigma mobile-first com comportamento *app-like*. A solução traz análises aprofundadas de mercado, histórico de transações e busca cartográfica interativa (inspirado no HouseSigma), alimentado por dados extraídos de forma resiliente do mercado (inspirado no modelo NewCore).

---

## 🏗 Arquitetura da Solução (100% TypeScript)

O projeto adota uma arquitetura desacoplada e serverless, unificada em **TypeScript**, focada em altíssima velocidade, segurança e ingestão robusta de dados:

* **Frontend (Camada de Apresentação):** Next.js (TypeScript), configurado como PWA. Utiliza renderização híbrida (SSR/ISR) para indexação SEO (Páginas de Imóveis) e Client-side puro para interações de mapa contínuas.
* **Backend (BaaS e Motor Espacial):** Supabase Cloud operando PostgreSQL 15+. Utiliza nativamente a extensão `PostGIS` para consultas espaciais ultrarrápidas, expondo os dados via `PostgREST`.
* **Motor de Ingestão (Worker/Crawler):** Escrito em Node.js/TypeScript. Utiliza **Crawlee + Playwright + Cheerio** em ambiente *headless* para bypass de renderizações SPA, interceptando o tráfego interno (XHR/JSON) da origem. Integração altamente otimizada via `supabase-js`. Hospedado via Docker na Railway.
* **Serviços Complementares (Geocoding):** Edge Functions (Deno/TS) no Supabase atuando como proxy seguro para a API do Mapbox.

## 🚀 Principais Funcionalidades

* **Busca Cartográfica Avançada:** Motor visual baseado em Mapbox GL JS / MapLibre. Recálculos dinâmicos por *bounding box* da tela e clustering nativo.
* **Histórico Transacional:** Cada imóvel monitorado possui registro cronológico imutável de alterações de preço (`price_history`), plotados em gráficos evolutivos para o cliente.
* **Painel Analytics (Market Stats):** Medianas de metro quadrado, velocidade de absorção e volume de ofertas segmentados por bairros e zonas geográficas.
* **Watched (Avisos em Tempo Real):** Uso de *Supabase Realtime* (WebSockets) para notificar instantaneamente o usuário se um imóvel favoritado sofrer variação de preço.

## 🗺️ Fases de Implementação

O desenvolvimento está estruturado nas seguintes etapas lineares:

- [ ] **Fase 1: Ingestão e Infraestrutura Base**
  - Provisionamento Supabase e ativação PostGIS.
  - Construção do motor de extração TypeScript com Crawlee/Playwright (Interceptação XHR).
- [ ] **Fase 2: Dados e Motor Geoespacial**
  - Aplicação de regras estritas de Row Level Security (RLS).
  - Indexação espacial de buscas e similaridade de imóveis.
- [ ] **Fase 3: Construção da UI (Front-end)**
  - Setup do Next.js (PWA, Tailwind).
  - Componentização: Tabs inferiores, Listing Cards, Mapbox e Detalhe.
- [ ] **Fase 4: Analytics e Módulos Reativos**
  - Dashboards macroeconômicos e painel "Watched" em realtime.

## 🔒 Diretrizes de Segurança

1. **Isolamento de Chaves:** A `SUPABASE_SERVICE_ROLE_KEY` é de uso exclusivo do Crawler Node.js. O cliente Next.js operará **apenas** com a chave `NEXT_PUBLIC_SUPABASE_ANON_KEY`.
2. **Imutabilidade Pública:** Todas as operações que não sejam de leitura (`SELECT`) são travadas na base por **RLS**, impedindo adulterações de preços via injeção externa no PostgREST.
3. **Throttling no Scraper:** Limite rígido de ingestão (1 req / 2s + Exponential Backoff) gerenciado nativamente pelo Crawlee, garantindo respeito às políticas de uso do alvo e evitando bloqueios de WAF.
