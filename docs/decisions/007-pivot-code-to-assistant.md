# Decision 007: Pivot — Replace Code Specialist with Assistant Features

**Date:** 2026-03-12
**Status:** Accepted (supersedes parts of Decision 004)
**Decision:** Drop Code specialist, add Speech-to-Text and local task/event management

## Context

During architecture design, the Code specialist (Phi-3 Mini 3.8B, ~2GB) was reconsidered. Code generation on a phone has limited practical value. Instead, the app should focus on being a personal assistant with voice input and the ability to manage tasks and events locally.

## Changes from Decision 004

### Removed
- **Code Specialist (Phi-3 Mini 3.8B, ~2GB):** Dropped entirely

### Added
- **Speech-to-Text (Whisper base, ~150MB):** On-device voice transcription via push-to-talk
- **Task/Event management:** Not a separate model — handled by the chat specialist as a dispatcher intent category. Tasks and events stored locally (SwiftData/Core Data), no third-party integrations.

### Unchanged
- Chat Specialist (Llama 3.2 1B, ~500MB)
- Summarizer (DistilBART, ~150MB)
- Dispatcher (BERT-tiny, ~17MB)

## Revised Model Budget

| Model | Params | Est. Size (4-bit) |
|-------|--------|-------------------|
| Dispatcher (BERT-tiny) | 4.4M | ~17MB |
| Chat/Assistant (Llama 3.2 1B) | 1B | ~500MB |
| Summarizer (DistilBART) | 306M | ~150MB |
| Speech-to-Text (Whisper base) | 74M | ~150MB |
| **Total** | | **~817MB** |

## Revised Dispatcher Intent Categories

1. **chat** — general conversation, Q&A
2. **summarize** — document/text summarization
3. **task** — create/list/update/delete tasks
4. **event** — create/list/update/delete calendar events

## Rationale

- Saves ~2GB of RAM (Code model was the largest)
- Voice + task management is a more natural phone use case than code generation
- Local-only storage avoids third-party API complexity
- Chat model can extract structured task/event data without a dedicated model

## Voice Input Design

- Push-to-talk button (user taps mic, speaks, releases)
- Whisper base handles transcription on-device
- Transcribed text goes through the normal dispatcher flow
- No wake word, no always-listening (battery-friendly)
