import Foundation
import AVFoundation

/// Protocol for speech-to-text transcription.
/// Loaded on first voice input, unloaded after inactivity timeout.
public protocol TranscriberProtocol: AnyObject {
    /// Whether the transcriber model is loaded.
    var isLoaded: Bool { get }

    /// Memory footprint in bytes.
    var memoryFootprint: Int { get }

    /// Load the STT model.
    func load() async throws

    /// Release the STT model.
    func unload()

    /// Transcribe audio buffer to text.
    func transcribe(audio: AVAudioBuffer) async throws -> String
}
