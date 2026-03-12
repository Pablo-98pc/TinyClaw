import XCTest
import SwiftData
@testable import TinyClawCore
@testable import TinyClawStore
@testable import TinyClawSpecialists
@testable import TinyClawDispatcher

final class ChatViewModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var manager: ModelManager!
    var dispatcher: StubDispatcher!
    var chatSpecialist: StubSpecialist!
    var summarizerSpecialist: StubSpecialist!
    var viewModel: ChatViewModel!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Message.self, TaskItem.self, EventItem.self, configurations: config)
        context = ModelContext(container)

        manager = ModelManager(budgetBytes: 4_000_000_000)
        dispatcher = StubDispatcher()
        try await dispatcher.load()

        chatSpecialist = StubSpecialist(id: "chat", memoryFootprint: 500_000_000)
        summarizerSpecialist = StubSpecialist(id: "summarizer", memoryFootprint: 150_000_000)
        manager.register(specialist: chatSpecialist, for: .chat)
        manager.register(specialist: summarizerSpecialist, for: .summarize)

        viewModel = ChatViewModel(modelManager: manager, dispatcher: dispatcher, modelContext: context)
    }

    func testChatIntentRoutesToChatSpecialist() async throws {
        chatSpecialist.cannedResponse = "Hello! How can I help?"
        await viewModel.send(text: "Hi there")

        let messages = try context.fetch(FetchDescriptor<Message>())
        XCTAssertEqual(messages.count, 2) // user + assistant
        XCTAssertEqual(messages.last?.specialistBadge, "chat")
    }

    func testSummarizeIntentRoutesToSummarizer() async throws {
        summarizerSpecialist.cannedResponse = "Here is the summary."
        await viewModel.send(text: "Summarize this text")

        let messages = try context.fetch(FetchDescriptor<Message>())
        XCTAssertEqual(messages.last?.specialistBadge, "summarize")
    }

    func testTaskIntentCreatesTaskItem() async throws {
        chatSpecialist.cannedResponse = """
        Got it! ```json
        { "type": "task", "title": "Buy milk", "dueDate": "2026-03-13T17:00:00", "notes": "" }
        ```
        """
        await viewModel.send(text: "Add a task to buy milk")

        let tasks = try context.fetch(FetchDescriptor<TaskItem>())
        XCTAssertEqual(tasks.count, 1)
        XCTAssertEqual(tasks.first?.title, "Buy milk")
    }

    func testErrorPathShowsGracefulMessage() async throws {
        chatSpecialist.shouldFailOnPredict = true
        await viewModel.send(text: "Hello")

        let messages = try context.fetch(FetchDescriptor<Message>())
        let lastMessage = messages.last
        XCTAssertEqual(lastMessage?.role, .assistant)
        XCTAssertTrue(lastMessage?.content.contains("Something went wrong") ?? false)
    }
}
