import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/core/intent.dart';
import 'package:tinyclaw/core/specialist_error.dart';
import 'package:tinyclaw/specialists/stub_specialist.dart';

void main() {
  group('StubSpecialist', () {
    late StubSpecialist specialist;

    setUp(() {
      specialist = StubSpecialist(id: 'test-chat', intent: Intent.chat);
    });

    test('starts unloaded', () {
      expect(specialist.isLoaded, false);
    });

    test('load sets isLoaded to true', () async {
      await specialist.load();
      expect(specialist.isLoaded, true);
    });

    test('unload sets isLoaded to false', () async {
      await specialist.load();
      specialist.unload();
      expect(specialist.isLoaded, false);
    });

    test('predict streams canned response when loaded', () async {
      await specialist.load();
      final chunks = await specialist.predict('hello').toList();
      final response = chunks.join();
      expect(response.trim(), contains('TinyClaw'));
    });

    test('predict throws NotLoadedError when not loaded', () {
      expect(
        () => specialist.predict('hello').toList(),
        throwsA(isA<NotLoadedError>()),
      );
    });

    test('load throws LoadFailedError when shouldFail is true', () {
      specialist.shouldFail = true;
      expect(
        () => specialist.load(),
        throwsA(isA<LoadFailedError>()),
      );
    });

    test('reports memory footprint', () {
      final s = StubSpecialist(
        id: 'big', intent: Intent.chat, memoryFootprint: 500,
      );
      expect(s.memoryFootprint, 500);
    });
  });
}
