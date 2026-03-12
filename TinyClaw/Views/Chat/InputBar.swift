import SwiftUI

struct InputBar: View {
    @Binding var text: String
    var onSend: () -> Void
    var onMicTap: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            TextField("Message TinyClaw...", text: $text)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
                .onSubmit { if !text.isEmpty { onSend() } }

            Button(action: onMicTap) {
                Image(systemName: "mic.fill")
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Color.red)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
