# Design Document: miGarden MVP
Date: 2026-06-02
Status: Approved
Approach: Lean MVP (Abordagem 1)

## 1. Overview
miGarden is a smart botanical management system designed to help users maintain their home plants. It calculates care schedules (watering, fertilization, pest control) and sends daily notifications via WhatsApp using the CallMeBot API.

### Core Objectives
- Track plant care cycles.
- Automate daily reminders via WhatsApp.
- Provide a visual dashboard of plant health and pending tasks.
- Support multiple users (initially ~10) with isolated data.

## 2. Technical Architecture
- **Backend:** Ruby on Rails 7+ (API/MVC)
- **Database:** PostgreSQL
- **Background Processing:** Solid Queue (Postgres-backed)
- **Notifications:** CallMeBot API (HTTP GET)
- **Deployment:** Railway (Dockerized)
- **Authentication:** Manual `has_secure_password` (Bcrypt)

## 3. Data Model

### User
- `name`: string
- `email`: string (unique)
- `password_digest`: string
- `callmebot_phone`: string (User's WhatsApp number)
- `callmebot_api_key`: string (User's CallMeBot API key)
- **Relationship:** `has_many :plants`

### Plant
- `user_id`: references (belongs to User)
- `name`: string
- `plant_type`: string
- `sun_exposure`: string (enum: `sombra`, `meia_sombra`, `sol`)
- `watering_frequency_days`: integer
- `fertilization_frequency_days`: integer
- `pest_control_frequency_days`: integer
- `last_watered_at`: date
- `last_fertilized_at`: date
- `last_pest_control_at`: date
- **Attachments:** `has_one_attached :photo` (Active Storage)

## 4. Business Logic

### Date Calculations
The `Plant` model implements logic to determine the next care date:
- `next_watering_date = last_watered_at + watering_frequency_days.days`
- `needs_watering?` returns true if `next_watering_date <= Date.current`.
- Same logic applies to fertilization and pest control.

### Notification Pipeline
1. **PlantReminderJob:** A Solid Queue job scheduled daily at 08:00 AM.
   - Iterates through all `User` records.
   - Checks for plants needing care today.
   - Constructs a formatted message.
   - Calls the `WhatsappNotifier` service.
2. **WhatsappNotifier Service:**
   - Encapsulates HTTP calls to CallMeBot.
   - Uses `user.callmebot_phone` and `user.callmebot_api_key`.
   - Endpoint: `https://api.callmebot.com/whatsapp.php`

## 5. Interface Design

### Visual Identity
- **Primary Color:** Moss Green (`#556B2F`)
- **Secondary Colors:** Deep Green (`#2F4F2F`), Ice White (`#F7F8F4`)
- **Feel:** Natural, clean, welcoming.

### Key Screens
- **Auth:** Minimalist Login and Sign-up screens.
- **Dashboard:** 
  - Top row of summary cards (Total, Watering, Fertilizer, Pest Control).
  - Grid of plant cards with photos and status indicators.
- **Plant Management:** 
  - CRUD for plants.
  - "Mark as Done" buttons that update the `last_*_at` date to today.
- **Layout:** Fixed Sidebar with navigation (Dashboard, My Plants, New Plant, Settings, Logout).

## 6. Deployment Strategy
- **Containerization:** Dockerfile for local dev and production.
- **Railway Config:** 
  - PostgreSQL and Solid Queue (managed via Postgres).
  - Environment variables for Rails and CallMeBot default configs (if any).
  - Automated migrations on boot via `bin/docker-entrypoint`.
