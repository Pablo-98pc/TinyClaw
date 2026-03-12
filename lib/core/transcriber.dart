/// Base class for speech-to-text transcription.
abstract class Transcriber {
  bool get isAvailable;
  Stream<String> transcribe();
  void stop();
}
