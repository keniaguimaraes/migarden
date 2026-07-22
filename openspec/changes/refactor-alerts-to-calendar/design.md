## Context

Current alerts page at `/alerts` loads all user plants, filters in-memory via `Plant#needs_any_care?`, and renders a flat grid of `_plant_card` partials. No forward-looking view — only "needs care today".

Proposal replaces this with a monthly calendar showing all upcoming care events across a 30-day rolling window. Route changes to `/calendar`, controller renamed, sidebar updated.

Care data is normalized: frequencies in `CareParameter` (separate table with `interval_days`), history in `CareLog` (separate table with `performed_at`). Computing future events requires iterating forward from last log date by interval.

## Goals / Non-Goals

**Goals:**
- Monthly calendar grid with day cells showing colored care dots for each care type
- 30-day rolling window (from today forward)
- Click day to expand detail panel with plant cards for that day
- Month navigation (prev/next month arrows)
- Keep summary cards (watering, fertilization, pest totals)
- Desktop-first responsive layout
- Replace `/alerts` route with `/calendar` + redirect from old path

**Non-Goals:**
- Not building a full-featured calendar component (no drag-drop, no event editing)
- No recurring event patterns beyond fixed-interval recurrence
- No multi-user calendar sharing
- No exporting/printing calendar

## Decisions

1. **Rolling window over calendar month**: 30 days from `Date.current` rather than fixed calendar month. Ensures user always sees exactly ~1 month of forward planning. Calendar grid still shows the current month navigated in the UI — only days within the 30-day window show data.

2. **Pure Ruby Date logic, no calendar gem**: Building calendar grid using Ruby stdlib `Date` class for first-of-month/day-of-week/month-length calculations. No external dependency needed for a single-page calendar.

3. **New `CalendarController` over mutating `AlertsController`**: Clean rename — new controller with focused `#index` action. Old controller deleted. Semantics changed from "what's late" to "what's coming up."

4. **Separate `calendar.css` file**: Avoids bloating `application.css` (already 1168 lines). Maintains existing CSS architecture (single CSS file, no import pipeline).

5. **30-day window computed in controller, not model**: Controller calls `Plant.upcoming_care_events` aggregated across user's plants, groups by date, passes hash to view. Model stays pure — just returns flat events array.

6. **Desktop-first grid**: 7-column CSS Grid for desktop. On mobile (< 880px), switches to single-column day list to avoid unusable tiny cells.

## Risks / Trade-offs

- [Performance] Computing recurrence for every plant across 30 days involves N plants × 3 care types × potentially many recurrences. Mitigation: eager-load `care_parameters` and `care_logs`; computation is pure Ruby in-memory with no additional queries.
- [Edge case] Plant with 1-day interval generates 30 entries per care type. Mitigation: expected behavior — fast-growing plants legitimately need daily care. Calendar handles gracefully.
- [Edge case] Very large plant collections (50+). Calendar grid remains functional; day detail panel may scroll. Mitigation: limit detail panel height with scroll.
