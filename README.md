# IMOX — Plataforma Imobiliária e de Ativos

O IMOX é uma plataforma em desenvolvimento para apresentação e gestão de imóveis e serviços relacionados. O repositório contém aplicações web, uma API e migrações do Supabase. **A implementação atual não corresponde integralmente à arquitetura ou às funcionalidades originalmente planejadas**: algumas telas usam dados fictícios, e integrações externas ainda estão em modo de demonstração ou aguardam configuração/homologação.

## Estado atual

- **Frontend Nuxt 3 (`frontend/`):** aplicação Vue/TypeScript integrada ao módulo Supabase e configurada para consumir a API FastAPI. Inclui páginas de acesso, painéis e áreas de imóveis, além de uma área administrativa. É o frontend verificado pelo pipeline de CI.
- **Frontend Next.js (`imox-app/`):** aplicação separada em Next.js/React/TypeScript, com páginas de imóveis, estatísticas e perfil. Os dados em `src/lib/data.ts` são explicitamente fictícios; essa aplicação ainda não deve ser tratada como integrada ao Supabase.
- **Backend FastAPI (`backend/`):** API em Python, com verificação de tokens Supabase e acesso administrativo ao Supabase no servidor. Inclui health check e rotas para pedidos de certidões/matrículas e webhooks ONR.
- **Supabase (`supabase/`):** configuração local e migrações SQL para o esquema, políticas de acesso, perfis, funções administrativas, pedidos de cartório e campos avançados da vitrine. A presença de migrações no repositório não significa que tenham sido aplicadas a um projeto remoto.
- **Integração ONR/SAEC:** o serviço possui modo simulado ativado por padrão (`ONR_MOCK_MODE=true`). O contrato e os campos de integração ainda precisam ser conferidos com a documentação oficial e homologados antes do uso real.

## Arquitetura no repositório

```text
frontend/       Nuxt 3 + Vue + TypeScript — frontend principal verificado pela CI
imox-app/       Next.js + React + TypeScript — frontend separado, com dados de demonstração
backend/        FastAPI + Python — API e integração com Supabase/ONR
supabase/       Configuração e migrações SQL
legacy_reference/Referência legada de interface
```

Há, portanto, **duas aplicações de frontend**, e a implementação não é “100% TypeScript”: o backend é Python. O repositório não contém atualmente o crawler Crawlee/Playwright, nem implementação comprovada de Mapbox/PostGIS para busca por área ou notificações Supabase Realtime descritos em propostas anteriores.

## Funcionalidades presentes no código

- Páginas e componentes de imóveis, dashboards, perfil, favoritos e administração nos frontends.
- Esquema Supabase com políticas e controles de acesso definidos por migrações.
- Endpoints de saúde da API (`GET /health`), solicitação de certidão e recebimento de webhook ONR.
- Armazenamento de documentos recebidos em bucket privado, no fluxo de cartório.

A existência de páginas ou tabelas não implica que todos os fluxos estejam conectados a dados reais. Em particular, a aplicação Next.js usa dados mock e o fluxo ONR inicia em modo simulado.

## Executar localmente

### Nuxt — `frontend/`

Requer Node.js 20 e npm.

```bash
cd frontend
cp .env.example .env
npm ci
npm run dev
```

Por padrão, o Nuxt aponta a API para `http://localhost:8000`. Configure as variáveis de ambiente conforme necessário. Para verificar tipos e gerar a build:

```bash
npm run typecheck
npm run build
```

### API — `backend/`

Requer Python 3.11 ou compatível com as dependências listadas.

```bash
cd backend
python -m venv .venv
# Linux/macOS:
source .venv/bin/activate
# Windows PowerShell: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload
```

A API fica disponível em `http://localhost:8000`; a documentação interativa do FastAPI, em `/docs`. Configure as variáveis do Supabase no `.env` para usar recursos que dependem do banco. O modo ONR simulado é o padrão; não configure credenciais reais sem validar o fluxo e o contrato com o provedor.

### Next.js — `imox-app/`

Requer Node.js e npm.

```bash
cd imox-app
cp .env.example .env.local
npm ci
npm run dev
```

Esta aplicação é independente do Nuxt e, atualmente, utiliza os dados de demonstração definidos em `src/lib/data.ts`.

## Banco de dados e segurança

- Revise as migrações em `supabase/migrations/` antes de aplicá-las ao ambiente desejado.
- Nunca versione arquivos `.env` preenchidos, senhas ou chaves secretas.
- `SUPABASE_SERVICE_ROLE_KEY` é uma credencial privilegiada: mantenha-a somente no ambiente seguro do backend. Nunca a exponha em código ou variáveis públicas do frontend.
- Use apenas chaves públicas nos clientes web e mantenha as políticas RLS apropriadas no Supabase. A chave pública, por si só, não substitui as políticas de acesso.
- Configure o segredo de webhook, CORS e hosts permitidos para documentos antes de expor a API em produção.

## Integração contínua

O workflow em `.github/workflows/ci.yml` executa verificação de tipos e build do Nuxt, além de um smoke test do health check da API. O Next.js e as migrações SQL não são validados por esse workflow atualmente.

## Próximos passos

- Definir qual frontend será a experiência principal e alinhar o outro a essa decisão.
- Substituir dados fictícios por integração real onde aplicável e documentar claramente o que ainda é mock.
- Validar e homologar a integração ONR/SAEC com o contrato oficial.
- Adicionar testes e verificações de CI para o Next.js e para as migrações.
- Implementar e documentar separadamente crawler, busca geoespacial e notificações em tempo real caso continuem no escopo do produto.
