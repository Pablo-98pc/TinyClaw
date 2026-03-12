import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/dispatcher.dart';
import '../core/model_manager.dart';
import '../store/database.dart';
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

      // 3. Get specialist
      final specialist = await _modelManager.specialist(intent);
      _modelManager.markActive(intent);

      // 4. Collect streaming response
      final buffer = StringBuffer();
      try {
        await for (final chunk in specialist.predict(text)) {
          buffer.write(chunk);
        }
      } finally {
        _modelManager.markInactive(intent);
      }

      final response = buffer.toString().trim();

      // 5. Parse structured output
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
      }

      // 6. Persist assistant message
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
}
