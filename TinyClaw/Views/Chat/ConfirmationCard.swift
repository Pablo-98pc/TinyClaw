import SwiftUI

/// Inline confirmation card shown when a task or event is created via chat.
struct ConfirmationCard: View {
    let data: Data

    struct Data {
        let title: String
        let subtitle: String  // e.g., "Tomorrow, 5:00 PM" or "March 14, 9:00 AM - 9:30 AM"
        let intent: Intent
    }

    private var accentColor: Color {
        data.intent == .task ? .blue : .purple
    }

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(accentColor)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 2) {
                Text(data.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(accentColor)
                Text(data.subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(8)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
