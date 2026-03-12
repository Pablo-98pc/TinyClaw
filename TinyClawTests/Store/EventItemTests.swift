import XCTest
import SwiftData
@testable import TinyClawStore

final class EventItemTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: EventItem.self, configurations: config)
        context = ModelContext(container)
    }

    func testCreateEvent() throws {
        let event = EventItem(title: "Standup", date: Date(), startTime: "09:00", endTime: "09:30")
        context.insert(event)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<EventItem>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.title, "Standup")
        XCTAssertEqual(fetched.first?.startTime, "09:00")
    }

    func testCreateRecurringEvent() throws {
        let event = EventItem(title: "Weekly sync", date: Date(), recurrence: "weekly")
        context.insert(event)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<EventItem>())
        XCTAssertEqual(fetched.first?.recurrence, "weekly")
    }

    func testDeleteEvent() throws {
        let event = EventItem(title: "Delete me", date: Date())
        context.insert(event)
        try context.save()

        context.delete(event)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<EventItem>())
        XCTAssertEqual(fetched.count, 0)
    }
}
