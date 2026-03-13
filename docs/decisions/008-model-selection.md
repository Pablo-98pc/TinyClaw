# ADR 008: Chat Specialist Model Selection

**Status:** Accepted
**Date:** 2026-03-12
**Supersedes:** Parts of ADR 004 (model budget)

## Context

TinyClaw needs a primary chat/instruction-following model for on-device inference. The current plan uses Llama 3.2 1B (~500MB quantized) plus a separate DistilBART summarizer (~150MB). On March 2, 2026, Alibaba released the Qwen 3.5 small model series with significant quality improvements.

## Decision

Replace Llama 3.2 1B + DistilBART with **Qwen 3.5-4B** as a single unified specialist.

## Options Considered

### Option A: Keep Llama 3.2 1B + DistilBART (current)
- **Pros:** Small (~650MB combined), proven, well-documented Core ML conversion path
- **Cons:** Lower quality output, text-only, separate models for chat and summarization, limited context window (4K for Llama, 1K for DistilBART)

### Option B: Qwen 3.5-4B (chosen)
- **Pros:** Dramatically better quality, 262K context window, native multimodal (text + image + video), handles both chat and summarization, outperforms previous-gen 30B models
- **Cons:** ~2GB quantized (4x Llama), tighter headroom on 6GB iPhones, newer model with less community Core ML tooling

### Option C: Qwen 3.5-2B
- **Pros:** Smaller (~1GB), confirmed running on iPhone 17 via MLX
- **Cons:** Less capable than 4B for complex tasks (drafting, structured extraction)

### Option D: Qwen 3.5-9B
- **Pros:** Best quality in the family, beats GPT-OSS-120B on benchmarks
- **Cons:** 10-16GB RAM requirement — cannot co-exist with other models on current iPhones

## Rationale

The 4B model hits the sweet spot: quality is dramatically better than 1B-class models, it eliminates the need for a separate summarizer, and it fits within the 4GB memory budget (~2.2GB total with dispatcher + STT). The native multimodal capability future-proofs for photo-based features without adding another model.

## Risks

- 2GB footprint is tight on base iPhone 15/16 (6GB RAM) when Whisper is co-loaded
- Core ML conversion may require more testing (newer model, less community precedent)

## Mitigation

- Aggressive Whisper unloading (60s idle timeout)
- Device testing on 6GB targets before shipping
- Llama 3.2 1B remains as fallback if Qwen proves too heavy

## Revisit

- Qwen 3.5-9B when iPhone RAM increases (likely iPhone 18+)
- If 4B proves too heavy on base iPhones, drop to Qwen 3.5-2B
