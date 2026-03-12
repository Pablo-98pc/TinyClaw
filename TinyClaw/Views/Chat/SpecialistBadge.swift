import SwiftUI
import TinyClawCore

struct SpecialistBadge: View {
    let intent: Intent

    private var color: Color {
        switch intent {
        case .chat: return .green
        case .summarize: return .red
        case .task: return .blue
        case .event: return .purple
        }
    }

    var body: some View {
        Text(intent.rawValue.uppercased())
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
