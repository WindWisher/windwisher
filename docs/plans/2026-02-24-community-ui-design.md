# Community UI Design (Phase UI-first)

## Context

This design defines the Community tab for the current UI-first phase.
The feature must prioritize a Woo Sports-like flow and postpone domain/data architecture extraction until a later phase.

## Goals

- Build a Community experience with two primary modes using a segmented control.
- Make `Leaderboard` the main competitive view using `Big Air Score` as the primary ranking metric.
- Provide a `Following` view focused on people the user follows and their sessions.
- Ensure users can access profile, sessions, and messaging entry points from Community.

## Information Architecture

- Community page contains a top `SegmentedButton` with:
  - `Leaderboard`
  - `Following`
- Each segment keeps its own local UI state:
  - filters
  - search text
  - scroll position

## Leaderboard Design

### Primary ranking model

- Default sorting metric: `Big Air Score` (descending).
- Each leaderboard row must show:
  - ranking position number (`#`)
  - profile avatar thumbnail
  - username
  - Big Air Score value
  - highest jump value (meters)

### Filters

Leaderboard includes Woo-style quick filters (responsive row/stack):

- Period: `24h`, `7d`, `30d`, `All time`
- Spot: `Todos` + mock spots
- Scope: `Global`, `Friends`
- Order: default `Big Air Score`

### Interactions

- Tap on a row opens an action sheet with:
  - `Ver perfil`
  - `Ver sesiones`
- Top 3 rows receive subtle visual emphasis (gold/silver/bronze cues) while keeping a consistent list format.

## Following Design

### Purpose

- Show only sessions from followed users.
- Provide user discovery and social actions from the same tab.

### Layout

- Search bar with magnifier icon at top.
- User discovery results section (based on search text) with follow/add action.
- Followed users sessions feed below.

### Session cards in Following

- Card content:
  - avatar + username
  - spot and date
  - Big Air Score
  - highest jump
- User actions from card/menu:
  - `Mensaje`
  - `Ver perfil`
  - `Ver sesiones`

### Empty states

- No followed users: show guided empty state with CTA to search and follow.
- No search results: show neutral empty state.

## Navigation and Placeholders (UI-first)

For this phase, navigation targets are real pages with placeholder content:

- Community -> user profile page (placeholder)
- Community -> user sessions page (placeholder)
- Community -> messages page (placeholder)

These pages must be navigable now and can be functionally expanded in later phases.

## Data Strategy for this phase

- Use deterministic in-memory mock data only.
- Keep user identity and stats consistent across:
  - leaderboard rows
  - following feed cards
  - profile/sessions placeholders
- No backend integration in this phase.

## UX and Visual Rules

- Keep Material style coherence with existing app patterns.
- Preserve current spacing/token usage from `AppSpacing`.
- Ensure no horizontal overflow in narrow screens.
- Maintain clear visual hierarchy for score and jump metrics.

## Accessibility and Interaction Quality

- Tap targets at least standard Material size.
- Semantic labels for key action icons/buttons.
- Distinguishable states for selected segment and active filters.

## Testing Scope

- Widget tests for segmented switching behavior.
- Widget tests for leaderboard row content fields.
- Widget tests for filter application in leaderboard.
- Widget tests for following search and follow action.
- Widget tests for navigation actions (`Ver perfil`, `Ver sesiones`, `Mensaje`).
- Widget tests for empty states.

## Out of Scope (current phase)

- Real-time ranking updates.
- Backend/API persistence.
- Full messaging system behavior.
- Deep profile/session analytics implementation.
