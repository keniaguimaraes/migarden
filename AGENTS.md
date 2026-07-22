# CLAUDE.md

## Contexto do Projeto

Este projeto será um sistema simples em **Ruby on Rails** chamado **migarden**, voltado para controle de cuidados com plantas.

O sistema deverá permitir cadastrar plantas e controlar:

* Nome da planta;
* Tipo da planta;
* Foto da planta;
* Frequência recomendada de rega;
* Tipo de exposição: sombra, meia sombra ou sol;
* Frequência de fertilização;
* Frequência de controle de pragas;
* Datas dos últimos cuidados realizados;
* Próximas datas previstas para rega, fertilização e controle de pragas;
* Envio de lembretes via WhatsApp.

O projeto será deployado em produção no **Railway**.

A stack principal será:

* Ruby on Rails;
* PostgreSQL;
* Active Storage;
* Sidekiq;
* Redis;
* CallMeBot para envio de mensagens via WhatsApp;
* Autenticação simples;
* Docker para ambiente local e produção.

---

## Nome Oficial do Projeto

O nome oficial do projeto será:

```text
migarden
```

Esse nome deve ser usado em:

* Layout;
* Sidebar;
* Dashboard;
* Títulos das páginas;
* README;
* Referências internas do projeto;
* Nome visual do sistema.

Comando sugerido para criação do projeto Rails:

```bash
rails new migarden -d postgresql
```

---

## Objetivo do Sistema

Criar um sistema pessoal para gerenciamento de plantas, com dashboard visual e lembretes automáticos por WhatsApp.

O sistema deve ajudar o usuário a saber:

* Quais plantas precisam ser regadas hoje;
* Quais plantas precisam ser fertilizadas;
* Quais plantas precisam de controle de pragas;
* Quais plantas estão com cuidados atrasados;
* Qual o status geral da coleção de plantas.

---

## Banco de Dados

Usar **PostgreSQL** como banco principal.

O projeto deve ser configurado para funcionar com PostgreSQL tanto em desenvolvimento quanto em produção.

O arquivo `config/database.yml` deve usar variáveis de ambiente, especialmente em produção.

Exemplo de variáveis esperadas:

```env
DATABASE_URL=postgresql://user:password@host:port/database
REDIS_URL=redis://default:password@host:port
CALLMEBOT_PHONE=5571999999999
CALLMEBOT_API_KEY=sua_api_key
SECRET_KEY_BASE=sua_secret_key
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
```

---

## Entidades Principais

### User

O sistema deve ter autenticação simples.

Campos sugeridos:

```ruby
email:string
password_digest:string
name:string
```

Usar `has_secure_password`.

Não usar Devise inicialmente, para manter o sistema simples.

O usuário deve conseguir:

* Criar conta;
* Fazer login;
* Fazer logout;
* Acessar apenas suas próprias plantas.

Relacionamento:

```ruby
User has_many :plants
Plant belongs_to :user
```

---

### Plant

A entidade principal será `Plant`.

Campos sugeridos:

```ruby
name:string
plant_type:string
sun_exposure:string
watering_frequency_days:integer
fertilization_frequency_days:integer
pest_control_frequency_days:integer
last_watered_at:date
last_fertilized_at:date
last_pest_control_at:date
user:references
```

A foto da planta deve ser controlada com **Active Storage**:

```ruby
has_one_attached :photo
```

Validações sugeridas:

```ruby
validates :name, presence: true
validates :plant_type, presence: true
validates :sun_exposure, presence: true
validates :watering_frequency_days, presence: true, numericality: { greater_than: 0 }
validates :fertilization_frequency_days, presence: true, numericality: { greater_than: 0 }
validates :pest_control_frequency_days, presence: true, numericality: { greater_than: 0 }
```

Valores possíveis para exposição solar:

```ruby
["sombra", "meia_sombra", "sol"]
```

---

## Métodos da Model Plant

A model `Plant` deve conter métodos para calcular os cuidados pendentes.

Exemplo:

```ruby
class Plant < ApplicationRecord
  belongs_to :user
  has_one_attached :photo

  validates :name, :plant_type, :sun_exposure, presence: true
  validates :watering_frequency_days,
            :fertilization_frequency_days,
            :pest_control_frequency_days,
            presence: true,
            numericality: { greater_than: 0 }

  def next_watering_date
    return Date.current if last_watered_at.blank?

    last_watered_at + watering_frequency_days.days
  end

  def next_fertilization_date
    return Date.current if last_fertilized_at.blank?

    last_fertilized_at + fertilization_frequency_days.days
  end

  def next_pest_control_date
    return Date.current if last_pest_control_at.blank?

    last_pest_control_at + pest_control_frequency_days.days
  end

  def needs_watering?
    next_watering_date <= Date.current
  end

  def needs_fertilization?
    next_fertilization_date <= Date.current
  end

  def needs_pest_control?
    next_pest_control_date <= Date.current
  end

  def care_status
    return "atrasada" if needs_watering? || needs_fertilization? || needs_pest_control?

    "em_dia"
  end
end
```

---

## Dashboard

O sistema deve ter uma página inicial autenticada com dashboard.

O dashboard deve mostrar:

* Total de plantas cadastradas;
* Quantidade de plantas que precisam de rega hoje;
* Quantidade de plantas que precisam de fertilização;
* Quantidade de plantas que precisam de controle de pragas;
* Cards com as plantas cadastradas;
* Status visual de cada planta;
* Próxima data de rega;
* Próxima data de fertilização;
* Próxima data de controle de pragas.

A rota principal após login deve ser:

```ruby
dashboard#index
```

Exemplo de rotas:

```ruby
root "dashboard#index"

resources :plants do
  member do
    patch :mark_as_watered
    patch :mark_as_fertilized
    patch :mark_as_pest_controlled
  end
end

resource :session, only: [:new, :create, :destroy]
resources :users, only: [:new, :create]
```

---

## Layout e Frontend

Usar um frontend simples, limpo e moderno.

Utilizar abordagem de **Frontend Design** para criar uma interface agradável, organizada e responsiva.

O sistema deve ter:

* Sidebar lateral;
* Dashboard;
* Cards de plantas;
* Formulários simples;
* Botões claros para marcar cuidado como realizado;
* Interface responsiva;
* Visual acolhedor e natural.

---

## Sidebar

A sidebar deve conter:

* Logo/nome do sistema: **migarden**;
* Dashboard;
* Minhas Plantas;
* Nova Planta;
* Alertas;
* Configurações;
* Sair.

Exemplo de estrutura:

```erb
<aside class="sidebar">
  <div class="sidebar__brand">
    🌿 migarden
  </div>

  <nav class="sidebar__nav">
    <%= link_to "Dashboard", root_path %>
    <%= link_to "Minhas Plantas", plants_path %>
    <%= link_to "Nova Planta", new_plant_path %>
    <%= link_to "Alertas", root_path %>
    <%= link_to "Configurações", root_path %>
    <%= button_to "Sair", session_path, method: :delete %>
  </nav>
</aside>
```

---

## Paleta de Cores

Usar como base:

```text
Branco gelo
Verde musgo
```

Cores sugeridas:

```css
--color-ice-white: #F7F8F4;
--color-moss-green: #556B2F;
--color-deep-green: #2F4F2F;
--color-soft-green: #DDE8D2;
--color-sage: #A8B89B;
--color-earth: #8B7355;
--color-text: #263128;
--color-muted: #6B7568;
--color-danger: #B94A48;
--color-warning: #C28B2C;
--color-success: #4F7D4F;
```

O layout deve transmitir sensação de:

* Organização;
* Natureza;
* Simplicidade;
* Cuidado;
* Leveza.

---

## Telas Principais

### 1. Login

Tela simples com:

* E-mail;
* Senha;
* Botão entrar;
* Link para criar conta.

---

### 2. Cadastro de Usuário

Campos:

* Nome;
* E-mail;
* Senha;
* Confirmação de senha.

---

### 3. Dashboard

Exibir cards de resumo:

```text
Total de plantas
Precisam de rega
Precisam de fertilização
Precisam de controle de pragas
```

Exibir lista/cards das plantas.

Cada card deve mostrar:

* Foto;
* Nome;
* Tipo;
* Exposição solar;
* Status;
* Próxima rega;
* Próxima fertilização;
* Próximo controle de pragas.

---

### 4. Cadastro de Planta

Campos:

* Nome;
* Tipo;
* Foto;
* Frequência de rega em dias;
* Exposição solar;
* Frequência de fertilização em dias;
* Frequência de controle de pragas em dias.

---

### 5. Detalhes da Planta

Mostrar informações completas da planta e botões:

```text
Marcar como regada
Marcar como fertilizada
Marcar controle de pragas realizado
Editar
Excluir
```

Quando clicar nos botões de cuidado realizado, atualizar as datas:

```ruby
last_watered_at = Date.current
last_fertilized_at = Date.current
last_pest_control_at = Date.current
```

---

## WhatsApp com CallMeBot

O sistema usará **CallMeBot** para envio de mensagens via WhatsApp.

Criar um service object:

```ruby
# app/services/whatsapp_notifier.rb

require "net/http"
require "uri"

class WhatsappNotifier
  def self.send_message(message)
    phone = ENV.fetch("CALLMEBOT_PHONE")
    api_key = ENV.fetch("CALLMEBOT_API_KEY")

    uri = URI("https://api.callmebot.com/whatsapp.php")
    uri.query = URI.encode_www_form(
      phone: phone,
      text: message,
      apikey: api_key
    )

    response = Net::HTTP.get_response(uri)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("[WhatsAppNotifier] Erro ao enviar mensagem: #{response.body}")
    end

    response
  rescue StandardError => e
    Rails.logger.error("[WhatsAppNotifier] Erro inesperado: #{e.message}")
    nil
  end
end
```

---

## Job de Lembretes

Criar um job para verificar diariamente quais plantas precisam de cuidado.

```ruby
# app/jobs/plant_reminder_job.rb

class PlantReminderJob < ApplicationJob
  queue_as :default

  def perform
    User.includes(:plants).find_each do |user|
      user.plants.find_each do |plant|
        pending_cares = []

        pending_cares << "regar" if plant.needs_watering?
        pending_cares << "fertilizar" if plant.needs_fertilization?
        pending_cares << "fazer controle de pragas" if plant.needs_pest_control?

        next if pending_cares.empty?

        message = <<~MSG
          🌱 Lembrete do migarden

          Planta: #{plant.name}
          Tipo: #{plant.plant_type}
          Hoje é dia de: #{pending_cares.to_sentence(locale: :pt)}

          💧 Próxima rega: #{plant.next_watering_date.strftime("%d/%m/%Y")}
          🧪 Próxima fertilização: #{plant.next_fertilization_date.strftime("%d/%m/%Y")}
          🐛 Próximo controle de pragas: #{plant.next_pest_control_date.strftime("%d/%m/%Y")}
        MSG

        WhatsappNotifier.send_message(message)
      end
    end
  end
end
```

---

## Sidekiq e Redis

Usar **Sidekiq** para processamento em background.

Adicionar ao `Gemfile`:

```ruby
gem "sidekiq"
gem "sidekiq-cron"
```

Configurar o Active Job:

```ruby
# config/application.rb

config.active_job.queue_adapter = :sidekiq
```

Configurar Sidekiq:

```ruby
# config/initializers/sidekiq.rb

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") }
end
```

---

## Agendamento Diário dos Lembretes

Usar `sidekiq-cron` para executar o job diariamente.

Criar:

```ruby
# config/initializers/sidekiq_cron.rb

if defined?(Sidekiq::Cron::Job)
  Sidekiq::Cron::Job.create(
    name: "migarden Plant Reminder Job",
    cron: "0 8 * * *",
    class: "PlantReminderJob"
  )
end
```

O job deve rodar todos os dias às 08h.

---

## Active Storage

Usar Active Storage para upload das fotos das plantas.

Executar ou gerar as migrations do Active Storage:

```bash
bin/rails active_storage:install
```

Em produção no Railway, usar inicialmente armazenamento local se for apenas MVP.

Para uma versão mais robusta, preparar o projeto para futuramente usar S3, Cloudflare R2 ou outro serviço compatível.

---

## Railway

O deploy será feito no Railway.

Como no Railway nem sempre é prático rodar manualmente:

```bash
rails db:migrate
```

ou

```bash
docker rake db:migrate
```

o projeto deve executar as migrations automaticamente no start da aplicação em produção.

Criar um script de entrypoint para produção.

Arquivo sugerido:

```bash
# bin/docker-entrypoint

#!/usr/bin/env bash
set -e

if [ "${RAILS_ENV}" = "production" ]; then
  echo "Running database migrations..."
  bundle exec rails db:migrate
fi

exec "$@"
```

Garantir permissão de execução:

```bash
chmod +x bin/docker-entrypoint
```

---

## Dockerfile para Desenvolvimento

Criar um arquivo:

```dockerfile
# Dockerfile

FROM ruby:3.3.0

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  postgresql-client \
  imagemagick \
  libvips \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
```

---

## Dockerfile para Produção

Criar um arquivo:

```dockerfile
# Dockerfile.prod

FROM ruby:3.3.0-slim

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  postgresql-client \
  libvips \
  curl \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT="development:test"

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

RUN chmod +x bin/docker-entrypoint

RUN bundle exec rails assets:precompile

EXPOSE 3000

ENTRYPOINT ["bin/docker-entrypoint"]

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
```

---

## Procfile Opcional para Railway

Caso o Railway use Procfile, criar:

```procfile
web: bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}
worker: bundle exec sidekiq
```

Mesmo usando Dockerfile.prod, manter esse arquivo pode ajudar na organização.

---

## Docker Compose para Desenvolvimento Local

Criar um arquivo `docker-compose.yml` para ambiente local:

```yaml
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
    command: bin/rails server -b 0.0.0.0
    volumes:
      - .:/app
    ports:
      - "3000:3000"
    environment:
      DATABASE_URL: postgres://postgres:password@db:5432/migarden_development
      REDIS_URL: redis://redis:6379/0
    depends_on:
      - db
      - redis

  worker:
    build:
      context: .
      dockerfile: Dockerfile
    command: bundle exec sidekiq
    volumes:
      - .:/app
    environment:
      DATABASE_URL: postgres://postgres:password@db:5432/migarden_development
      REDIS_URL: redis://redis:6379/0
    depends_on:
      - db
      - redis

  db:
    image: postgres:16
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: migarden_development
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

---

## Autenticação Simples

Implementar autenticação manual com `has_secure_password`.

Adicionar ao `Gemfile`:

```ruby
gem "bcrypt", "~> 3.1.7"
```

Model:

```ruby
class User < ApplicationRecord
  has_secure_password

  has_many :plants, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
```

Controller de sessões:

```ruby
class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Login realizado com sucesso."
    else
      flash.now[:alert] = "E-mail ou senha inválidos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to new_session_path, notice: "Você saiu do sistema."
  end
end
```

ApplicationController:

```ruby
class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def authenticate_user!
    redirect_to new_session_path, alert: "Faça login para continuar." unless current_user
  end
end
```

---

## Controllers Principais

Criar:

```text
UsersController
SessionsController
DashboardController
PlantsController
```

O `PlantsController` deve garantir que o usuário só acesse suas próprias plantas:

```ruby
def set_plant
  @plant = current_user.plants.find(params[:id])
end
```

Nunca buscar planta diretamente com:

```ruby
Plant.find(params[:id])
```

em ações autenticadas, para evitar que um usuário acesse planta de outro usuário.

---

## Ações de Cuidado

No `PlantsController`, criar ações:

```ruby
def mark_as_watered
  @plant.update!(last_watered_at: Date.current)
  redirect_to @plant, notice: "Planta marcada como regada."
end

def mark_as_fertilized
  @plant.update!(last_fertilized_at: Date.current)
  redirect_to @plant, notice: "Planta marcada como fertilizada."
end

def mark_as_pest_controlled
  @plant.update!(last_pest_control_at: Date.current)
  redirect_to @plant, notice: "Controle de pragas marcado como realizado."
end
```

---

## Boas Práticas

Seguir estas práticas:

* Código simples e legível;
* Models com regras de negócio pequenas e objetivas;
* Services para integrações externas;
* Jobs para tarefas assíncronas;
* Controllers enxutos;
* Views organizadas;
* Componentizar partials quando fizer sentido;
* Usar variáveis de ambiente para dados sensíveis;
* Não commitar `.env`;
* Não expor API key do CallMeBot;
* Não permitir acesso a plantas de outros usuários.

--- 

## Estrutura Visual Sugerida

Criar partials:

```text
app/views/shared/_sidebar.html.erb
app/views/shared/_flash.html.erb
app/views/plants/_form.html.erb
app/views/plants/_plant_card.html.erb
app/views/dashboard/index.html.erb
```

---

## Estilo Base

Criar um CSS com base na paleta definida.

Exemplo:

```css
:root {
  --color-ice-white: #F7F8F4;
  --color-moss-green: #556B2F;
  --color-deep-green: #2F4F2F;
  --color-soft-green: #DDE8D2;
  --color-sage: #A8B89B;
  --color-earth: #8B7355;
  --color-text: #263128;
  --color-muted: #6B7568;
  --color-danger: #B94A48;
  --color-warning: #C28B2C;
  --color-success: #4F7D4F;
}

body {
  margin: 0;
  background: var(--color-ice-white);
  color: var(--color-text);
  font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

.app-layout {
  display: flex;
  min-height: 100vh;
}

.sidebar {
  width: 260px;
  background: var(--color-deep-green);
  color: white;
  padding: 24px;
}

.sidebar a,
.sidebar button {
  display: block;
  color: white;
  text-decoration: none;
  margin-bottom: 12px;
  background: transparent;
  border: 0;
  font: inherit;
  cursor: pointer;
}

.main-content {
  flex: 1;
  padding: 32px;
}

.card {
  background: white;
  border-radius: 18px;
  padding: 20px;
  box-shadow: 0 10px 30px rgba(47, 79, 47, 0.08);
}

.btn-primary {
  background: var(--color-moss-green);
  color: white;
  border: 0;
  border-radius: 999px;
  padding: 10px 18px;
  cursor: pointer;
}
```

---

## Requisitos de Produção no Railway

O projeto deve estar pronto para produção com:

* PostgreSQL provisionado no Railway;
* Redis provisionado no Railway;
* Variáveis de ambiente configuradas;
* Worker Sidekiq rodando em serviço separado;
* Migrations automáticas no boot da aplicação;
* Logs enviados para STDOUT;
* Assets precompilados no build;
* Porta configurável por variável `PORT`.

O servidor Rails em produção deve usar:

```bash
bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}
```

Se o Dockerfile.prod não aceitar interpolação diretamente no `CMD`, criar script próprio para iniciar o servidor.

---

## Arquivos Esperados

Gerar ou ajustar os seguintes arquivos:

```text
Dockerfile
Dockerfile.prod
docker-compose.yml
Procfile
bin/docker-entrypoint
Gemfile
config/database.yml
config/routes.rb
config/application.rb
config/initializers/sidekiq.rb
config/initializers/sidekiq_cron.rb
app/models/user.rb
app/models/plant.rb
app/controllers/application_controller.rb
app/controllers/users_controller.rb
app/controllers/sessions_controller.rb
app/controllers/dashboard_controller.rb
app/controllers/plants_controller.rb
app/jobs/plant_reminder_job.rb
app/services/whatsapp_notifier.rb
app/views/shared/_sidebar.html.erb
app/views/shared/_flash.html.erb
app/views/dashboard/index.html.erb
app/views/plants/index.html.erb
app/views/plants/show.html.erb
app/views/plants/new.html.erb
app/views/plants/edit.html.erb
app/views/plants/_form.html.erb
app/views/plants/_plant_card.html.erb
```

---

## Prioridade de Implementação

Implementar nesta ordem:

1. Criar projeto Rails com PostgreSQL;
2. Configurar Docker local;
3. Criar autenticação simples;
4. Criar model `Plant`;
5. Configurar Active Storage;
6. Criar CRUD de plantas;
7. Criar dashboard;
8. Criar layout com sidebar;
9. Criar actions de marcar cuidado realizado;
10. Criar service de WhatsApp com CallMeBot;
11. Criar job de lembrete;
12. Configurar Sidekiq e Redis;
13. Configurar Dockerfile.prod;
14. Configurar migration automática no Railway;
15. Ajustar visual final com branco gelo, verde musgo e cores complementares.

---

## Observações Importantes

Este projeto é um MVP pessoal.

A integração com WhatsApp será feita inicialmente com CallMeBot porque é simples e gratuita para uso pessoal.

Caso o sistema evolua para múltiplos usuários reais, clientes ou uso comercial, avaliar troca para WhatsApp Cloud API oficial da Meta ou outro provedor profissional.

Não implementar complexidade desnecessária neste primeiro momento.

Priorizar:

* Simplicidade;
* Funcionalidade;
* Deploy funcional no Railway;
* Interface bonita e agradável;
* Código fácil de manter.

---

## Identidade do Produto

Nome oficial:

```text
migarden
```

Conceito:

```text
Um jardim inteligente, simples e pessoal para lembrar o usuário de cuidar das suas plantas.
```

Tom visual:

```text
Natural, limpo, organizado, leve e acolhedor.
```

---

## GitHub Actions - Node 24 Migration

Node 20 deprecated on GH runners since June 16, 2026. All actions must use Node 24 runtime.

### Current Status

`.github/workflows/ci.yml` needs updates:

| Action | Current | Target | Why |
|--------|---------|--------|-----|
| `actions/checkout` | `@v4` | `@v7` | Node 20 → Node 24 |
| `actions/cache` | `@v4` | `@v5` | Node 20 → Node 24 |
| `actions/upload-artifact` | `@v4` | `@v7` | Node 20 → Node 24 |
| `docker/setup-buildx-action` | `@v3` | `@v4` | Node 20 → Node 24 |
| `docker/build-push-action` | `@v6` | `@v7` | Node 20 → Node 24 |
| `ruby/setup-ruby` | `@v1` | `@v1` | Moving tag, already Node 24 |

To fix: update version tags in `.github/workflows/ci.yml`.

---

## Dockerfile Ruby Version

Current Dockerfile uses `ruby:3.3.0` and Dockerfile.prod uses `ruby:3.3.0-slim`. When upgrading Ruby, update both files.

---

Mensagem exemplo de lembrete:

```text
🌱 Lembrete do migarden

Hoje é dia de cuidar da sua planta:

Planta: Jiboia
Cuidado: regar

Não esqueça de registrar no sistema depois de realizar o cuidado.
```
