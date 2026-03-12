import SwiftUI
import SwiftData
import TinyClawCore
import TinyClawStore
import TinyClawDispatcher
import TinyClawSpecialists

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Message.timestamp) private var messages: [Message]
    @State private var inputText = ""
    @State private var viewModel: ChatViewModel?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                MessageBubble(
                                    content: message.content,
                                    isUser: message.role == .user,
                                    specialistBadge: message.specialistBadge.flatMap { Intent(rawValue: $0) },
                                    isVoiceInput: message.isVoiceInput
                                )
                                .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .onChange(of: messages.count) {
                        if let last = messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }

                Divider()

                InputBar(
                    text: $inputText,
                    onSend: sendMessage,
                    onMicTap: startVoiceInput
                )
            }
            .navigationTitle("TinyClaw")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if viewModel == nil {
                    let manager = ModelManager()
                    let dispatcher = StubDispatcher()
                    Task { try? await dispatcher.load() }

                    // Register stub specialists for development
                    let chatStub = StubSpecialist(id: "chat", memoryFootprint: 500_000_000,
                        cannedResponse: "I'm TinyClaw, your on-device assistant. How can I help?")
                    let summarizerStub = StubSpecialist(id: "summarizer", memoryFootprint: 150_000_000,
                        cannedResponse: "Here's a summary of the text you provided.")
                    manager.register(specialist: chatStub, for: .chat)
                    manager.register(specialist: summarizerStub, for: .summarize)

                    viewModel = ChatViewModel(
                        modelManager: manager,
                        dispatcher: dispatcher,
                        modelContext: modelContext
                    )
                }
            }
        }
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""

        Task {
            await viewModel?.send(text: text)
        }
    }

    private func startVoiceInput() {
        // TODO: Wire up TranscriberProtocol in a future task
    }
}
