import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/core/intent.dart';
import 'package:tinyclaw/core/model_manager.dart';
import 'package:tinyclaw/core/specialist_error.dart';
import 'package:tinyclaw/specialists/stub_specialist.dart';

void main() {
  group('ModelManager', () {
    late ModelManager manager;

    StubSpecialist makeSpecialist(Intent intent, {int memory = 100}) {
      return StubSpecialist(id: intent.name, intent: intent, memoryFootprint: memory);
    }

    setUp(() {
      manager = ModelManager(memoryBudget: 300);
    });

    test('register and retrieve specialist', () async {
      final s = makeSpecialist(Intent.chat);
      manager.register(Intent.chat, s);
      final result = await manager.specialist(Intent.chat);
      expect(result, s);
      expect(s.isLoaded, true);
    });

    test('specialist throws NotLoadedError for unregistered intent', () {
      expect(
        () => manager.specialist(Intent.chat),
        throwsA(isA<NotLoadedError>()),
      );
    });

    test('pin and loadPinned loads pinned specialists', () async {
      final s = makeSpecialist(Intent.chat);
      manager.register(Intent.chat, s);
      manager.pin(Intent.chat);
      await manager.loadPinned();
      expect(s.isLoaded, true);
      expect(manager.pinnedIntents, contains(Intent.chat));
    });

    test('pin throws for unregistered intent', () {
      expect(
        () => manager.pin(Intent.chat),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('evicts LRU specialist when over budget', () async {
      final chat = makeSpecialist(Intent.chat, memory: 150);
      final summarize = makeSpecialist(Intent.summarize, memory: 150);
      final task = makeSpecialist(Intent.task, memory: 150);

      manager.register(Intent.chat, chat);
      manager.register(Intent.summarize, summarize);
      manager.register(Intent.task, task);

      await manager.specialist(Intent.chat);
      await manager.specialist(Intent.summarize);
      // Budget is 300, both loaded = 300. Loading task (150) needs eviction.
      await manager.specialist(Intent.task);

      // chat was LRU, should be evicted
      expect(chat.isLoaded, false);
      expect(summarize.isLoaded, true);
      expect(task.isLoaded, true);
    });

    test('pinned specialists are not evicted', () async {
      final chat = makeSpecialist(Intent.chat, memory: 150);
      final summarize = makeSpecialist(Intent.summarize, memory: 150);
      final task = makeSpecialist(Intent.task, memory: 150);

      manager.register(Intent.chat, chat);
      manager.register(Intent.summarize, summarize);
      manager.register(Intent.task, task);

      manager.pin(Intent.chat);
      await manager.loadPinned();
      await manager.specialist(Intent.summarize);
      // chat(pinned)+summarize = 300. Loading task needs eviction.
      // chat is pinned so summarize gets evicted.
      await manager.specialist(Intent.task);

      expect(chat.isLoaded, true); // pinned, protected
      expect(summarize.isLoaded, false); // evicted
      expect(task.isLoaded, true);
    });

    test('active specialists are not evicted', () async {
      final chat = makeSpecialist(Intent.chat, memory: 150);
      final summarize = makeSpecialist(Intent.summarize, memory: 150);
      final task = makeSpecialist(Intent.task, memory: 150);

      manager.register(Intent.chat, chat);
      manager.register(Intent.summarize, summarize);
      manager.register(Intent.task, task);

      await manager.specialist(Intent.chat);
      await manager.specialist(Intent.summarize);
      manager.markActive(Intent.chat); // protect chat
      // Loading task: chat is active, summarize is evictable
      await manager.specialist(Intent.task);

      expect(chat.isLoaded, true); // active, protected
      expect(summarize.isLoaded, false); // evicted
      expect(task.isLoaded, true);
    });

    test('markActive and markInactive toggles protection', () async {
      final chat = makeSpecialist(Intent.chat, memory: 150);
      final summarize = makeSpecialist(Intent.summarize, memory: 150);
      final task = makeSpecialist(Intent.task, memory: 150);

      manager.register(Intent.chat, chat);
      manager.register(Intent.summarize, summarize);
      manager.register(Intent.task, task);

      await manager.specialist(Intent.chat);
      manager.markActive(Intent.chat);
      manager.markInactive(Intent.chat); // no longer protected
      await manager.specialist(Intent.summarize);
      await manager.specialist(Intent.task);

      expect(chat.isLoaded, false); // was LRU and no longer active
    });

    test('handleMemoryWarning evicts non-essential', () async {
      final chat = makeSpecialist(Intent.chat, memory: 100);
      final summarize = makeSpecialist(Intent.summarize, memory: 100);

      manager.register(Intent.chat, chat);
      manager.register(Intent.summarize, summarize);
      manager.pin(Intent.chat);

      await manager.loadPinned();
      await manager.specialist(Intent.summarize);

      manager.handleMemoryWarning();

      expect(chat.isLoaded, true); // pinned
      expect(summarize.isLoaded, false); // evicted
    });

    test('enters degradation mode when cannot free enough memory', () async {
      // Budget of 300, but all specialists are pinned
      manager = ModelManager(memoryBudget: 100);
      final chat = makeSpecialist(Intent.chat, memory: 100);
      final summarize = makeSpecialist(Intent.summarize, memory: 100);

      manager.register(Intent.chat, chat);
      manager.register(Intent.summarize, summarize);
      manager.pin(Intent.chat);
      manager.pin(Intent.summarize);

      await manager.loadPinned();
      expect(manager.isDegraded, false);

      manager.handleMemoryWarning();
      expect(manager.isDegraded, true);
    });

    test('currentMemoryUsage tracks loaded specialists', () async {
      final chat = makeSpecialist(Intent.chat, memory: 100);
      final summarize = makeSpecialist(Intent.summarize, memory: 200);

      manager.register(Intent.chat, chat);
      manager.register(Intent.summarize, summarize);

      expect(manager.currentMemoryUsage, 0);
      await manager.specialist(Intent.chat);
      expect(manager.currentMemoryUsage, 100);
      await manager.specialist(Intent.summarize);
      expect(manager.currentMemoryUsage, 300);
      chat.unload();
      expect(manager.currentMemoryUsage, 200);
    });
  });
}
