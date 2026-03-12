# TinyClaw

On-device multi-model AI assistant for iOS. Runs entirely locally — no cloud, no data leaves your phone.

## Features (v0)

- **Chat** — General conversation powered by Llama 3.2 1B
- **Summarize** — Text summarization via DistilBART
- **Voice Input** — Push-to-talk with Whisper speech-to-text
- **Tasks** — Create and manage tasks through natural language
- **Events** — Create and manage calendar events through conversation

All inference runs on-device via Core ML on the Apple Neural Engine.

## Architecture

A lightweight BERT-tiny dispatcher classifies user intent (<50ms) and routes to the appropriate specialist model. A central ModelManager handles model lifecycle with LRU eviction under a 4GB RAM budget.

Total model footprint: ~817MB (4-bit quantized).

## Requirements

- iOS 17+
- Xcode 15+
- iPhone with A14 chip or later (for Neural Engine performance)

## Project Structure

- `TinyClaw/Core/` — Protocols, ModelManager, Intent types
- `TinyClaw/Specialists/` — Core ML model wrappers
- `TinyClaw/Dispatcher/` — Intent classification
- `TinyClaw/Transcriber/` — Speech-to-text
- `TinyClaw/Store/` — SwiftData models + JSON parser
- `TinyClaw/Views/` — SwiftUI interface
- `TinyClaw/ViewModels/` — Orchestration layer
- `docs/decisions/` — Architecture Decision Records
- `docs/superpowers/specs/` — Design specifications

## Development

The project currently uses stub models for development. Real Core ML models will be integrated as they are converted and quantized.

## License

TBD
