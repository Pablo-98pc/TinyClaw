import SwiftUI
import SwiftData

struct EventsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \EventItem.date) private var events: [EventItem]

    private var todayEvents: [EventItem] {
        events.filter { Calendar.current.isDateInToday($0.date) }
    }

    private var thisWeekEvents: [EventItem] {
        let cal = Calendar.current
        let startOfWeek = cal.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let endOfWeek = cal.date(byAdding: .day, value: 7, to: startOfWeek) ?? Date()
        return events.filter { !cal.isDateInToday($0.date) && $0.date >= startOfWeek && $0.date < endOfWeek }
    }

    private var upcomingEvents: [EventItem] {
        let cal = Calendar.current
        let endOfWeek = cal.date(byAdding: .day, value: 7,
            to: cal.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()) ?? Date()
        return events.filter { $0.date >= endOfWeek }
    }

    var body: some View {
        NavigationStack {
            List {
                if !todayEvents.isEmpty {
                    Section("Today") {
                        eventRows(todayEvents)
                    }
                }
                if !thisWeekEvents.isEmpty {
                    Section("This Week") {
                        eventRows(thisWeekEvents)
                    }
                }
                if !upcomingEvents.isEmpty {
                    Section("Upcoming") {
                        eventRows(upcomingEvents)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Events")
            .overlay {
                if events.isEmpty {
                    ContentUnavailableView(
                        "No Events",
                        systemImage: "calendar",
                        description: Text("Create events by chatting with TinyClaw")
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func eventRows(_ items: [EventItem]) -> some View {
        ForEach(items) { event in
            EventRow(event: event)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
        .onDelete { offsets in
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}
