import 'dart:convert';

/// Result of parsing a specialist's response for structured data.
sealed class ParsedOutput {
  const ParsedOutput();
}

class TaskOutput extends ParsedOutput {
  final String title;
  final String? dueDate;
  final String? notes;
  const TaskOutput({required this.title, this.dueDate, this.notes});
}

class EventOutput extends ParsedOutput {
  final String title;
  final String date;
  final String? startTime;
  final String? endTime;
  final String? recurrence;
  final String? notes;
  const EventOutput({
    required this.title,
    required this.date,
    this.startTime,
    this.endTime,
    this.recurrence,
    this.notes,
  });
}

class NoOutput extends ParsedOutput {
  const NoOutput();
}

/// Parses specialist responses looking for embedded JSON task/event data.
class StructuredOutputParser {
  static ParsedOutput parse(String text) {
    // Try fenced code block first: ```json\n{...}\n```
    final fencedPattern = RegExp(r'```(?:json)?\s*\n?([\s\S]*?)\n?```');
    final fencedMatch = fencedPattern.firstMatch(text);
    if (fencedMatch != null) {
      final result = _tryParseJson(fencedMatch.group(1)!.trim());
      if (result != null) return result;
    }

    // Try raw JSON
    final jsonPattern = RegExp(r'\{[\s\S]*\}');
    final jsonMatch = jsonPattern.firstMatch(text);
    if (jsonMatch != null) {
      final result = _tryParseJson(jsonMatch.group(0)!.trim());
      if (result != null) return result;
    }

    return const NoOutput();
  }

  static ParsedOutput? _tryParseJson(String jsonStr) {
    try {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      final type = map['type'] as String?;

      if (type == 'task') {
        return TaskOutput(
          title: map['title'] as String? ?? '',
          dueDate: map['dueDate'] as String?,
          notes: map['notes'] as String?,
        );
      }

      if (type == 'event') {
        return EventOutput(
          title: map['title'] as String? ?? '',
          date: map['date'] as String? ?? '',
          startTime: map['startTime'] as String?,
          endTime: map['endTime'] as String?,
          recurrence: map['recurrence'] as String?,
          notes: map['notes'] as String?,
        );
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
