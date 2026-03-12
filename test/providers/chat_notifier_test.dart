import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/core/intent.dart';
import 'package:tinyclaw/providers/chat_provider.dart';
import 'package:tinyclaw/providers/database_provider.dart';
import 'package:tinyclaw/providers/model_manager_provider.dart';
import 'package:tinyclaw/store/database.dart';
import 'package:tinyclaw/specialists/stub_specialist.dart';
import 'package:tinyclaw/dispatcher/stub_dispatcher.dart';
import 'package:tinyclaw/core/model_manager.dart';
import 'package:tinyclaw/core/dispatcher.dart';

void main() {
  group('ChatNotifier', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());

      final testManager = ModelManager();
      for (final intent in Intent.values) {
        testManager.register(intent, StubSpecialist(id: 'test-${intent.name}', intent: intent));
      }

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          modelManagerProvider.overrideWithValue(testManager),
          dispatcherProvider.overrideWithValue(StubDispatcher()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      db.close();
    });

    test('send persists user and assistant messages', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      await notifier.send('Hello there');

      final messages = await db.messageDao.allMessages();
      expect(messages.length, 2);
      expect(messages[0].role, 'user');
      expect(messages[0].content, 'Hello there');
      expect(messages[1].role, 'assistant');
      expect(messages[1].specialistBadge, 'chat');
    });

    test('send creates task from structured output', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      await notifier.send('Add a task to buy groceries');

      final tasks = await db.taskDao.allTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, contains('task'));
    });

    test('send creates event from structured output', () async {
      final notifier = container.read(chatNotifierProvider.notifier);
      await notifier.send('Schedule a meeting tomorrow');

      final events = await db.eventDao.allEvents();
      expect(events.length, 1);
    });

    test('handles specialist error gracefully', () async {
      // Register a failing specialist for chat
      final failManager = ModelManager();
      final failSpecialist = StubSpecialist(id: 'fail-chat', intent: Intent.chat, shouldFail: true);
      failManager.register(Intent.chat, failSpecialist);
      for (final intent in Intent.values.where((i) => i != Intent.chat)) {
        failManager.register(intent, StubSpecialist(id: 'test-${intent.name}', intent: intent));
      }

      final failContainer = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          modelManagerProvider.overrideWithValue(failManager),
          dispatcherProvider.overrideWithValue(StubDispatcher()),
        ],
      );

      final notifier = failContainer.read(chatNotifierProvider.notifier);
      await notifier.send('Hello');

      final messages = await db.messageDao.allMessages();
      expect(messages.length, 2);
      expect(messages[1].content, contains('Sorry'));

      failContainer.dispose();
    });
  });
}
