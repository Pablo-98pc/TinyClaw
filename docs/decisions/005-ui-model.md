# Decision 005: UI Interaction Model

**Date:** 2026-03-12
**Status:** Accepted
**Decision:** Single chat interface with auto-detect and visible specialist indicator

## Context

The UI model determines how users interact with multiple specialists. It affects both UX and how the dispatcher integrates with the interface layer.

## Options Considered

### A. Single chat interface (invisible routing)
- One conversation thread, dispatcher routes silently
- User just talks naturally — no awareness of specialists
- Simplest UX, but no transparency into what's happening

### B. Mode-switching UI (manual selection)
- User explicitly picks a mode (Chat / Code / Summarize) via tabs or picker
- Simpler routing logic — dispatcher is optional
- Less magical, more cognitive load on user

### C. Auto-detect with visible indicator (Chosen)
- Single chat interface, automatic routing
- Small badge/indicator shows which specialist is handling the query (e.g., "Code" badge)
- Transparent but still automatic — user understands without having to choose
- Optionally allows manual override if the dispatcher misclassifies

## Rationale

Showing which specialist is active builds user trust and helps debug misclassifications. It keeps the simplicity of a single chat while giving transparency. The badge also enables a future "tap to override" feature if users want to force a specific specialist.

## Alternatives to Revisit

- **Invisible routing (Option A):** If user testing shows the badge is distracting or confusing, simplify to invisible
- **Mode-switching (Option B):** Could be useful as a "power user" mode or settings toggle
