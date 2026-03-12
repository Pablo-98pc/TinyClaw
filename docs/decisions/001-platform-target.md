# Decision 001: Platform Target

**Date:** 2026-03-12
**Status:** Accepted
**Decision:** iOS first (Swift/SwiftUI + Core ML)

## Context

TinyClaw needs a mobile platform target. The core constraint is on-device ML inference performance.

## Options Considered

### A. Android first
- Wider device access, more flexible model runtime options (TFLite, ONNX, llama.cpp)
- Easier to sideload and test
- Kotlin/Java
- Hardware fragmentation makes performance unpredictable

### B. iOS first (Chosen)
- Core ML + Apple Neural Engine gives best perf-per-watt
- Tighter ecosystem but hardware is more consistent
- Swift/SwiftUI
- Smaller device matrix to test against

### C. Cross-platform (React Native)
- Ship to both from day one via llama.cpp as shared runtime via native modules
- More complexity upfront but broader reach
- Native module bridging adds latency and maintenance burden

### D. Desktop PoC first, mobile later
- Build dispatcher + specialist architecture as Python/desktop app
- Validate concept before dealing with mobile constraints
- Delays confronting real device limitations (RAM, thermals)

## Rationale

iOS gives the most predictable ML inference performance thanks to the Neural Engine and consistent hardware. Core ML is the most optimized runtime for Apple silicon. Smaller device matrix simplifies initial testing.

## Alternatives to Revisit

- **Android (Option A):** After iOS v0 ships, port using ExecuTorch or ONNX Runtime Mobile
- **Cross-platform (Option C):** Consider if user demand warrants both platforms simultaneously
