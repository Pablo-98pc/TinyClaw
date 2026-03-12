import SwiftUI

struct MessageBubble: View {
    let content: String
    let isUser: Bool
    let specialistBadge: Intent?
    let isVoiceInput: Bool
    let confirmationCard: ConfirmationCard.Data?

    init(content: String, isUser: Bool, specialistBadge: Intent? = nil,
         isVoiceInput: Bool = false, confirmationCard: ConfirmationCard.Data? = nil) {
        self.content = content
        self.isUser = isUser
        self.specialistBadge = specialistBadge
        self.isVoiceInput = isVoiceInput
        self.confirmationCard = confirmationCard
    }

    var body: some View {
        HStack {
            if isUser { Spacer() }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                if isUser && isVoiceInput {
                    Text("VOICE")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.red)
                }

                if !isUser, let badge = specialistBadge {
                    SpecialistBadge(intent: badge)
                }

                Text(content)
                    .font(.system(size: 14))
                    .foregroundStyle(isUser ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isUser ? Color.blue : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                if !isUser, let card = confirmationCard {
                    ConfirmationCard(data: card)
                }
            }

            if !isUser { Spacer() }
        }
    }
}
