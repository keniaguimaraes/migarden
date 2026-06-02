# migarden

Um jardim inteligente, simples e pessoal, para lembrar você de cuidar das suas plantas.

> Stack: Ruby on Rails 7 · PostgreSQL · Solid Queue · Active Storage · WhatsApp via CallMeBot

---

## Sumário

1. [Visão geral](#visão-geral)
2. [Setup local com Docker](#setup-local-com-docker)
3. [Setup local sem Docker](#setup-local-sem-docker)
4. [Configuração do WhatsApp (CallMeBot)](#configuração-do-whatsapp-callmebot)
5. [Variáveis de ambiente](#variáveis-de-ambiente)
6. [Comandos úteis](#comandos-úteis)
7. [Testes](#testes)
8. [Deploy no Railway](#deploy-no-railway)
9. [Arquitetura](#arquitetura)

---

## Visão geral

migarden é um MVP pessoal para gestão de plantas. Calcula a próxima data de rega, fertilização e controle de pragas a partir de um histórico de cuidados por planta, e envia lembretes diários via WhatsApp usando a API gratuita do [CallMeBot](https://www.callmebot.com).

Recursos:

- Cadastro de plantas com foto, tipo, espécie, apelido e exposição solar
- Frequências individuais de rega, fertilização e controle de pragas
- Histórico completo de cada cuidado (modelo normalizado `CareLog`)
- Dashboard com cards de resumo e plantas que precisam de atenção
- Lembretes diários às 08:00 via WhatsApp (Solid Queue + CallMeBot)
- Autenticação manual com `has_secure_password` (bcrypt)
- Active Storage para upload de fotos

---

## Setup local com Docker

```bash
cp .env.example .env
docker compose up -d
docker compose exec web bin/rails db:create db:migrate
docker compose exec web bin/rails server
```

Acesse `http://localhost:3000`.

---

## Setup local sem Docker

Requisitos: Ruby 3.3.0, PostgreSQL 16, Node (para assets).

```bash
bundle install
bin/rails db:create db:migrate
bin/rails server
```

---

## Configuração do WhatsApp (CallMeBot)

O CallMeBot é um serviço gratuito para uso pessoal. Para habilitar o envio de mensagens para o seu número:

1. Salve o número **+34 644 59 71 47** nos seus contatos (apelido: CallMeBot).
2. Envie a mensagem `/start` para esse contato pelo WhatsApp.
3. O bot responde com sua **API key**.
4. No migarden, vá em **Configurações** e preencha:
   - **Telefone**: seu número com código do país (ex: `+5511999990000`).
   - **API key**: a chave devolvida pelo bot.

As credenciais são armazenadas no `User.callmebot_phone` e `User.callmebot_api_key` — cada usuário tem as suas.

---

## Variáveis de ambiente

Crie um `.env` a partir de `.env.example`. As variáveis são lidas por `config/database.yml` e pelo `WhatsappNotifier`.

| Variável | Obrigatória | Descrição |
|---|---|---|
| `DATABASE_URL` | dev/prod | URL completa do Postgres (ex: `postgres://user:pass@host:5432/db`) |
| `POSTGRES_USER` | dev | Usuário do Postgres (Docker) |
| `POSTGRES_PASSWORD` | dev | Senha do Postgres (Docker) |
| `POSTGRES_DB` | dev | Nome do banco de dev (Docker) |
| `RAILS_MASTER_KEY` | prod | Chave mestra para descriptografar `config/credentials.yml.enc` |
| `SECRET_KEY_BASE` | prod | Chave usada pelo Rails para assinar cookies e sessions |
| `PORT` | prod | Porta do servidor web (padrão: 3000) |
| `RAILS_ENV` | prod | Deve ser `production` no deploy |
| `RAILS_MAX_THREADS` | opcional | Threads do pool de conexões (padrão: 5) |

> **Per-user (não env)**: as credenciais CallMeBot ficam em `User.callmebot_phone` e `User.callmebot_api_key` por usuário, editáveis em **Configurações**.

---

## Comandos úteis

```bash
# Subir ambiente
docker compose up -d

# Console Rails
docker compose exec web bin/rails console

# Rodar migrations
docker compose exec web bin/rails db:migrate

# Reiniciar jobs (caso o agendamento 08h se perca)
docker compose exec worker bundle exec rake solid_queue:start

# Disparar o PlantReminderJob manualmente (sem esperar 08h)
docker compose exec web bin/rails runner "PlantReminderJob.perform_now"

# Reset completo do banco
docker compose exec web bin/rails db:drop db:create db:migrate db:seed
```

---

## Testes

```bash
docker compose exec web bin/rails db:test:prepare
docker compose exec web bin/rails test
```

Resultado esperado: **54 runs, 93 assertions, 0 failures, 0 errors**.

---

## Deploy no Railway

1. Crie um novo projeto no Railway e adicione um serviço **PostgreSQL**.
2. Conecte o repositório a um serviço **web** apontando para o `Dockerfile.prod`.
3. Adicione um serviço **worker** com o mesmo `Dockerfile.prod` e comando `bundle exec rake solid_queue:start`.
4. Configure as variáveis de ambiente (copie do `.env.example` e ajuste para produção):
   - `DATABASE_URL` (fornecida pelo plugin Postgres do Railway)
   - `RAILS_MASTER_KEY` (use `bin/rails credentials:edit` para gerar/visualizar)
   - `RAILS_SERVE_STATIC_FILES=true`
   - `RAILS_LOG_TO_STDOUT=true`
5. O `Procfile` já define a fase `release` que roda `db:migrate` automaticamente.
6. O `bin/docker-entrypoint` garante que migrations rodem também no boot em produção.

---

## Arquitetura

### Modelos

- **User** — autenticação + credenciais WhatsApp por usuário
- **Plant** — dados da planta + foto (Active Storage)
- **CareParameter** — frequência (em dias) de cada tipo de cuidado por planta
- **CareLog** — histórico de cada cuidado realizado

### Cálculo de próxima data

```
next_<action>_date = last_care_log.performed_at + care_parameter.interval_days
needs_<action>?    = next_<action>_date <= Date.current
```

### Job de lembretes

- `app/jobs/plant_reminder_job.rb` itera plantas que precisam de cuidado, monta a mensagem PT-BR e chama `WhatsappNotifier.send_message(user, message)`.
- Re-agenda a si mesmo para a próxima 08h após cada execução.
- `config/initializers/plant_reminder_schedule.rb` agenda o primeiro run no boot se nenhum estiver na fila.

### Pastas

```
app/
  controllers/   # Application, Sessions, Users, Plants, Dashboard, Settings, Alerts
  models/        # User, Plant, CareParameter, CareLog
  services/      # WhatsappNotifier
  jobs/          # PlantReminderJob
  views/         # auth + dashboard + plants CRUD + sidebar/flash partials
  assets/stylesheets/application.css  # tema botânico
config/
  initializers/  # plant_reminder_schedule
  routes.rb
db/
  migrate/       # users, plants (+ update), care_parameters, care_logs, active_storage, solid_queue
```

### Boas práticas aplicadas

- Autenticação obrigatória em todas as rotas, exceto `sessions#new/create` e `users#new/create`
- `set_plant` busca via `current_user.plants.find` — usuário nunca acessa planta de outro
- 3 serviços rodando no `docker-compose`: `web`, `worker`, `db`
- Mensagens de erro em PT-BR
- Validações nos modelos (presence, numericality, inclusion, uniqueness scoped)
