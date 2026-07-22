# migarden — Documentação de Arquitetura

## 1. Visão Geral da Arquitetura (Macro)

### Stack Principal

| Camada | Tecnologia |
|--------|-----------|
| Runtime | Ruby 3.3.0 |
| Framework | Rails 7.0 |
| Banco de Dados | PostgreSQL 16 |
| Job Queue | Solid Queue (DB-backed, sem Redis) |
| File Storage | Active Storage (local) |
| Frontend | ERB + Hotwire (Turbo + Stimulus) |
| JS Bundling | Importmap |
| Auth | bcrypt + sessão (sem Devise) |
| WhatsApp | CallMeBot API |
| Monitoramento | Sentry + NewRelic + Lograge |
| Containerização | Docker (dev) + Docker.prod (prod) |
| Deploy | Railway |

### Arquitetura em Camadas

```
┌─────────────────────────────────────────────────────────────┐
│                    Browser (Usuário)                        │
└─────────────────────┬───────────────────────────────────────┘
                      │ HTTPS
┌─────────────────────▼───────────────────────────────────────┐
│              Railway Platform (Docker)                       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Rails App (Puma)                                    │   │
│  │  ┌──────────┐  ┌──────────┐  ┌───────────────────┐   │   │
│  │  │ Router   │→│ Controller│→│ Model (AR)        │   │   │
│  │  └──────────┘  └──────────┘  └───────┬───────────┘   │   │
│  │  ┌──────────┐  ┌──────────┐          │               │   │
│  │  │ Views    │←│ Turbo    │          │               │   │
│  │  │ (ERB)    │  │ Streams  │          │               │   │
│  │  └──────────┘  └──────────┘          │               │   │
│  └──────────────────────────────────────┼────────────────┘   │
│                                         │                    │
│  ┌─────────────────────────┐  ┌─────────▼──────────────┐     │
│  │ Active Storage (fotos)  │  │ PostgreSQL              │     │
│  └─────────────────────────┘  │  ├─ users               │     │
│                                │  ├─ plants              │     │
│  ┌─────────────────────────┐  │  ├─ care_parameters     │     │
│  │ Worker (Solid Queue)    │  │  ├─ care_logs           │     │
│  │  └─ PlantReminderJob    │  │  └─ solid_queue_*       │     │
│  └────────┬────────────────┘  └────────────────────────┘     │
└───────────┼───────────────────────────────────────────────────┘
            │ HTTP GET
┌───────────▼───────────────────────────────────────────────────┐
│  CallMeBot (WhatsApp API)                                     │
└───────────────────────────────────────────────────────────────┘
```

### Diagramas Interativos

Abra no navegador:

- **`docs/migarden-architecture.html`** — Diagrama completo de componentes, boundaries e conexões. Inclui 3 guided views (request path, background jobs, photo upload).
- **`docs/daily-reminder-flow.html`** — Sequência do job diário: schedule → Solid Queue → worker → query → WhatsApp.
- **`docs/mark-care-flow.html`** — Sequência do usuário marcando cuidado como realizado: clique → controller → CareLog → redirect.
- **`docs/plant-care-lifecycle.html`** — Máquina de estados do ciclo de cuidado: Cadastrada → Em Dia → Atrasada → Cuidado Feito.

---

## 2. Fluxos de Dados Críticos

### 2.1 Marcação de Cuidado (Ex: "Marcar como Regada")

```
Usuário                    Controller                CareLog
   │                           │                        │
   │ PATCH /plants/1/          │                        │
   │   mark_as_watered         │                        │
   ├──────────────────────────►│                        │
   │                           │ authenticate_user!     │
   │                           │── (session check)      │
   │                           │                        │
   │                           │ current_user.plants    │
   │                           │   .find(params[:id])   │
   │                           │── scoped query ───────►│
   │                           │◄── plant object ───────│
   │                           │                        │
   │                           │ create!(               │
   │                           │   action_type: :watering│
   │                           │   performed_at: today   │
   │                           │ )─────────────────────►│
   │                           │◄── persisted ──────────│
   │                           │                        │
   │ redirect_to @plant        │                        │
   │◄──────────────────────────│                        │
```

**Regra de segurança**: `Plant.find(params[:id])` NUNCA é usado. A busca é sempre `current_user.plants.find(...)`, garantindo isolamento entre usuários.

### 2.2 Job Diário de Lembretes (08:00)

```
Scheduler              Solid Queue        Worker              DB              CallMeBot
   │                       │                │                  │                  │
   │ enqueue job           │                │                  │                  │
   ├──────────────────────►│                │                  │                  │
   │                       │ dequeue 08:00  │                  │                  │
   │                       ├───────────────►│                  │                  │
   │                       │                │ perform           │                  │
   │                       │                ├─────────────────►│                  │
   │                       │                │ User.includes(    │                  │
   │                       │                │   :plants)        │                  │
   │                       │                │◄── users+plants ─│                  │
   │                       │                │                  │                  │
   │                       │                │ for each plant:   │                  │
   │                       │                │ needs_watering?   │                  │
   │                       │                │ needs_fert?       │                  │
   │                       │                │ needs_pest?       │                  │
   │                       │                │                  │                  │
   │                       │                │ build_message     │                  │
   │                       │                │                                     │
   │                       │                │ send_message ──────────────────────►│
   │                       │                │◄── HTTP 200 ────────────────────────│
   │                       │                │                                     │
   │                       │ reschedule     │                                     │
   │                       │◄───────────────│                                     │
```

**Auto-reschedule**: O job se reagenda para o próximo dia às 08:00 via `wait_until`, sem necessidade de cron externo.

### 2.3 Upload de Foto (Active Storage)

```
Browser                 Rails App              Active Storage      Disco
   │                       │                       │                │
   │ multipart form        │                       │                │
   │ (file field)          │                       │                │
   ├──────────────────────►│                       │                │
   │                       │ has_one_attached      │                │
   │                       │   :photo              │                │
   │                       │ plant.save            │                │
   │                       ├──────────────────────►│                │
   │                       │                       │ store file     │
   │                       │                       ├───────────────►│
   │                       │                       │◄── stored ─────│
   │                       │◄── attachment saved ──│                │
   │◄── redirect ──────────│                       │                │
```

---

## 3. Guia de Análise de Código

### 3.1 Estrutura de Diretórios

```
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb    # Auth base (current_user, authenticate_user!)
│   │   ├── sessions_controller.rb       # Login/logout
│   │   ├── users_controller.rb          # Cadastro
│   │   ├── dashboard_controller.rb      # Home page com resumo
│   │   ├── plants_controller.rb         # CRUD + mark_as_* actions
│   │   ├── settings_controller.rb       # CallMeBot config + test
│   │   └── alerts_controller.rb         # Plantas precisando cuidado
│   ├── models/
│   │   ├── user.rb                      # has_secure_password + has_many :plants
│   │   ├── plant.rb                     # belongs_to :user, has_many care_*
│   │   ├── care_parameter.rb            # action_type + interval_days
│   │   └── care_log.rb                  # action_type + performed_at
│   ├── jobs/
│   │   └── plant_reminder_job.rb        # Job diário de lembretes
│   ├── services/
│   │   └── whatsapp_notifier.rb         # Integração CallMeBot
│   └── views/
│       ├── layouts/application.html.erb # Layout com sidebar/logged_in?
│       ├── shared/_sidebar.html.erb     # Navegação
│       ├── dashboard/index.html.erb     # Cards de resumo
│       └── plants/                      # CRUD views + partials
├── config/
│   ├── routes.rb                        # Rotas (root, resources, member)
│   ├── database.yml                     # PG + variáveis de ambiente
│   └── application.rb                   # active_job.queue_adapter = :solid_queue
├── db/
│   ├── schema.rb                        # Estrutura completa do banco
│   └── migrate/                         # Migrations
├── docker-compose.yml                   # Web + Worker + PostgreSQL
├── Dockerfile                           # Dev
├── Dockerfile.prod                      # Produção (Railway)
├── Procfile                             # web + worker
└── railway.json                         # Build config
```

### 3.2 Pontos-Chave de Análise

#### Camada de Controllers
- `ApplicationController` define `current_user` e `authenticate_user!` antes de qualquer ação
- `PlantsController` usa `before_action :set_plant` que sempre busca via `current_user.plants.find(params[:id])`
- `SessionsController` e `UsersController` usam `skip_before_action :authenticate_user!` para páginas públicas

#### Camada de Models
- `Plant#next_watering_date` etc. calculam via `CareLog` mais recente + `CareParameter#interval_days`
- `Plant#needs_watering?` compara `next_watering_date <= Date.current`
- `care_parameters` usa `accepts_nested_attributes_for` para criação em lote

#### Camada de Jobs
- `PlantReminderJob` usa `ensure` block para auto-reschedule via `reschedule_for_next_8am`
- Percorre `User.includes(plants: [:care_parameters, :care_logs])` para evitar N+1
- Usa `WhatsappNotifier.send_message(user, message)` que aceita credentials por usuário

#### Camada de Services
- `WhatsappNotifier` é stateless por conveniência (`self.send_message`)
- Suporta credentials por usuário (phone + api_key no model User)
- Timeout de 10s em produção para evitar blocking

### 3.3 Fluxo de Autenticação

```
1. POST /session (email + password)
2. User.find_by(email:)&.authenticate(password)
3. session[:user_id] = user.id
4. ApplicationController#authenticate_user! checka session[:user_id]
5. Logout: reset_session → redirect new_session_path
```

### 3.4 Segurança

| Aspecto | Implementação |
|---------|--------------|
| Senhas | `has_secure_password` (bcrypt) |
| Sessão | `session[:user_id]` em cookie criptografado |
| Isolamento | `current_user.plants.find()` — nunca `Plant.find()` |
| Credenciais WhatsApp | Por usuário (não global), armazenadas no banco |
| CSRF | Rails default `protect_from_forgery with: :exception` |

### 3.5 Modelo de Dados

```
User
├── id (PK)
├── name
├── email (unique)
├── password_digest
├── callmebot_phone
└── callmebot_api_key

Plant
├── id (PK)
├── name
├── plant_type
├── sun_exposure (sombra|meia_sombra|sol)
├── species
├── nickname
├── user_id (FK → users)
└── has_one_attached :photo

CareParameter
├── id (PK)
├── plant_id (FK → plants)
├── action_type (enum: watering|fertilization|insecticide)
└── interval_days (> 0, unique per plant + action_type)

CareLog
├── id (PK)
├── plant_id (FK → plants)
├── action_type (enum)
├── performed_at (date)
└── observation (text)
```

### 3.6 Ambiente Local

```bash
docker compose up    # Sobe web + worker + postgres
# Web: http://localhost:3000
# Worker: processa jobs da Solid Queue
```
