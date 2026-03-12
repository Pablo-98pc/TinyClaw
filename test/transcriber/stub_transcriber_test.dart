import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/transcriber/stub_transcriber.dart';

void main() {
  group('StubTranscriber', () {
    late StubTranscriber transcriber;

    setUp(() {
      transcriber = StubTranscriber();
    });

    tearDown(() {
      transcriber.stop();
    });

    test('is available by default', () {
      expect(transcriber.isAvailable, true);
    });

    test('transcribe returns stream of text chunks', () async {
      final chunks = await transcriber.transcribe().toList();
      final text = chunks.join();
      expect(text, contains('TinyClaw'));
    });

    test('transcribe errors when not available', () {
      transcriber.isAvailable = false;
      expect(
        () => transcriber.transcribe().toList(),
        throwsA(isA<StateError>()),
      );
    });

    test('stop halts transcription', () async {
      final stream = transcriber.transcribe();
      // Let some chunks come through then stop
      await Future.delayed(const Duration(milliseconds: 80));
      transcriber.stop();
      // Stream should have fewer chunks than full transcription
      final chunks = await stream.toList();
      expect(chunks.length, lessThanOrEqualTo(6));
    });
  });
}
