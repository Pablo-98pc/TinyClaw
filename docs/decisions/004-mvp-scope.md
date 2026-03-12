# Decision 004: MVP Specialist Scope

**Date:** 2026-03-12
**Status:** Accepted
**Decision:** 3 specialists for v0 — Chat, Code, and Summarizer

## Context

The full vision includes 5 specialists (chat, code, summarizer, translation, vision). More specialists means more integration work, model conversion, and testing before anything ships.

## Options Considered

### A. Chat + Code only
- Minimum viable scope — 2 specialists plus dispatcher
- Validates routing architecture with least effort
- Misses testing a different model architecture (seq2seq)

### B. Chat + Code + Summarizer (Chosen)
- 3 specialists covering two model types: decoder-only (chat, code) and seq2seq (summarizer)
- Tests the architecture with meaningfully different models
- Still manageable scope

### C. All 5 specialists
- Full vision from the project brief
- Much more integration work, model conversion, and testing
- Translation and vision add significant complexity (multilingual tokenizers, image pipelines)

## Rationale

Three specialists validate the architecture with two different model types (decoder-only LLMs and seq2seq). This confirms the specialist protocol and model manager work across architectures, without the complexity of multilingual or vision pipelines.

## Models for v0

| Specialist | Base Model | Est. Size (4-bit) |
|-----------|-----------|-------------------|
| Chat | Llama 3.2 1B | ~500MB |
| Code | Phi-3 Mini (3.8B) | ~2GB |
| Summarizer | DistilBART (306M) | ~150MB |
| Dispatcher | BERT-tiny (4.4M) | ~17MB |
| **Total** | | **~2.7GB** |

## Specialists to Add Later

- **Translation (NLLB-200 distilled):** ~300MB, adds multilingual support
- **Vision (MobileVLM / PaliGemma):** Adds image understanding, requires camera/photo integration
