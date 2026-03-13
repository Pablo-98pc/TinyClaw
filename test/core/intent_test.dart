import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/core/intent.dart';

void main() {
  group('Intent', () {
    test('has exactly four values', () {
      expect(Intent.values.length, 8);
      expect(Intent.values, contains(Intent.chat));
      expect(Intent.values, contains(Intent.summarize));
      expect(Intent.values, contains(Intent.task));
      expect(Intent.values, contains(Intent.event));
    });

    test('round-trips through string', () {
      for (final intent in Intent.values) {
        expect(Intent.fromString(intent.name), intent);
      }
      expect(Intent.fromString('invalid'), isNull);
    });

    test('fromString returns habit', () {
      expect(Intent.fromString('habit'), Intent.habit);
    });
    test('fromString returns draft', () {
      expect(Intent.fromString('draft'), Intent.draft);
    });
    test('fromString returns search', () {
      expect(Intent.fromString('search'), Intent.search);
    });
    test('Intent.values contains 8 values', () {
      expect(Intent.values.length, 8);
    });
  });
}
