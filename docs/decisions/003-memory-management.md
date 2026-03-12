# Decision 003: Memory Management Strategy

**Date:** 2026-03-12
**Status:** Accepted
**Decision:** Lazy-load specialists with LRU eviction policy

## Context

iPhone RAM is limited (6GB on most modern devices, ~4GB usable for apps). Multiple specialist models must share this budget. Loading a model takes 1-3s depending on size.

## Options Considered

### A. Lazy-load with LRU eviction (Chosen)
- Load specialists on first use
- Keep most-recently-used models in memory
- Evict least-recently-used when approaching RAM budget (~4GB cap)
- Dispatcher always pinned in memory (never evicted)
- Best balance of speed (warm cache) and RAM efficiency

### B. Lazy-load, unload after each query
- Load specialist, run inference, immediately unload
- Minimal RAM footprint at any given time
- Cold start on every query (~1-3s per load) — bad UX for repeated queries
- Simplest implementation

### C. Preload top 2, lazy-load rest
- Keep chat specialist + dispatcher always loaded (most common use case)
- Lazy-load code/summarizer on demand
- Predictable performance for common case
- Wastes RAM if user primarily uses code or summarizer

## Rationale

LRU eviction adapts to actual usage patterns. If a user is in a coding session, the code specialist stays hot. If they switch to summarization, the least-used model gets evicted. The dispatcher stays pinned since it's needed for every query.

## Alternatives to Revisit

- **Preload top 2 (Option C):** If analytics show 80%+ of queries go to chat, preloading it may be worth the RAM tradeoff
- **Unload after query (Option B):** Useful as a fallback on low-RAM devices (older iPhones)
