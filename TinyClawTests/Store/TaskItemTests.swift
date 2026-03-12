import XCTest
import SwiftData
@testable import TinyClawStore

final class TaskItemTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: TaskItem.self, configurations: config)
        context = ModelContext(container)
    }

    func testCreateTask() throws {
        let task = TaskItem(title: "Buy groceries", notes: "Milk, eggs")
        context.insert(task)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<TaskItem>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.title, "Buy groceries")
        XCTAssertFalse(fetched.first?.isCompleted ?? true)
    }

    func testToggleCompletion() throws {
        let task = TaskItem(title: "Test")
        context.insert(task)
        XCTAssertFalse(task.isCompleted)
        task.isCompleted = true
        XCTAssertTrue(task.isCompleted)
    }

    func testDeleteTask() throws {
        let task = TaskItem(title: "Delete me")
        context.insert(task)
        try context.save()

        context.delete(task)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<TaskItem>())
        XCTAssertEqual(fetched.count, 0)
    }
}
