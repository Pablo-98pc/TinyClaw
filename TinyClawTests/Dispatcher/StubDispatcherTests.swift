import XCTest
@testable import TinyClawCore
@testable import TinyClawDispatcher

final class StubDispatcherTests: XCTestCase {
    var dispatcher: StubDispatcher!

    override func setUp() async throws {
        dispatcher = StubDispatcher()
        try await dispatcher.load()
    }

    func testClassifiesChatIntent() async throws {
        let intent = try await dispatcher.classify(input: "Hello, how are you?")
        XCTAssertEqual(intent, .chat)
    }

    func testClassifiesSummarizeIntent() async throws {
        let intent = try await dispatcher.classify(input: "Summarize this article")
        XCTAssertEqual(intent, .summarize)
    }

    func testClassifiesTaskIntent() async throws {
        let intent = try await dispatcher.classify(input: "Add a task to buy groceries")
        XCTAssertEqual(intent, .task)
    }

    func testClassifiesEventIntent() async throws {
        let intent = try await dispatcher.classify(input: "Create an event for team meeting tomorrow")
        XCTAssertEqual(intent, .event)
    }

    func testDefaultsToChatForAmbiguousInput() async throws {
        let intent = try await dispatcher.classify(input: "something random")
        XCTAssertEqual(intent, .chat)
    }

    func testIsLoadedAfterLoad() async throws {
        XCTAssertTrue(dispatcher.isLoaded)
    }

    func testIsNotLoadedAfterUnload() async throws {
        dispatcher.unload()
        XCTAssertFalse(dispatcher.isLoaded)
    }
}
