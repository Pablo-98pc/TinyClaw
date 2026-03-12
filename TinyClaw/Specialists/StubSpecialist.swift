import Foundation
import TinyClawCore

/// A mock specialist that returns canned responses.
/// Used for testing ModelManager and UI without real Core ML models.
public final class StubSpecialist: SpecialistProtocol {
    public let id: String
    public private(set) var isLoaded: Bool = false
    public let memoryFootprint: Int
    public var cannedResponse: String
    public var shouldFailOnLoad: Bool = false
    public var shouldFailOnPredict: Bool = false

    /// Track how many times load/unload are called for test assertions.
    public private(set) var loadCount: Int = 0
    public private(set) var unloadCount: Int = 0

    public init(id: String, memoryFootprint: Int, cannedResponse: String = "Stub response") {
        self.id = id
        self.memoryFootprint = memoryFootprint
        self.cannedResponse = cannedResponse
    }

    public func load() async throws {
        if shouldFailOnLoad {
            throw SpecialistError.loadFailed("Simulated load failure for \(id)")
        }
        isLoaded = true
        loadCount += 1
    }

    public func unload() {
        isLoaded = false
        unloadCount += 1
    }

    public func predict(input: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            if !self.isLoaded {
                continuation.finish(throwing: SpecialistError.notLoaded)
                return
            }
            if self.shouldFailOnPredict {
                continuation.finish(throwing: SpecialistError.inferenceFailed("Simulated inference failure"))
                return
            }
            // Stream the response word by word to simulate token streaming
            let words = self.cannedResponse.split(separator: " ").map(String.init)
            for word in words {
                continuation.yield(word + " ")
            }
            continuation.finish()
        }
    }
}
