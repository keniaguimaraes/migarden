# 🎛️ GUIA VISUAL - Configurar no Dashboard Railway

## 1️⃣ ACESSAR RAILWAY

```
https://railway.app → Log in com GitHub → Ir para Dashboard
```

---

## 2️⃣ CRIAR NOVO PROJETO

```
┌─────────────────────────────┐
│   Dashboard                 │
│  ┌───────────────────────┐  │
│  │ NEW PROJECT           │  │
│  │                       │  │
│  │ Deploy from GitHub    │  │
│  │    [Conectar]         │  │
│  └───────────────────────┘  │
└─────────────────────────────┘

Clique em: "+ New Project"
         ↓
Escolha: "Deploy from GitHub repo"
         ↓
Autorize o GitHub
         ↓
Selecione: "migarden"
         ↓
Escolha branch: "main"
         ↓
Pronto! Projeto criado
```

---

## 3️⃣ ADICIONAR BANCO DE DADOS

```
Seu projeto Railway aberto:

┌──────────────────────────────────────┐
│ migarden Project                     │
│                                      │
│  [+ Add Service]  [Variables] ...    │
│                                      │
│  Services:                           │
│  ├─ app (seu Rails)                 │
│  └─ (nenhum banco ainda)            │
└──────────────────────────────────────┘

Passo a passo:
1. Clique em "+ Add Service"
2. Escolha "Database" (lado esquerdo)
3. Escolha "PostgreSQL"
4. Railway vai criar (leva 2-3 minutos)
5. Pronto! DATABASE_URL será auto preenchida
```

---

## 4️⃣ CONFIGURAR VARIÁVEIS DE AMBIENTE

```
Dashboard → Seu Projeto → [Variables] (aba superior)

┌──────────────────────────────────────┐
│ Variables                            │
│                                      │
│ [+ Add Variable]                     │
│                                      │
│ RAILS_ENV          = production  ✓   │
│ RAILS_MASTER_KEY   = abc123... ✓     │
│ SECRET_KEY_BASE    = xyz789... ✓     │
│ DATABASE_URL       = [Auto]     ✓   │
│ EVOLUTION_API_URL  = https://... ✓   │
│                                      │
│ [Salvar]                            │
└──────────────────────────────────────┘

COMO ADICIONAR CADA UMA:

┌─ Passo 1: Clique em "+ Add Variable"
│
├─ Passo 2: Digite o Nome (ex: RAILS_ENV)
│
├─ Passo 3: Digite o Valor (ex: production)
│
├─ Passo 4: Clique ✓ (salvar)
│
└─ Passo 5: Repita para todas abaixo
```

### Variáveis para Copiar-Colar

```
┌─────────────────────────────────────────┐
│ 1. RAILS_ENV                            │
│    Valor: production                    │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 2. RAILS_MASTER_KEY                     │
│    Valor: [cole aqui da saída do       │
│           rails secret local]           │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 3. SECRET_KEY_BASE                      │
│    Valor: [cole aqui de outro          │
│           rails secret]                 │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 4. LOG_LEVEL                            │
│    Valor: info                          │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 5. EVOLUTION_API_URL                    │
│    Valor: https://sua-api.com          │
│    (ou deixar vazio se não usar)        │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 6. EVOLUTION_API_KEY                    │
│    Valor: sua_chave_aqui                │
│    (ou deixar vazio se não usar)        │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 7. EVOLUTION_INSTANCE                   │
│    Valor: miGarden_prod                 │
│    (ou deixar vazio se não usar)        │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 8. USER_PHONE                           │
│    Valor: 5571992464928                 │
│    (seu número com DDI)                 │
└─────────────────────────────────────────┘
```

---

## 5️⃣ INICIAR DEPLOY

```
Após configurar variáveis:

┌──────────────────────────────────────┐
│ migarden Project                     │
│                                      │
│ [Variables] [Deployments]            │
│                                      │
│ Services:                            │
│ ├─ app (Rails)                      │
│ │  └─ Status: Ready                 │
│ │     [Deploy] [Settings]           │
│ │                                    │
│ └─ postgres (Database)              │
│    └─ Status: Connected             │
└──────────────────────────────────────┘

Clique em: [Deploy] no serviço "app"

Railway vai:
1. ✓ Fazer build (1-2 min)
2. ✓ Push da imagem
3. ✓ Iniciar container
4. ✓ Rodar migrations automaticamente
5. ✓ Iniciar web server (Puma)
```

---

## 6️⃣ ACOMPANHAR DEPLOY

```
┌──────────────────────────────────────┐
│ Deployments                          │
│                                      │
│ [#1] Deploy em progresso            │
│      Status: Building...             │
│      Tempo: 2 minutos                │
│                                      │
│      [Ver Logs Completos]            │
│                                      │
│      Logs:                           │
│      ─────────────────────────────   │
│      > Building image...             │
│      > Installing gems...            │
│      > Precompiling assets...        │
│      > Running migrations...         │
│      > 🟢 Migrations completed      │
│      > Starting Puma...              │
│      > 🟢 Puma started on port 3000 │
│                                      │
│      Status: ✅ Successfully deployed│
└──────────────────────────────────────┘

PROCURE POR ESTAS MENSAGENS:
✅ "Migrations completed"
✅ "Puma started"
✅ "Successfully deployed"

SE VER ERRO:
❌ "ERROR" → clique em "Ver Logs Completos"
❌ "Failed" → verifique variáveis
```

---

## 7️⃣ VERIFICAR SE ESTÁ RODANDO

```
┌──────────────────────────────────────┐
│ Services                             │
│                                      │
│ app (Rails)                          │
│ ├─ Status: Running ✅                │
│ ├─ URL: https://migarden-abc.up...  │
│ ├─ [Abrir] [Logs] [Settings]        │
│                                      │
│ postgres (Database)                  │
│ ├─ Status: Connected ✅              │
│ └─ [Connection info]                │
└──────────────────────────────────────┘

CLIQUE EM: [Abrir] ou copie a URL

Browser abre:
https://seu-dominio.up.railway.app

Você deve ver:
✅ Página da aplicação (sem erro)
✅ Lista de plantas (pode estar vazia)
✅ Sem erro 500
```

---

## 8️⃣ CONFIGURAR DOMÍNIO CUSTOMIZADO (Opcional)

```
Dashboard → Seu Projeto → [Settings]
                          ↓
Procure por: "Domains"
                          ↓
┌──────────────────────────────────────┐
│ Domains                              │
│                                      │
│ [+ Add Domain]                       │
│                                      │
│ ┌─────────────────────────────────┐  │
│ │ Escolha:                        │  │
│ │                                 │  │
│ │ ○ migarden.up.railway.app       │  │
│ │ ○ seu-dominio.com (seu próprio) │  │
│ │                                 │  │
│ │ [Adicionar]                     │  │
│ └─────────────────────────────────┘  │
└──────────────────────────────────────┘

Resultado:
- Se escolher railway.app: pronto!
- Se escolher seu domínio:
  1. Railway dará um CNAME
  2. Adicionar no seu DNS provider
  3. Aguardar 24h para propagar
```

---

## 9️⃣ VER LOGS EM TEMPO REAL

```
Dashboard → Seu Projeto → app (serviço) → [Logs]

┌──────────────────────────────────────┐
│ Logs - app                           │
│                                      │
│ [🔴 Live] [Filtrar] [Download]      │
│                                      │
│ 12:30:45 Started GET "/plants"      │
│ 12:30:45 Processing by Plants...    │
│ 12:30:45 Completed 200 OK in 145ms  │
│                                      │
│ 12:31:00 Started POST "/plants"     │
│ 12:31:00 Unpermitted parameter...   │
│ 12:31:00 Completed 422 Unproc...    │
│                                      │
│ [carregar mais]                      │
└──────────────────────────────────────┘

MONITORAR:
- GET / POST com status 200 = OK ✅
- Status 500 = Erro no código ❌
- Status 422 = Parâmetros inválidos ⚠️
```

---

## 🔟 VER LOGS DO WORKER (Sidekiq)

```
Dashboard → Seu Projeto → [Services]

┌──────────────────────────────────────┐
│ Services                             │
│                                      │
│ app (Rails Web Server)               │
│ ├─ Status: Running ✅                │
│ └─ [Logs]                           │
│                                      │
│ worker (Sidekiq)                     │
│ ├─ Status: Running ✅                │
│ └─ [Logs]  ← Clique aqui             │
│                                      │
│ postgres (Database)                  │
│ ├─ Status: Connected ✅              │
│ └─ [Connection]                     │
└──────────────────────────────────────┘

Logs do Worker:
┌──────────────────────────────────────┐
│ 2026-05-08T12:30:00 INFO: Sidekiq... │
│ 2026-05-08T12:30:00 INFO: Worker... │
│ 2026-05-08T12:30:05 INFO: Job com..  │
│                                      │
│ ✅ Significa que está rodando!       │
└──────────────────────────────────────┘
```

---

## 1️⃣1️⃣ ATIVAR AUTO DEPLOY

```
Dashboard → Seu Projeto → [Settings]
                          ↓
Procure: "Auto Deploy"
                          ↓
┌──────────────────────────────────────┐
│ Auto Deploy                          │
│                                      │
│ Ativar auto deploy ao fazer push     │
│ em branches selecionadas:            │
│                                      │
│ [☐] main   ← ATIVAR                  │
│ [☐] develop                          │
│ [☐] staging                          │
│                                      │
│ [Salvar]                             │
└──────────────────────────────────────┘

BENEFÍCIO:
- Cada git push no main = deploy automático
- Não precisa clicar "Deploy" manualmente
- Pipeline CI/CD automático
```

---

## 1️⃣2️⃣ MONITORAR ALERTAS

```
Dashboard → Seu Projeto → [Settings]
                          ↓
Procure: "Alerts"
                          ↓
┌──────────────────────────────────────┐
│ Alerts                               │
│                                      │
│ [☐] Build Failure                    │
│ [☐] Deployment Failure               │
│ [☐] Service Crashed                  │
│ [☐] Database Connection Lost         │
│                                      │
│ Notificação: Email                   │
│                                      │
│ [Salvar]                             │
└──────────────────────────────────────┘

Railway enviará email se algo quebrar!
```

---

## 📊 RESUMO DO DASHBOARD

```
┌─ RAILWAY DASHBOARD (Visão Geral)
│
├─ Projects (seu migarden)
│  ├─ Services
│  │  ├─ app (Rails) ← Seu código
│  │  ├─ worker (Sidekiq) ← Background jobs
│  │  └─ postgres (Database) ← Seus dados
│  │
│  ├─ Variables ← Configurações (RAILS_ENV, etc)
│  ├─ Logs ← Ver o que está acontecendo
│  ├─ Deployments ← Histórico de deploys
│  └─ Settings ← Domínio, auto-deploy, alertas
│
└─ Account (seu perfil)
   ├─ Billing ← Créditos/plano
   ├─ Members ← Adicionar time
   └─ Settings ← Configurações conta
```

---

**Agora você está pronto para deployar no Railway! 🚀**
