import 'dart:async';
import '../core/transcriber.dart';

/// Mock transcriber that returns hardcoded text for testing.
class StubTranscriber extends Transcriber {
  bool _isAvailable = true;
  bool _isTranscribing = false;
  StreamController<String>? _controller;

  @override
  bool get isAvailable => _isAvailable;

  set isAvailable(bool value) => _isAvailable = value;

  @override
  Stream<String> transcribe() {
    if (!_isAvailable) {
      return Stream.error(StateError('Transcriber not available'));
    }
    _controller = StreamController<String>();
    _isTranscribing = true;

    // Simulate transcription with hardcoded phrases
    Future(() async {
      final phrases = ['Hello', ' TinyClaw,', ' what', ' can', ' you', ' do?'];
      for (final phrase in phrases) {
        if (!_isTranscribing) break;
        await Future.delayed(const Duration(milliseconds: 50));
        if (_isTranscribing) _controller?.add(phrase);
      }
      await _controller?.close();
    });

    return _controller!.stream;
  }

  @override
  void stop() {
    _isTranscribing = false;
    _controller?.close();
    _controller = null;
  }
}
