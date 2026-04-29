# miGarden Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the miGarden API for managing plant care with daily WhatsApp notifications.

**Architecture:** Rails 8 API with Solid Queue for background jobs, PostgreSQL for data, and Active Storage (Cloudinary/S3) for plant photos. Logic is isolated in `app/services` to keep controllers thin.

**Tech Stack:** Ruby on Rails 7+, PostgreSQL, Solid Queue, Docker, Evolution API, Cloudinary/S3.

---

## File Map

### Models & DB
- `app/models/plant.rb`: Base entity with `has_one_attached :image`.
- `app/models/care_parameter.rb`: Care rules and intervals.
- `app/models/care_log.rb`: History of care actions.

### Services
- `app/services/care_calculator_service.rb`: Logic for "due" dates and interval adjustments.
- `app/services/notification_engine_service.rb`: Consolidates all due tasks into a single message.
- `app/services/whatsapp/send_notification_service.rb`: Wrapper for Evolution API.

### Jobs
- `app/jobs/daily_notification_job.rb`: Scheduled job to trigger the engine.

### Config & Infra
- `Dockerfile`: Multi-stage build for Rails.
- `docker-compose.yml`: Rails, Postgres, Evolution API.
- `Procfile`: Web and worker processes.

---

## Implementation Tasks

### Task 1: Infrastructure Setup

- [ ] **Step 1: Create Dockerfile**
```dockerfile
# Multi-stage build for Rails 8
FROM ruby:3.3.0-slim as base
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install

FROM base as development
COPY . .
CMD ["rails", "server", "-b", "0.0.0.0"]
```

- [ ] **Step 2: Create docker-compose.yml**
```yaml
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  app:
    build: .
    command: bundle exec rails s -b '0.0.0.0'
    ports:
      - "3000:3000"
    environment:
      DATABASE_URL: postgres://postgres:password@db:5432/migarden_development
    depends_on:
      - db

  evolution_api:
    image: atendai/evolution-api:latest
    ports:
      - "8080:8080"
    environment:
      - AUTH_API_KEY=your_api_key
    volumes:
      - evolution_data:/evolution/instances

volumes:
  postgres_data:
  evolution_data:
```

- [ ] **Step 3: Create Procfile for Railway**
```text
web: bundle exec puma -C config/puma.rb
worker: bundle exec rake solid_queue:start
```

- [ ] **Step 4: Commit Infra**
```bash
git add Dockerfile docker-compose.yml Procfile
git commit -m "infra: initial docker and deployment config"
```

### Task 2: Model Scaffolding & Schema

- [ ] **Step 1: Create Plant model**
```bash
rails g model Plant name:string species:string nickname:string
```

- [ ] **Step 2: Create CareParameter model**
```bash
rails g model CareParameter plant:references action_type:integer interval_days:integer
```

- [ ] **Step 3: Create CareLog model**
```bash
rails g model CareLog plant:references care_parameter:references performed_at:date observation:text
```

- [ ] **Step 4: Define Enums in CareParameter**
```ruby
# app/models/care_parameter.rb
class CareParameter < ApplicationRecord
  belongs_to :plant
  enum action_type: { watering: 0, fertilization: 1, insecticide: 2 }
end
```

- [ ] **Step 5: Run Migrations**
```bash
rails db:migrate
```

- [ ] **Step 6: Commit Models**
```bash
git add app/models db/migrate
git commit -m "feat: add plant, care_parameter, and care_log models"
```

### Task 3: Plant Photos (Active Storage)

- [ ] **Step 1: Install Active Storage**
```bash
rails active_storage:install
rails db:migrate
```

- [ ] **Step 2: Configure Plant model for images**
```ruby
# app/models/plant.rb
class Plant < ApplicationRecord
  has_many :care_parameters
  has_many :care_logs
  has_one_attached :image
end
```

- [ ] **Step 3: Commit Photos feature**
```bash
git add app/models config/storage.yml
git commit -m "feat: add plant photo support via active storage"
```

### Task 4: Care Calculation Logic (`CareCalculatorService`)

- [ ] **Step 1: Write test for due date calculation**
```ruby
# spec/services/care_calculator_service_spec.rb
it "identifies plant as due if performed_at + interval <= today" do
  plant = Plant.create!(name: "Test")
  param = CareParameter.create!(plant: plant, action_type: :watering, interval_days: 7)
  CareLog.create!(plant: plant, care_parameter: param, performed_at: 8.days.ago.to_date)
  
  expect(CareCalculatorService.due_today(param)).to be true
end
```

- [ ] **Step 2: Implement `CareCalculatorService`**
```ruby
# app/services/care_calculator_service.rb
class CareCalculatorService
  def self.due_today(parameter)
    last_log = CareLog.where(care_parameter: parameter).order(performed_at: :desc).first
    return true if last_log.nil?
    
    next_date = last_log.performed_at + parameter.interval_days.days
    next_date <= Date.today
  end
end
```

- [ ] **Step 3: Implement Dynamic Frequency Adjustment**
```ruby
# app/services/care_calculator_service.rb (addition)
def self.adjust_frequency(parameter, actual_date)
  expected_date = CareLog.where(care_parameter: parameter).order(performed_at: :desc).first.performed_at + parameter.interval_days.days
  days_diff = (expected_date - actual_date).to_i
  
  if days_diff >= 2 # Regou 2 ou mais dias antes do prazo
    new_interval = parameter.interval_days - days_diff
    parameter.update(interval_days: [new_interval, 1].max)
  end
end
```

- [ ] **Step 4: Run tests and commit**
```bash
bundle exec rspec spec/services/care_calculator_service_spec.rb
git add app/services spec/services
git commit -m "feat: implement care calculation and dynamic frequency adjustment"
```

### Task 5: WhatsApp Integration (`WhatsApp::SendNotificationService`)

- [ ] **Step 1: Create Service wrapper**
```ruby
# app/services/whatsapp/send_notification_service.rb
module WhatsApp
  class SendNotificationService
    def self.call(number, text, image_url = nil)
      payload = { number: number, text: text }
      payload[:image] = image_url if image_url
      
      Faraday.post("#{ENV['EVOLUTION_API_URL']}/message/sendText/#{ENV['EVOLUTION_INSTANCE']}", 
                   payload.to_json, 
                   { 'Content-Type' => 'application/json', 'apikey' => ENV['EVOLUTION_API_KEY'] })
    end
  end
end
```

- [ ] **Step 2: Commit Integration**
```bash
git add app/services/whatsapp
git commit -m "feat: integrate Evolution API for WhatsApp notifications"
```

### Task 6: Notification Engine & Daily Job

- [ ] **Step 1: Implement `NotificationEngineService`**
```ruby
# app/services/notification_engine_service.rb
class NotificationEngineService
  def self.call
    due_tasks = []
    CareParameter.all.each do |param|
      if CareCalculatorService.due_today(param)
        due_tasks << { plant: param.plant, action: param.action_type }
      end
    end
    
    return if due_tasks.empty?
    
    message = "🌿 *miGarden Informa:*\n\nHoje é dia de cuidar de:\n"
    # Grouping logic here...
    WhatsApp::SendNotificationService.call(ENV['USER_PHONE'], message)
  end
end
```

- [ ] **Step 2: Create `DailyNotificationJob`**
```ruby
# app/jobs/daily_notification_job.rb
class DailyNotificationJob < ApplicationJob
  queue_as :default
  def perform
    NotificationEngineService.call
  end
end
```

- [ ] **Step 3: Commit Engine**
```bash
git add app/services/notification_engine_service.rb app/jobs/daily_notification_job.rb
git commit -m "feat: implement notification engine and daily job"
```

### Task 7: API Endpoints & Final Polish

- [ ] **Step 1: Create PlantsController (Index/Show)**
- [ ] **Step 2: Create CareLogsController (Create for marking as done)**
```ruby
# app/controllers/care_logs_controller.rb
def create
  log = CareLog.create!(log_params)
  CareCalculatorService.adjust_frequency(log.care_parameter, log.performed_at)
  render json: log
end
```

- [ ] **Step 3: Final commit and smoke test**
```bash
git add app/controllers
git commit -m "feat: add API endpoints for plants and care logs"
```
