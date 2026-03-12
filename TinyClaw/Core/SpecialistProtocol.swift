import Foundation

/// Errors that can occur during specialist operations.
public enum SpecialistError: Error, Equatable {
    case notLoaded
    case loadFailed(String)
    case inferenceFailed(String)
}

/// Protocol that all specialist models conform to.
/// Defines the lifecycle (load/unload) and inference interface.
public protocol SpecialistProtocol: AnyObject {
    /// Unique identifier for this specialist (e.g., "chat", "summarizer").
    var id: String { get }

    /// Whether the model is currently loaded in memory.
    var isLoaded: Bool { get }

    /// Reported memory footprint in bytes when loaded.
    var memoryFootprint: Int { get }

    /// Load the Core ML model into memory.
    func load() async throws

    /// Release the model from memory.
    func unload()

    /// Run inference on the input, streaming tokens back.
    /// Throws `SpecialistError.notLoaded` if called before `load()`.
    func predict(input: String) -> AsyncThrowingStream<String, Error>
}
