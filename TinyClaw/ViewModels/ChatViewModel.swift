import Foundation
import SwiftData
import TinyClawCore
import TinyClawStore

@Observable
final class ChatViewModel {
    private let modelManager: ModelManager
    private let dispatcher: DispatcherProtocol
    private let transcriber: TranscriberProtocol?
    private var modelContext: ModelContext

    var isProcessing = false
    var isRecording = false

    init(modelManager: ModelManager, dispatcher: DispatcherProtocol,
         transcriber: TranscriberProtocol? = nil, modelContext: ModelContext) {
        self.modelManager = modelManager
        self.dispatcher = dispatcher
        self.transcriber = transcriber
        self.modelContext = modelContext
    }

    /// Process a user message: dispatch intent, route to specialist, save response.
    func send(text: String, isVoice: Bool = false) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isProcessing = true
        defer { isProcessing = false }

        // Save user message
        let userMessage = Message(role: .user, content: text, isVoiceInput: isVoice)
        modelContext.insert(userMessage)

        do {
            // Classify intent
            let intent = try await dispatcher.classify(input: text)

            // Route to specialist
            let specialist: SpecialistProtocol
            switch intent {
            case .task, .event, .chat:
                specialist = try await modelManager.specialist(for: .chat)
            case .summarize:
                specialist = try await modelManager.specialist(for: .summarize)
            }

            // Collect streamed response
            var responseText = ""
            for try await token in specialist.predict(input: text) {
                responseText += token
            }

            // Handle structured output for task/event intents
            if intent == .task || intent == .event {
                let parsed = StructuredOutputParser.parse(responseText)
                switch parsed {
                case .task(let title, let dueDate, let notes):
                    let task = TaskItem(title: title, dueDate: dueDate, notes: notes)
                    modelContext.insert(task)
                case .event(let title, let date, let startTime, let endTime, let recurrence, let notes):
                    if let date = date {
                        let event = EventItem(title: title, date: date, startTime: startTime,
                                              endTime: endTime, recurrence: recurrence, notes: notes)
                        modelContext.insert(event)
                    } else {
                        // Date is required — fall back to asking user to rephrase
                        responseText = "I understood you want to create an event called \"\(title)\", but I couldn't determine the date. Could you rephrase with a specific date?"
                    }
                case .none:
                    break  // Malformed — response still shown as chat
                }
            }

            // Save assistant response
            let assistantMessage = Message(
                role: .assistant,
                content: responseText,
                specialistBadge: intent.rawValue
            )
            modelContext.insert(assistantMessage)

            try? modelContext.save()

        } catch {
            // Error handling: show graceful message
            let errorMessage = Message(
                role: .assistant,
                content: "Something went wrong. Try asking again.",
                specialistBadge: "chat"
            )
            modelContext.insert(errorMessage)
            try? modelContext.save()
        }
    }
}
