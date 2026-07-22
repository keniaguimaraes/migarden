## ADDED Requirements

### Requirement: Calendar displays monthly grid
The system SHALL display a monthly calendar grid with days as cells showing care indicators for plants within the 30-day rolling window from today.

#### Scenario: Default view shows current month
- **WHEN** user navigates to `/calendar` without params
- **THEN** page renders a calendar grid for the current month
- **THEN** today's cell is visually highlighted
- **THEN** day cells outside the 30-day window show no care indicators

#### Scenario: Month navigation
- **WHEN** user clicks next month arrow
- **THEN** calendar grid updates to show the following month
- **WHEN** user clicks previous month arrow
- **THEN** calendar grid updates to show the previous month

#### Scenario: Day cell shows care dots
- **WHEN** a plant has a watering event on a specific day within the window
- **THEN** that day cell shows a 💧 dot
- **WHEN** a plant has a fertilization event
- **THEN** that day cell shows a 🧪 dot
- **WHEN** a plant has a pest control event
- **THEN** that day cell shows a 🐛 dot

### Requirement: Day detail panel
The system SHALL show an expanded detail panel below the calendar when a day is selected, listing plants with care events on that day.

#### Scenario: Click day shows detail
- **WHEN** user clicks a day cell with care events
- **THEN** detail panel appears below calendar with plant cards for that day
- **THEN** each card shows plant name, care type needed, and action buttons

#### Scenario: Empty day message
- **WHEN** user clicks a day cell with no care events (or outside window)
- **THEN** detail panel shows "Nenhum cuidado previsto para este dia"

### Requirement: Summary cards
The system SHALL display summary cards above the calendar showing counts of plants needing care today.

#### Scenario: Summary counts
- **WHEN** calendar page loads
- **THEN** shows card with 💧 icon and count of plants needing watering today
- **THEN** shows card with 🧪 icon and count of plants needing fertilization today
- **THEN** shows card with 🐛 icon and count of plants needing pest control today

### Requirement: Backward compatibility
The system SHALL redirect the old `/alertas` path to `/calendar`.

#### Scenario: Old path redirects
- **WHEN** user accesses `/alertas`
- **THEN** they are redirected to `/calendar`
