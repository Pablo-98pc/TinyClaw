import SwiftUI
import TinyClawStore

struct EventRow: View {
    let event: EventItem

    private var accentColor: Color {
        if event.recurrence != nil { return .purple }
        return .blue
    }

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(accentColor)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 14, weight: .medium))

                HStack(spacing: 4) {
                    Text(event.date, style: .date)
                    if let start = event.startTime, let end = event.endTime {
                        Text("\(start) - \(end)")
                    } else if let start = event.startTime {
                        Text(start)
                    }
                }
                .font(.system(size: 11))
                .foregroundStyle(.secondary)

                if let recurrence = event.recurrence {
                    Text("Repeats \(recurrence)")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.leading, 12)

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
