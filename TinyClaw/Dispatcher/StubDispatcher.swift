import Foundation
import TinyClawCore

/// A keyword-based dispatcher for development and testing.
/// Replaces the real BERT-tiny dispatcher until the model is trained.
public final class StubDispatcher: DispatcherProtocol {
    public private(set) var isLoaded: Bool = false
    public let memoryFootprint: Int = 0  // No real model

    private let summarizeKeywords = ["summarize", "summary", "summarise", "tldr", "shorten", "brief"]
    private let taskKeywords = ["task", "todo", "remind me", "reminder", "add a task", "create a task"]
    private let eventKeywords = ["event", "meeting", "appointment", "schedule", "calendar", "create an event"]

    public init() {}

    public func load() async throws {
        isLoaded = true
    }

    public func unload() {
        isLoaded = false
    }

    public func classify(input: String) async throws -> Intent {
        let lowered = input.lowercased()

        for keyword in taskKeywords {
            if lowered.contains(keyword) { return .task }
        }
        for keyword in eventKeywords {
            if lowered.contains(keyword) { return .event }
        }
        for keyword in summarizeKeywords {
            if lowered.contains(keyword) { return .summarize }
        }

        return .chat
    }
}
