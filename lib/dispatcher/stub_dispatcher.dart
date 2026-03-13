import '../core/dispatcher.dart';
import '../core/intent.dart';

/// Keyword-based intent classifier with priority disambiguation for 8 intents.
///
/// Priority order: summarize > search > note > habit > draft > task > event > chat
/// Disambiguation rules:
/// - "remind ... every" → habit (not task)
/// - "write down / write that" → note (not draft)
/// - "write a / draft / compose" → draft (not task)
class StubDispatcher extends Dispatcher {
  static final _summarize = RegExp(
    r'\b(summarize|summary|tldr|key\s+points|brief\b|condense|recap|overview|main\s+ideas)\b',
    caseSensitive: false,
  );

  static final _search = RegExp(
    r'\b(find|search|look\s+up|what\s+was|where\s+did\s+i|did\s+i\s+write|when\s+was\s+my)\b',
    caseSensitive: false,
  );

  static final _note = RegExp(
    r'\b(note\s+that|remember\s+that|jot\s+down|save\s+this|write\s+down|write\s+that|keep\s+in\s+mind)\b',
    caseSensitive: false,
  );

  static final _habit = RegExp(
    r'\b(every\s+day|every\s+morning|every\s+evening|every\s+\d+\s+hours?|daily|streak|habit)\b',
    caseSensitive: false,
  );

  /// "remind me to X every Y" → habit
  static final _remindEvery = RegExp(
    r'remind\s+me\s+to\s+.+\s+every\b',
    caseSensitive: false,
  );

  /// "track my [daily|weekly] X"
  static final _trackMy = RegExp(
    r'track\s+my\b',
    caseSensitive: false,
  );

  static final _draft = RegExp(
    r'\b(draft|compose|rewrite|rephrase|make\s+this\s+sound|shorten\s+this)\b',
    caseSensitive: false,
  );

  /// "write a [noun]" — draft intent (not note or task)
  static final _writeA = RegExp(
    r'write\s+a\s+',
    caseSensitive: false,
  );

  static final _task = RegExp(
    r'\b(task|todo|remind|buy|finish|complete|do\b|send|pick\s+up|clean|fix|update|check|get|prepare|need\s+to|have\s+to|don.t\s+forget)\b',
    caseSensitive: false,
  );

  static final _event = RegExp(
    r'\b(event|meeting|schedule|appointment|dinner|lunch)\b',
    caseSensitive: false,
  );

  static final _eventTime = RegExp(
    r'at\s+\d+\s*(?:am|pm)|on\s+(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday)',
    caseSensitive: false,
  );

  @override
  Future<Intent> classify(String text) async {
    final lower = text.toLowerCase();

    // 1. Summarize — highest priority
    if (_summarize.hasMatch(lower)) return Intent.summarize;

    // 2. Search
    if (_search.hasMatch(lower)) return Intent.search;

    // 3. Note — "write down / write that / note that / remember that"
    if (_note.hasMatch(lower)) return Intent.note;

    // 4. Habit — "every day", "streak", or "remind me to X every Y"
    if (_remindEvery.hasMatch(lower)) return Intent.habit;
    if (_trackMy.hasMatch(lower)) return Intent.habit;
    if (_habit.hasMatch(lower)) return Intent.habit;

    // 5. Draft — "write a ...", "draft", "compose", "rewrite"
    if (_writeA.hasMatch(lower)) return Intent.draft;
    if (_draft.hasMatch(lower)) return Intent.draft;

    // 6. Event — check before task because "schedule" and time patterns
    if (_event.hasMatch(lower)) return Intent.event;
    if (_eventTime.hasMatch(lower)) return Intent.event;

    // 7. Task
    if (_task.hasMatch(lower)) return Intent.task;

    // 8. Chat — default fallback
    return Intent.chat;
  }
}
