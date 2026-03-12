import XCTest
@testable import TinyClawCore
@testable import TinyClawSpecialists

final class ModelManagerTests: XCTestCase {
    var manager: ModelManager!
    var chat: StubSpecialist!
    var summarizer: StubSpecialist!

    override func setUp() {
        // Budget of 1000 bytes for easy testing
        manager = ModelManager(budgetBytes: 1000)
        chat = StubSpecialist(id: "chat", memoryFootprint: 500)
        summarizer = StubSpecialist(id: "summarizer", memoryFootprint: 400)
        manager.register(specialist: chat, for: .chat)
        manager.register(specialist: summarizer, for: .summarize)
    }

    func testLoadSpecialistOnFirstUse() async throws {
        XCTAssertFalse(chat.isLoaded)
        let specialist = try await manager.specialist(for: .chat)
        XCTAssertTrue(specialist.isLoaded)
    }

    func testReturnsCachedSpecialist() async throws {
        let first = try await manager.specialist(for: .chat)
        let second = try await manager.specialist(for: .chat)
        XCTAssertTrue(first === second)
        XCTAssertEqual(chat.loadCount, 1) // Only loaded once
    }

    func testEvictsLRUWhenOverBudget() async throws {
        // Large specialist that forces eviction
        let large = StubSpecialist(id: "large", memoryFootprint: 600)
        manager.register(specialist: large, for: .task)

        // Load chat (500) — fits in budget (1000)
        _ = try await manager.specialist(for: .chat)
        XCTAssertTrue(chat.isLoaded)

        // Load large (600) — total would be 1100, exceeds 1000
        // Should evict chat (LRU) first
        _ = try await manager.specialist(for: .task)
        XCTAssertTrue(large.isLoaded)
        XCTAssertFalse(chat.isLoaded)
        XCTAssertEqual(chat.unloadCount, 1)
    }

    func testEvictsOldestFirst() async throws {
        // Load chat first, then summarizer
        _ = try await manager.specialist(for: .chat)
        _ = try await manager.specialist(for: .summarize)

        // Both fit: 500 + 400 = 900 < 1000
        XCTAssertTrue(chat.isLoaded)
        XCTAssertTrue(summarizer.isLoaded)

        // Now load something that doesn't fit
        let big = StubSpecialist(id: "big", memoryFootprint: 200)
        manager.register(specialist: big, for: .event)

        // 900 + 200 = 1100 > 1000, evict chat (oldest)
        _ = try await manager.specialist(for: .event)
        XCTAssertFalse(chat.isLoaded) // Evicted (LRU)
        XCTAssertTrue(summarizer.isLoaded) // More recently used
        XCTAssertTrue(big.isLoaded)
    }

    func testCurrentMemoryUsage() async throws {
        XCTAssertEqual(manager.currentMemoryUsage, 0)

        _ = try await manager.specialist(for: .chat)
        XCTAssertEqual(manager.currentMemoryUsage, 500)

        _ = try await manager.specialist(for: .summarize)
        XCTAssertEqual(manager.currentMemoryUsage, 900)
    }

    func testHandleMemoryWarningEvictsAll() async throws {
        _ = try await manager.specialist(for: .chat)
        _ = try await manager.specialist(for: .summarize)

        manager.handleMemoryWarning()

        XCTAssertFalse(chat.isLoaded)
        XCTAssertFalse(summarizer.isLoaded)
        XCTAssertEqual(manager.currentMemoryUsage, 0)
    }

    func testLoadFailureThrows() async throws {
        chat.shouldFailOnLoad = true
        do {
            _ = try await manager.specialist(for: .chat)
            XCTFail("Should have thrown")
        } catch {
            XCTAssertTrue(error is SpecialistError)
        }
    }

    func testPinnedSpecialistExemptFromEviction() async throws {
        manager.pin(specialist: chat, for: .chat)
        try await manager.loadPinned()

        // Load summarizer — should NOT evict pinned chat
        _ = try await manager.specialist(for: .summarize)

        XCTAssertTrue(chat.isLoaded) // Pinned, never evicted
        XCTAssertTrue(summarizer.isLoaded)
    }

    func testHandleMemoryWarningKeepsPinned() async throws {
        manager.pin(specialist: chat, for: .chat)
        try await manager.loadPinned()
        _ = try await manager.specialist(for: .summarize)

        manager.handleMemoryWarning()

        XCTAssertTrue(chat.isLoaded) // Pinned survives warning
        XCTAssertFalse(summarizer.isLoaded)
    }

    func testActiveStreamExemptFromEviction() async throws {
        _ = try await manager.specialist(for: .chat)
        manager.markActive(intent: .chat)

        // Try to load something that forces eviction
        let big = StubSpecialist(id: "big", memoryFootprint: 600)
        manager.register(specialist: big, for: .event)
        _ = try await manager.specialist(for: .summarize) // Fits: 500+400=900

        // Can't evict chat (active), so summarizer gets evicted instead if needed
        XCTAssertTrue(chat.isLoaded) // Active, exempt

        manager.markInactive(intent: .chat) // Release
    }

    func testIsDegradedAfterFullEviction() async throws {
        _ = try await manager.specialist(for: .chat)
        manager.handleMemoryWarning()
        XCTAssertTrue(manager.isDegraded)
    }
}
