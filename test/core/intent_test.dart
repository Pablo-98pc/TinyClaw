import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/core/intent.dart';

void main() {
  group('Intent', () {
    test('has exactly four values', () {
      expect(Intent.values.length, 4);
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
  });
}
