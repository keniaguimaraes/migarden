# miGarden MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a multi-user plant care system with a botanical-themed dashboard and daily WhatsApp reminders via CallMeBot.

**Architecture:** Rails 7+ MVC with a lean manual authentication system, Active Storage for images, and Solid Queue for daily background notifications.

**Tech Stack:** Ruby on Rails, PostgreSQL, Solid Queue, CallMeBot API, Docker.

---

## Phase 1: Core Infrastructure

### Task 1: Project Initialization
**Files:**
- Create: `Gemfile`
- Create: `config/application.rb`
- Create: `config/database.yml`

- [ ] **Step 1: Generate new Rails project**
  Run: `rails new migarden -d postgresql --api=false`
  (Note: We want a full MVC app for the dashboard and forms).

- [ ] **Step 2: Add required gems**
  Modify `Gemfile`:
  ```ruby
  gem "bcrypt", "~> 3.1.7"
  gem "solid_queue"
  ```
  Run: `bundle install`

- [ ] **Step 3: Configure Active Job to use Solid Queue**
  Modify `config/application.rb`:
  ```ruby
  config.active_job.queue_adapter = :solid_queue
  ```

- [ ] **Step 4: Initial DB Setup**
  Run: `bin/rails db:create`

- [ ] **Step 5: Commit**
  ```bash
  git add .
  git commit -m "infra: initialize rails project with postgres and solid_queue"
  ```

### Task 2: Docker Development Environment
**Files:**
- Create: `Dockerfile`
- Create: `docker-compose.yml`

- [ ] **Step 1: Create Dockerfile**
  ```dockerfile
  FROM ruby:3.3.0
  RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs npm postgresql-client imagemagick libvips && rm -rf /var/lib/apt/lists/*
  WORKDIR /app
  COPY Gemfile Gemfile.lock ./
  RUN bundle install
  COPY . .
  EXPOSE 3000
  CMD ["bin/rails", "server", "-b", "0.0.0.0"]
  ```

- [ ] **Step 2: Create docker-compose.yml**
  ```yaml
  services:
    web:
      build: .
      volumes: [".:/app"]
      ports: ["3000:3000"]
      environment:
        DATABASE_URL: postgres://postgres:password@db:5432/migarden_development
      depends_on: ["db"]
    db:
      image: postgres:16
      environment:
        POSTGRES_USER: postgres
        POSTGRES_PASSWORD: password
        POSTGRES_DB: migarden_development
      volumes: ["postgres_data:/var/lib/postgresql/data"]
  volumes:
S     postgres_data:
  ```

- [ ] **Step 3: Verify Docker setup**
  Run: `docker compose up -d`
  Check: `curl -I http://localhost:3000` (Should return 200 OK)

- [ ] **Step 4: Commit**
  ```bash
  git add Dockerfile docker-compose.yml
  git commit -m "infra: setup docker development environment"
  ```

---

## Phase 2: User Authentication

### Task 3: User Model & Schema
**Files:**
- Create: `db/migrate/20260602000001_create_users.rb`
- Create: `app/models/user.rb`

- [ ] **Step 1: Generate User migration**
  Run: `bin/rails generate migration CreateUsers name:string email:string:uniq password_digest:string callmebot_phone:string callmebot_api_key:string`

- [ ] **Step 2: Implement User model**
  Modify `app/models/user.rb`:
  ```ruby
  class User < ApplicationRecord
    has_secure_password
    has_many :plants, dependent: :destroy
    validates :name, presence: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::PATTERN }
  end
  ```

- [ ] **Step 3: Run migration**
  Run: `bin/rails db:migrate`

- [ ] **Step 4: Commit**
  ```bash
  git add db/migrate/app/models/user.rb
  git commit -m "feat: implement user model with secure password"
  ```

### Task 4: Session Management
**Files:**
- Create: `app/controllers/application_controller.rb`
- Create: `app/controllers/sessions_controller.rb`
- Create: `app/controllers/users_controller.rb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Implement ApplicationController auth filters**
  Modify `app/controllers/application_controller.rb`:
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

- [ ] **Step 2: Implement SessionsController (Login/Logout)**
  Create `app/controllers/sessions_controller.rb`:
  ```ruby
  class SessionsController < ApplicationController
    skip_before_action :authenticate_user!, only: [:new, :create]
    def new; end
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

- [ ] **Step 3: Implement UsersController (Registration)**
  Create `app/controllers/users_controller.rb`:
  ```ruby
  class UsersController < ApplicationController
    skip_before_action :authenticate_user!, only: [:new, :create]
    def new; @user = User.new; end
    def create
      @user = User.new(user_params)
      if @user.save
        session[:user_id] = @user.id
        redirect_to root_path, notice: "Conta criada com sucesso!"
      else
        render :new, status: :unprocessable_entity
      end
    end
    private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
  end
  ```

- [ ] **Step 4: Configure routes**
  Modify `config/routes.rb`:
  ```ruby
  Rails.application.routes.draw do
    root "dashboard#index"
    resource :session, only: [:new, :create, :destroy]
    resources :users, only: [:new, :create]
  end
  ```

- [ ] **Step 5: Commit**
  ```bash
  git add app/controllers config/routes.rb
  git commit -m "feat: implement basic authentication flow"
  ```

---

## Phase 3: Plant Management

### Task 5: Plant Model & Logic
**Files:**
- Create: `db/migrate/20260602000002_create_plants.rb`
- Create: `app/models/plant.rb`

- [ ] **Step 1: Generate Plant migration**
  Run: `bin/rails generate migration CreatePlants name:string plant_type:string sun_exposure:string watering_frequency_days:integer fertilization_frequency_days:integer pest_control_frequency_days:integer last_watered_at:date last_fertilized_at:date last_pest_control_at:date user:references`

- [ ] **Step 2: Implement Plant model logic**
  Modify `app/models/plant.rb`:
  ```ruby
  class Plant < ApplicationRecord
    belongs_to :user
    has_one_attached :photo
    validates :name, :plant_type, :sun_exposure, presence: true
    validates :watering_frequency_days, :fertilization_frequency_days, :pest_control_frequency_days, presence: true, numericality: { greater_than: 0 }

    def next_watering_date
      last_watered_at ? last_watered_at + watering_frequency_days.days : Date.current
    end
    def next_fertilization_date
      last_fertilized_at ? last_fertilized_at + fertilization_frequency_days.days : Date.current
    end
    def next_pest_control_date
      last_pest_control_at ? last_pest_control_at + pest_control_frequency_days.days : Date.current
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
  end
  ```

- [ ] **Step 3: Run migration**
  Run: `bin/rails db:migrate`

- [ ] **Step 4: Commit**
  ```bash
  git add db/migrate app/models/plant.rb
  git commit -m "feat: implement plant model with care calculations"
  ```

### Task 6: Plants Controller (CRUD)
**Files:**
- Create: `app/controllers/plants_controller.rb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Implement PlantsController**
  Create `app/controllers/plants_controller.rb`:
  ```ruby
  class PlantsController < ApplicationController
    before_action :set_plant, only: [:show, :edit, :update, :destroy, :mark_as_watered, :mark_as_fertilized, :mark_as_pest_controlled]

    def index
      @plants = current_user.plants
    end
    def new; @plant = current_user.plants.build; end
    def create
      @plant = current_user.plants.build(plant_params)
      if @plant.save
        redirect_to @plant, notice: "Planta cadastrada com sucesso!"
      else
        render :new, status: :unprocessable_entity
      end
    end
    def show; end
    def edit; end
    def update
      if @plant.update(plant_params)
        redirect_to @plant, notice: "Planta atualizada!"
      else
        render :edit, status: :unprocessable_entity
      end
    end
    def destroy
      @plant.destroy
      redirect_to plants_path, notice: "Planta removida."
    end

    # Care Actions
    def mark_as_watered
      @plant.update!(last_watered_at: Date.current)
      redirect_to @plant, notice: "Rega registrada!"
    end
    def mark_as_fertilized
      @plant.update!(last_fertilized_at: Date.current)
      redirect_to @plant, notice: "Fertilização registrada!"
    end
    def mark_as_pest_controlled
      @plant.update!(last_pest_control_at: Date.current)
      redirect_to @plant, notice: "Controle de pragas registrado!"
    end

    private
    def set_plant
      @plant = current_user.plants.find(params[:id])
    end
    def plant_params
      params.require(:plant).permit(:name, :plant_type, :sun_exposure, :watering_frequency_days, :fertilization_frequency_days, :pest_control_frequency_days, :photo)
    end
  end
  ```

- [ ] **Step 2: Configure routes**
  Modify `config/routes.rb`:
  ```ruby
  Rails.application.routes.draw do
    root "dashboard#index"
    resource :session, only: [:new, :create, :destroy]
    resources :users, only: [:new, :create]
    resources :plants do
      member do
        patch :mark_as_watered
        patch :mark_as_fertilized
        patch :mark_as_pest_controlled
      end
    end
  end
  ```

- [ ] **Step 3: Commit**
  ```bash
  git add app/controllers/plants_controller.rb config/routes.rb
  git commit -m "feat: implement plants CRUD and care actions"
  ```

---

## Phase 4: Media & Storage

### Task 7: Active Storage Setup
**Files:**
- Modify: `config/storage.yml`

- [ ] **Step 1: Install Active Storage**
  Run: `bin/rails active_storage:install`
  Run: `bin/rails db:migrate`

- [ ] **Step 2: Configure local storage for MVP**
  Verify `config/storage.yml` has `local:` service.

- [ ] **Step 3: Commit**
  ```bash
  git add db/migrate
  git commit -m "feat: setup active storage for plant photos"
  ```

---

## Phase 5: Dashboard & UI

### Task 8: Dashboard Controller & Views
**Files:**
- Create: `app/controllers/dashboard_controller.rb`
- Create: `app/views/dashboard/index.html.erb`
- Create: `app/views/shared/_sidebar.html.erb`

- [ ] **Step 1: Implement DashboardController**
  Create `app/controllers/dashboard_controller.rb`:
  ```ruby
  class DashboardController < ApplicationController
    def index
      @plants = current_user.plants
      @total_plants = @plants.count
      @needs_watering = @plants.select { |p| p.needs_watering? }.count
      @needs_fertilization = @plants.select { |p| p.needs_fertilization? }.count
      @needs_pest_control = @plants.select { |p| p.needs_pest_control? }.count
    end
  end
  ```

- [ ] **Step 2: Implement Layout with Sidebar**
  Create `app/views/shared/_sidebar.html.erb`:
  ```erb
  <aside class="sidebar">
    <div class="sidebar__brand">🌿 migarden</div>
    <nav class="sidebar__nav">
      <%= link_to "Dashboard", root_path %>
      <%= link_to "Minhas Plantas", plants_path %>
      <%= link_to "Nova Planta", new_plant_path %>
      <%= button_to "Sair", session_path, method: :delete %>
    </nav>
  </aside>
  ```

- [ ] **Step 3: Apply CSS Theme**
  Create `app/assets/stylesheets/application.css` with the colors defined in the spec (Ice White, Moss Green, etc.).

- [ ] **Step 4: Commit**
  ```bash
  git add app/controllers/dashboard_controller.rb app/views/ app/assets/stylesheets/
  git commit -m "feat: implement dashboard and botanical theme layout"
  ```

---

## Phase 6: Notification Engine

### Task 9: WhatsApp Notifier Service
**Files:**
- Create: `app/services/whatsapp_notifier.rb`

- [ ] **Step 1: Implement the Notifier Service**
  Create `app/services/whatsapp_notifier.rb`:
  ```ruby
  require "net/http"
  require "uri"

  class WhatsappNotifier
    def self.send_message(user, message)
      return unless user.callmebot_phone && user.callmebot_api_key

      uri = URI("https://api.callmebot.com/whatsapp.php")
      uri.query = URI.encode_www_form(
        phone: user.callmebot_phone,
        text: message,
        apikey: user.callmebot_api_key
      )

      response = Net::HTTP.get_response(uri)
      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error("[WhatsappNotifier] Error sending to #{user.email}: #{response.body}")
      end
      response
    rescue StandardError => e
      Rails.logger.error("[WhatsappNotifier] Unexpected error: #{e.message}")
      nil
    end
  end
  ```

- [ ] **Step 2: Commit**
  ```bash
  git add app/services/whatsapp_notifier.rb
  git commit -m "feat: implement whatsapp notifier service via CallMeBot"
  ```

### Task 10: Daily Reminder Job
**Files:**
- Create: `app/jobs/plant_reminder_job.rb`
- Create: `config/initializers/solid_queue_cron.rb` (or equivalent scheduling)

- [ ] **Step 1: Implement the Reminder Job**
  Create `app/jobs/plant_reminder_job.rb`:
  ```ruby
  class PlantReminderJob < ApplicationJob
    queue_as :default

    def perform
      User.find_each do |user|
        pending_plants = user.plants.select { |p| p.needs_watering? || p.needs_fertilization? || p.needs_pest_control? }
        next if pending_plants.empty?

        message = "🌱 Lembrete do miGarden\n\n"
        pending_plants.each do |plant|
          cares = []
          cares << "regar" if plant.needs_watering?
          cares << "fertilizar" if plant.needs_fertilization?
          cares << "controle de pragas" if plant.needs_pest_control?
          message += "Plant: #{plant.name} -> #{cares.join(', ')}\n"
        end
        message += "\nNão esqueça de registrar no sistema!"

        WhatsappNotifier.send_message(user, message)
      end
    end
  end
  ```

- [ ] **Step 2: Schedule the Job (Solid Queue / Cron)**
  Since we are using Solid Queue, we will use a recurring task configuration or a simple system crontab to trigger `PlantReminderJob.perform_later`.

- [ ] **Step 3: Commit**
  ```bash
  git add app/jobs/
  git commit -m "feat: implement daily plant reminder job"
  ```

---

## Phase 7: Production Readiness

### Task 11: Railway Deployment Config
**Files:**
- Create: `Dockerfile.prod`
- Create: `bin/docker-entrypoint`
- Create: `Procfile`

- [ ] **Step 1: Create Production Dockerfile**
  (Slim image, asset precompilation, environment variables).

- [ ] **Step 2: Create Entrypoint script**
  Implement `bin/docker-entrypoint` to run `db:migrate` on boot.

- [ ] **Step 3: Create Procfile**
  ```text
  web: bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}
  worker: bundle exec rake solid_queue:start
  ```

- [ ] **Step 4: Final Commit**
  ```bash
  git add Dockerfile.prod bin/docker-entrypoint Procfile
  git commit -m "infra: prepare project for Railway production deployment"
  ```
