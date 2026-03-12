import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Message.timestamp) private var messages: [Message]
    @State private var inputText = ""

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
        }
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let userMessage = Message(role: .user, content: text)
        modelContext.insert(userMessage)
        inputText = ""

        // TODO: Wire up ChatViewModel for dispatch → specialist → response
    }

    private func startVoiceInput() {
        // TODO: Wire up TranscriberProtocol for push-to-talk
    }
}
