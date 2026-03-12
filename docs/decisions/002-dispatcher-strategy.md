# Decision 002: Dispatcher Strategy

**Date:** 2026-03-12
**Status:** Accepted
**Decision:** Fine-tuned BERT-tiny intent classifier (~17MB, <50ms)

## Context

The dispatcher is the routing brain of TinyClaw. It classifies user intent and routes to the correct specialist. It must be fast (<50ms), small, and accurate across 3+ intent categories.

## Options Considered

### A. Fine-tuned BERT-tiny classifier (Chosen)
- Train a small intent classifier on ~1-2k labeled examples per intent
- ~4.4M params, ~17MB after quantization
- Fast inference (<50ms), well-understood training pipeline
- Requires building/curating a labeled intent dataset

### B. Embedding similarity (sentence-transformers + cosine lookup)
- Embed the query, compare against intent centroid vectors
- No labeled training data needed — define centroids from example sentences
- Less precise decision boundaries, harder to tune
- Larger model (~80-120MB for a sentence-transformer)

### C. Rule-based heuristics
- Keyword matching + regex patterns
- Zero ML complexity, ship immediately
- Brittle — fails on ambiguous or novel inputs
- Good as a v0 prototype, not production-grade

## Rationale

BERT-tiny is the best balance of accuracy, size, and speed. The training dataset can be synthetically generated and iteratively improved. The model converts cleanly to Core ML.

## Alternatives to Revisit

- **Embedding similarity (Option B):** Useful if labeled data proves too expensive to curate, or as a fallback for out-of-distribution queries
- **Rule-based (Option C):** Could serve as an initial stub during development before the BERT model is trained
