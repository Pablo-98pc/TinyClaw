import XCTest
@testable import TinyClawCore

final class IntentTests: XCTestCase {
    func testAllCasesExist() {
        let cases = Intent.allCases
        XCTAssertEqual(cases.count, 4)
        XCTAssertTrue(cases.contains(.chat))
        XCTAssertTrue(cases.contains(.summarize))
        XCTAssertTrue(cases.contains(.task))
        XCTAssertTrue(cases.contains(.event))
    }

    func testRawValues() {
        XCTAssertEqual(Intent.chat.rawValue, "chat")
        XCTAssertEqual(Intent.summarize.rawValue, "summarize")
        XCTAssertEqual(Intent.task.rawValue, "task")
        XCTAssertEqual(Intent.event.rawValue, "event")
    }
}
