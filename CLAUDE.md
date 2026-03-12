# TinyClaw

Open-source, on-device multi-model AI assistant for iOS.

## Architecture Decisions

All architecture and design decisions are documented in `docs/decisions/` as numbered ADRs (Architecture Decision Records). Each file records the decision made, all options considered with pros/cons, the rationale, and which alternatives to revisit later.

**Always check `docs/decisions/` before making changes that relate to a prior decision.** If a new decision is needed, create a new numbered file following the same format. Never delete old decisions — mark them as `Superseded` with a link to the replacement if a decision changes.

Current decisions:
- 001: Platform Target (iOS first)
- 002: Dispatcher Strategy (BERT-tiny classifier)
- 003: Memory Management (Lazy-load + LRU eviction)
- 004: MVP Scope (Chat + Code + Summarizer) — *partially superseded by 007*
- 005: UI Model (Auto-detect with visible specialist badge)
- 006: Architecture Pattern (Unified Model Manager)
- 007: Pivot — Drop Code, add STT + local task/event management
