import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/dispatcher.dart';
import '../core/intent.dart';
import '../core/model_manager.dart';
import '../store/database.dart';
import '../store/habit_dao.dart';
import '../store/search_dao.dart';
import '../store/structured_output_parser.dart';
import 'database_provider.dart';
import 'model_manager_provider.dart';

/// Orchestrates the chat flow: send → classify → predict → parse → persist.
class ChatNotifier extends Notifier<bool> {
  @override
  bool build() => false; // isProcessing

  MessageDao get _messageDao => ref.read(messageDaoProvider);
  TaskDao get _taskDao => ref.read(taskDaoProvider);
  EventDao get _eventDao => ref.read(eventDaoProvider);
  NoteDao get _noteDao => ref.read(noteDaoProvider);
  HabitDao get _habitDao => ref.read(habitDaoProvider);
  SearchDao get _searchDao => ref.read(searchDaoProvider);
  ModelManager get _modelManager => ref.read(modelManagerProvider);
  Dispatcher get _dispatcher => ref.read(dispatcherProvider);

  Future<void> send(String text) async {
    if (state) return; // already processing
    state = true;

    try {
      // 1. Persist user message
      await _messageDao.insertMessage(MessagesCompanion.insert(
        role: 'user',
        content: text,
      ));

      // 2. Classify intent
      final intent = await _dispatcher.classify(text);

      // 3. Search goes directly to DAO — no specialist needed
      if (intent == Intent.search) {
        final searchQuery = _extractSearchQuery(text);
        final results = await _searchDao.search(searchQuery);
        final msg = results.isEmpty
          ? "I couldn't find anything matching that."
          : _formatSearchResults(results);
        await _messageDao.insertMessage(MessagesCompanion.insert(
          role: 'assistant',
          content: msg,
          specialistBadge: Value(intent.name),
        ));
        return; // skip specialist predict
      }

      // 4. Get specialist
      final specialist = await _modelManager.specialist(intent);
      _modelManager.markActive(intent);

      // 5. Collect streaming response
      final buffer = StringBuffer();
      try {
        await for (final chunk in specialist.predict(text)) {
          buffer.write(chunk);
        }
      } finally {
        _modelManager.markInactive(intent);
      }

      final response = buffer.toString().trim();

      // 6. Parse structured output
      final parsed = StructuredOutputParser.parse(response);
      if (parsed is TaskOutput) {
        await _taskDao.insertTask(TaskItemsCompanion.insert(
          title: parsed.title,
          dueDate: parsed.dueDate != null
              ? Value(DateTime.tryParse(parsed.dueDate!))
              : const Value.absent(),
          notes: parsed.notes != null ? Value(parsed.notes) : const Value.absent(),
        ));
      } else if (parsed is EventOutput) {
        await _eventDao.insertEvent(EventItemsCompanion.insert(
          title: parsed.title,
          date: DateTime.tryParse(parsed.date) ?? DateTime.now(),
          startTime: parsed.startTime != null ? Value(parsed.startTime) : const Value.absent(),
          endTime: parsed.endTime != null ? Value(parsed.endTime) : const Value.absent(),
          recurrence: parsed.recurrence != null ? Value(parsed.recurrence) : const Value.absent(),
          notes: parsed.notes != null ? Value(parsed.notes) : const Value.absent(),
        ));
      } else if (parsed is NoteOutput) {
        await _noteDao.insertNote(NoteItemsCompanion.insert(
          content: parsed.content,
          title: Value(parsed.title),
          tags: parsed.tags != null ? Value(parsed.tags!.join(',')) : const Value.absent(),
        ));
      } else if (parsed is HabitOutput) {
        await _habitDao.insertHabit(
          parsed.title,
          parsed.frequency,
          targetTime: parsed.targetTime,
        );
      }
      // DraftOutput and search don't persist — drafts display inline

      // 7. Persist assistant message
      await _messageDao.insertMessage(MessagesCompanion.insert(
        role: 'assistant',
        content: response,
        specialistBadge: Value(intent.name),
      ));
    } catch (e) {
      // Persist error as assistant message
      await _messageDao.insertMessage(MessagesCompanion.insert(
        role: 'assistant',
        content: 'Sorry, something went wrong: ${e.toString()}',
      ));
    } finally {
      state = false;
    }
  }

  /// Strips leading search command words so "find plumber" → "plumber".
  String _extractSearchQuery(String text) {
    final stripped = text.replaceFirst(
      RegExp(r'^(find|search\s+(for)?|look\s+up|what\s+was|where\s+did\s+i|did\s+i\s+write|when\s+was\s+my)\s+', caseSensitive: false),
      '',
    ).trim();
    return stripped.isEmpty ? text : stripped;
  }

  String _formatSearchResults(SearchResults results) {
    final parts = <String>[];
    if (results.notes.isNotEmpty) {
      parts.add('Notes: ${results.notes.map((n) => n.title.isEmpty ? n.content : n.title).join(', ')}');
    }
    if (results.tasks.isNotEmpty) {
      parts.add('Tasks: ${results.tasks.map((t) => t.title).join(', ')}');
    }
    if (results.events.isNotEmpty) {
      parts.add('Events: ${results.events.map((e) => e.title).join(', ')}');
    }
    if (results.habits.isNotEmpty) {
      parts.add('Habits: ${results.habits.map((h) => h.title).join(', ')}');
    }
    return 'Here\'s what I found:\n${parts.join('\n')}';
  }
}
