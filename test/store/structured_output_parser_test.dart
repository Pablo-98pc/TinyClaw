import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/store/structured_output_parser.dart';

void main() {
  group('StructuredOutputParser', () {
    test('parses fenced JSON task', () {
      const input = 'Here is your task:\n```json\n{"type":"task","title":"Buy milk","dueDate":"2026-03-15"}\n```';
      final result = StructuredOutputParser.parse(input);
      expect(result, isA<TaskOutput>());
      final task = result as TaskOutput;
      expect(task.title, 'Buy milk');
      expect(task.dueDate, '2026-03-15');
    });

    test('parses fenced JSON event', () {
      const input = '```json\n{"type":"event","title":"Team standup","date":"2026-03-15","startTime":"09:00","endTime":"09:30","recurrence":"daily"}\n```';
      final result = StructuredOutputParser.parse(input);
      expect(result, isA<EventOutput>());
      final event = result as EventOutput;
      expect(event.title, 'Team standup');
      expect(event.date, '2026-03-15');
      expect(event.startTime, '09:00');
      expect(event.endTime, '09:30');
      expect(event.recurrence, 'daily');
    });

    test('parses raw JSON task', () {
      const input = '{"type":"task","title":"Call dentist"}';
      final result = StructuredOutputParser.parse(input);
      expect(result, isA<TaskOutput>());
      expect((result as TaskOutput).title, 'Call dentist');
    });

    test('parses raw JSON event', () {
      const input = 'Sure! {"type":"event","title":"Lunch","date":"2026-03-15"}';
      final result = StructuredOutputParser.parse(input);
      expect(result, isA<EventOutput>());
      expect((result as EventOutput).title, 'Lunch');
    });

    test('returns NoOutput for plain text', () {
      const input = 'Hello! I am TinyClaw, your AI assistant.';
      final result = StructuredOutputParser.parse(input);
      expect(result, isA<NoOutput>());
    });

    test('returns NoOutput for malformed JSON', () {
      const input = '```json\n{broken json}\n```';
      final result = StructuredOutputParser.parse(input);
      expect(result, isA<NoOutput>());
    });
  });
}
