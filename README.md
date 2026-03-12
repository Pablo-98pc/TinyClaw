# TinyClaw

On-device multi-model AI assistant for iOS, built with Flutter.

## Architecture

TinyClaw uses a mixture-of-experts pattern where a lightweight dispatcher routes user input to specialized ML models:

- **Dispatcher** — Classifies user input into intents (chat, summarize, task, event)
- **Specialists** — Intent-specific ML models (Llama 3.2 1B for chat, DistilBART for summarization)
- **ModelManager** — LRU memory management with 4GB budget, pinning, and active-stream protection
- **Platform Channels** — MethodChannel bridge to native Core ML runtime on iOS

## Tech Stack

- **Flutter 3.x** / Dart
- **Riverpod** — State management
- **drift** — SQLite local storage with reactive streams
- **Core ML** — Native ML runtime (via platform channels)

## Project Structure

```
lib/
  core/           # Intent, Specialist, Dispatcher, Transcriber, ModelManager
  specialists/    # StubSpecialist (real models coming soon)
  dispatcher/     # StubDispatcher (keyword-based, BERT-tiny planned)
  transcriber/    # StubTranscriber (Whisper planned)
  store/          # drift database, StructuredOutputParser
  platform/       # MlChannel (MethodChannel wrapper)
  providers/      # Riverpod providers
  views/          # UI screens (Chat, Tasks, Events)
```

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Dart 3.x

### Setup
```bash
git clone https://github.com/Pablo-98pc/TinyClaw.git
cd TinyClaw
flutter pub get
dart run build_runner build
```

### Run Tests
```bash
flutter test
```

### Run on iOS
```bash
flutter run
```

## Current Status (v0 — Stub Models)

All ML models are currently stubs with canned responses. The architecture is complete and ready for real model integration:

1. Replace `StubDispatcher` with BERT-tiny intent classifier
2. Replace `StubSpecialist` instances with Core ML model wrappers
3. Implement native iOS side of `com.tinyclaw/ml` MethodChannel
