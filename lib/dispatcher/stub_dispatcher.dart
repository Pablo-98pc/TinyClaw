import '../core/dispatcher.dart';
import '../core/intent.dart';

/// Keyword-based intent classifier for testing.
class StubDispatcher extends Dispatcher {
  @override
  Future<Intent> classify(String text) async {
    final lower = text.toLowerCase();

    if (lower.contains('summarize') || lower.contains('summary') || lower.contains('tldr')) {
      return Intent.summarize;
    }
    if (lower.contains('task') || lower.contains('todo') || lower.contains('remind')) {
      return Intent.task;
    }
    if (lower.contains('event') || lower.contains('meeting') || lower.contains('schedule')) {
      return Intent.event;
    }
    return Intent.chat;
  }
}
