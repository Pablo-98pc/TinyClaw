import XCTest
@testable import TinyClawStore

final class StructuredOutputParserTests: XCTestCase {

    // MARK: - Task Parsing

    func testParsesValidTaskJSON() throws {
        let response = """
        Got it! I've added your task.
        ```json
        { "type": "task", "title": "Buy groceries", "dueDate": "2026-03-13T17:00:00", "notes": "" }
        ```
        """
        let result = StructuredOutputParser.parse(response)
        guard case .task(let title, let dueDate, let notes) = result else {
            XCTFail("Expected .task, got \(result)")
            return
        }
        XCTAssertEqual(title, "Buy groceries")
        XCTAssertNotNil(dueDate)
        XCTAssertEqual(notes, "")
    }

    func testParsesTaskWithoutCodeFence() throws {
        let response = """
        Sure! { "type": "task", "title": "Call dentist", "dueDate": "2026-03-14T10:00:00", "notes": "Ask about cleaning" }
        """
        let result = StructuredOutputParser.parse(response)
        guard case .task(let title, _, let notes) = result else {
            XCTFail("Expected .task, got \(result)")
            return
        }
        XCTAssertEqual(title, "Call dentist")
        XCTAssertEqual(notes, "Ask about cleaning")
    }

    // MARK: - Event Parsing

    func testParsesValidEventJSON() throws {
        let response = """
        ```json
        { "type": "event", "title": "Team standup", "date": "2026-03-14", "startTime": "09:00", "endTime": "09:30", "recurrence": "weekly", "notes": "" }
        ```
        """
        let result = StructuredOutputParser.parse(response)
        guard case .event(let title, _, _, _, let recurrence, _) = result else {
            XCTFail("Expected .event, got \(result)")
            return
        }
        XCTAssertEqual(title, "Team standup")
        XCTAssertEqual(recurrence, "weekly")
    }

    // MARK: - Failure Cases

    func testReturnNoneForMalformedJSON() {
        let response = "Here's your task: { broken json }"
        let result = StructuredOutputParser.parse(response)
        guard case .none = result else {
            XCTFail("Expected .none for malformed JSON, got \(result)")
            return
        }
    }

    func testReturnNoneForNoJSON() {
        let response = "I don't understand, could you rephrase?"
        let result = StructuredOutputParser.parse(response)
        guard case .none = result else {
            XCTFail("Expected .none, got \(result)")
            return
        }
    }

    func testReturnNoneForMissingTitle() {
        let response = """
        { "type": "task", "dueDate": "2026-03-13T17:00:00" }
        """
        let result = StructuredOutputParser.parse(response)
        guard case .none = result else {
            XCTFail("Expected .none for missing title, got \(result)")
            return
        }
    }
}
