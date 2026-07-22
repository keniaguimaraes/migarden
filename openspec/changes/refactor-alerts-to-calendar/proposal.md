## Why

Current `/alerts` shows flat list of plants needing care today — no forward visibility. User can't see what's due tomorrow, next week, or plan care rounds ahead. Replace with interactive monthly calendar showing upcoming care events across a 30-day rolling window.

## What Changes

- Replace `AlertsController` with `CalendarController` at route `/calendar`
- Replace `alerts/index.html.erb` with `calendar/index.html.erb` (monthly calendar grid)
- Rename sidebar label from "Alertas" to "Calendário"
- Add `Plant#upcoming_care_events(from:, to:)` model method
- Add `calendar.css` for calendar grid styling
- Remove old `alerts_controller.rb`, `alerts/index.html.erb`, `alerts_controller_test.rb`
- Add redirect from `/alertas` to `/calendar` for backward compatibility
- **BREAKING**: Route `/alerts` replaced by `/calendar`

## Capabilities

### New Capabilities
- `plant-care-calendar`: Monthly calendar grid showing upcoming watering, fertilization, and pest control events per plant within a 30-day rolling window, with day detail expansion and summary cards

### Modified Capabilities

None — no existing capability spec changes.

## Impact

- `app/controllers/alerts_controller.rb` — deleted, replaced by `calendar_controller.rb`
- `app/views/alerts/` — deleted, replaced by `app/views/calendar/`
- `app/models/plant.rb` — new method `upcoming_care_events`
- `config/routes.rb` — replace `resources :alerts` with `resource :calendar` + redirect
- `app/views/shared/_sidebar.html.erb` — update link label and path
- `app/assets/stylesheets/application.css` — no change (separate `calendar.css`)
- `test/controllers/alerts_controller_test.rb` — replaced by `calendar_controller_test.rb`
