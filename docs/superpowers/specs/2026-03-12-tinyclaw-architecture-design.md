# TinyClaw Architecture Design

**Date:** 2026-03-12
**Status:** Approved

## Overview

TinyClaw is an open-source, on-device multi-model AI assistant for iOS. Instead of running one large language model, it runs several small specialist models coordinated by a lightweight dispatcher — achieving privacy, low latency, and offline capability without cloud dependency.

The v0 MVP provides: general chat, text summarization, voice input (speech-to-text), and local task/event management — all running entirely on-device.

## Architecture

### High-Level Data Flow

1. **Input:** User types text or taps the push-to-talk mic button
2. **STT (voice only):** Whisper base transcribes speech to text (~150MB)
3. **Dispatch:** BERT-tiny classifies intent in <50ms into one of: `chat`, `summarize`, `task`, `event`
4. **Routing:**
   - `chat` → Chat model responds conversationally
   - `summarize` → Summarizer processes text
   - `task` / `event` → Chat model extracts structured data → saves to SwiftData
5. **Response:** Streams back to the SwiftUI chat interface with a specialist badge

### Model Budget

| Model | Base | Params | Est. Size (4-bit) | Lifecycle |
|-------|------|--------|-------------------|-----------|
| Dispatcher | BERT-tiny | 4.4M | ~17MB | Pinned (always in memory) |
| Chat/Assistant | Llama 3.2 1B | 1B | ~500MB | LRU managed |
| Summarizer | DistilBART | 306M | ~150MB | LRU managed |
| Speech-to-Text | Whisper base | 74M | ~150MB | Loaded on voice input |
| **Total** | | | **~817MB** | |

Total footprint is ~817MB out of a 4GB RAM budget — 80% headroom for the OS and app overhead.

### Runtime

- **Core ML** as the primary inference runtime (optimized for Apple Neural Engine)
- **ExecuTorch** as a fallback for models that don't convert cleanly to Core ML
- All models quantized to 4-bit for size/speed

## Components

### SpecialistProtocol

Every specialist model conforms to this protocol:

- `load()` — load Core ML model into memory
- `unload()` — release from memory
- `predict(input: String) -> AsyncStream<String>` — run inference, stream tokens
- `memoryFootprint: Int` — reported size in bytes for LRU budget tracking
- `isLoaded: Bool` — current load state

### DispatcherProtocol

The intent classifier. Same load/unload lifecycle, but with:

- `classify(input: String) -> Intent` — returns `.chat`, `.summarize`, `.task`, or `.event`
- Always pinned in memory (exempt from LRU eviction)

### TranscriberProtocol

Wraps the Whisper model for speech-to-text:

- `transcribe(audio: AVAudioBuffer) -> String`
- Loaded on first voice input, stays loaded while mic session is active
- Unloaded after a timeout of inactivity

### ModelManager

Central coordinator that owns all model lifecycle:

- Maintains an LRU cache of loaded specialists
- Enforces 4GB RAM budget
- Routes dispatcher results to the correct specialist
- Handles eviction: when loading a new model would exceed budget, evicts the least-recently-used model
- Dispatcher is pinned and exempt from eviction

### LocalStore (SwiftData)

Three entities:

- **Task** — title, dueDate, isCompleted, notes, createdAt
- **Event** — title, date, startTime, endTime, recurrence, notes, createdAt
- **Message** — role (user/assistant), content, specialistBadge, timestamp

When the dispatcher classifies intent as `task` or `event`, the chat model outputs structured JSON. This gets parsed and saved to the SwiftData store. The UI reads directly from SwiftData for task/event views.

## UI Structure

Three tabs via a bottom tab bar. Chat is the hub — Tasks and Events are read-only views of data created through conversation.

### Chat Tab (Main Screen)

- Message bubbles: user on right (blue), assistant on left (dark)
- Each assistant message has a specialist badge above it: `CHAT`, `SUMMARIZE`, `TASK`, or `EVENT`
- Voice messages from the user show a `VOICE` label
- Task/event creation shows an inline confirmation card (title + date)
- Input bar: text field + push-to-talk mic button

### Tasks Tab

- Simple checklist view sorted by due date (pending first)
- Each item: checkbox, title, due date
- Completed items show strikethrough with green check
- Users can toggle completion and delete from this view

### Events Tab

- Timeline/list view grouped by day
- Each event: color-coded left border, title, time range, optional recurrence label
- Sections: "Today", "This week", "Upcoming"
- Users can delete from this view

### Key UX Principle

Users never fill out forms. They create tasks and events by talking to TinyClaw in the chat. The Tasks and Events tabs are views with toggle/delete capability, not creation interfaces.

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Platform | iOS 17+ |
| Language | Swift |
| UI Framework | SwiftUI |
| ML Runtime | Core ML (primary), ExecuTorch (fallback) |
| Local Storage | SwiftData |
| Audio Capture | AVFoundation |
| Concurrency | Swift async/await, AsyncStream for token streaming |

## Dispatcher Intent Categories

| Intent | Description | Handled By |
|--------|-------------|------------|
| `chat` | General conversation, Q&A | Chat specialist |
| `summarize` | Document/text summarization | Summarizer specialist |
| `task` | Create/list/update/delete tasks | Chat specialist → SwiftData |
| `event` | Create/list/update/delete events | Chat specialist → SwiftData |

## Memory Management

- **Strategy:** Lazy-load with LRU eviction
- **Budget:** 4GB hard cap
- **Pinned:** Dispatcher (always in memory, ~17MB)
- **LRU managed:** Chat, Summarizer (loaded on demand, evicted when budget exceeded)
- **Session-scoped:** Whisper STT (loaded on first voice input, unloaded after inactivity timeout)

## Scope Boundaries (v0)

### In Scope
- On-device chat with Llama 3.2 1B
- On-device summarization with DistilBART
- Push-to-talk voice input with Whisper base
- Local task management (create, list, complete, delete)
- Local event management (create, list, delete, recurrence)
- Intent classification via fine-tuned BERT-tiny
- LRU memory management with 4GB budget

### Out of Scope (Future)
- Translation specialist (NLLB-200 distilled)
- Vision specialist (MobileVLM / PaliGemma)
- Third-party calendar/task sync (Google Calendar, Apple Reminders)
- Always-listening wake word
- Android / cross-platform support
- Cloud fallback for complex queries
