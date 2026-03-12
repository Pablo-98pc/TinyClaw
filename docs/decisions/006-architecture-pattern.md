# Decision 006: Core Architecture Pattern

**Date:** 2026-03-12
**Status:** Accepted
**Decision:** Unified Model Manager (Approach A)

## Context

The architecture needs a pattern for managing multiple Core ML models, their lifecycle, and memory coordination. This is the central structural decision for the codebase.

## Options Considered

### A. Unified Model Manager (Chosen)
- Single `ModelManager` class owns all model lifecycle — loading, inference, eviction
- Each specialist conforms to a `SpecialistProtocol` with common interface
- Dispatcher is managed by the same system but pinned (never evicted)
- One place for memory tracking, clean protocol-based testing, easy to add specialists
- **Con:** ModelManager becomes a central dependency

### B. Independent Specialist Modules
- Each specialist is self-contained, manages its own Core ML model
- Thin coordinator calls into modules; each handles own loading/unloading
- Memory pressure handled via iOS memory warnings
- **Pro:** True isolation, independent development/testing
- **Con:** No centralized memory budget — relies on iOS memory warnings which can be too late

### C. Actor-Based Concurrency
- Swift Actors for each specialist; dispatcher actor sends messages to specialist actors
- Supervisor actor tracks memory allocations
- **Pro:** Modern Swift concurrency, natural isolation, thread-safe by design
- **Con:** More complex, actor reentrancy issues, over-engineered for v0

## Rationale

Explicit control over the RAM budget is the hardest constraint on-device. A unified manager enforces the 4GB cap directly rather than hoping iOS memory warnings arrive in time. The protocol-based design keeps specialists testable and swappable. We can refactor toward actors later if concurrency becomes a bottleneck.

## Alternatives to Revisit

- **Actor-Based (Option C):** Natural next step if v0 reveals concurrency issues (e.g., user sends a new query while a specialist is mid-inference)
- **Independent Modules (Option B):** Worth considering if the ModelManager becomes too complex or creates tight coupling
