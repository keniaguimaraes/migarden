## 1. Model

- [x] 1.1 Add `Plant#upcoming_care_events(from:, to:)` method returning all care events in date range

## 2. Controller

- [x] 2.1 Create `CalendarController` with `#index` action loading calendar data and summary counts
- [x] 2.2 Delete `AlertsController`

## 3. View

- [x] 3.1 Create `calendar/index.html.erb` with month grid, summary cards, day detail panel
- [x] 3.2 Delete `alerts/index.html.erb` and `alerts/` directory

## 4. Styles

- [x] 4.1 Create `app/assets/stylesheets/calendar.css` with calendar grid, day cells, dots, detail panel, responsive rules

## 5. Routes & Navigation

- [x] 5.1 Update `config/routes.rb`: add calendar route, add /alertas redirect, remove alerts resource
- [x] 5.2 Update sidebar: rename "Alertas" to "Calendário", link to `calendar_path`

## 6. Tests

- [x] 6.1 Create `CalendarControllerTest` with tests for default view, day selection, empty state, auth, old path redirect
- [x] 6.2 Delete `AlertsControllerTest`
