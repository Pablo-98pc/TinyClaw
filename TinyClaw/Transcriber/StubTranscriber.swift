import Foundation
import AVFoundation
import TinyClawCore

/// Mock transcriber that returns canned text for development/testing.
public final class StubTranscriber: TranscriberProtocol {
    public private(set) var isLoaded: Bool = false
    public let memoryFootprint: Int = 0
    public var cannedTranscription: String = "Hello, this is a test transcription"

    public init() {}

    public func load() async throws {
        isLoaded = true
    }

    public func unload() {
        isLoaded = false
    }

    public func transcribe(audio: AVAudioBuffer) async throws -> String {
        return cannedTranscription
    }
}
