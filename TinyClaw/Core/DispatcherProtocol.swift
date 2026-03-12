import Foundation

/// Protocol for intent classification.
/// The dispatcher is always pinned in memory (exempt from LRU eviction).
public protocol DispatcherProtocol: AnyObject {
    /// Whether the dispatcher model is loaded.
    var isLoaded: Bool { get }

    /// Memory footprint in bytes.
    var memoryFootprint: Int { get }

    /// Load the classifier model.
    func load() async throws

    /// Release the classifier model.
    func unload()

    /// Classify user input into an Intent.
    /// Target latency: <50ms.
    func classify(input: String) async throws -> Intent
}
