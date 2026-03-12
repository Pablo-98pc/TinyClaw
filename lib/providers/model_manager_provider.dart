import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/intent.dart';
import '../core/model_manager.dart';
import '../specialists/stub_specialist.dart';
import '../dispatcher/stub_dispatcher.dart';
import '../core/dispatcher.dart';

/// Provides the ModelManager with stub specialists registered.
final modelManagerProvider = Provider<ModelManager>((ref) {
  final manager = ModelManager();

  // Register stub specialists for each intent
  manager.register(Intent.chat, StubSpecialist(id: 'stub-chat', intent: Intent.chat, memoryFootprint: 100));
  manager.register(Intent.summarize, StubSpecialist(id: 'stub-summarize', intent: Intent.summarize, memoryFootprint: 100));
  manager.register(Intent.task, StubSpecialist(id: 'stub-task', intent: Intent.task, memoryFootprint: 100));
  manager.register(Intent.event, StubSpecialist(id: 'stub-event', intent: Intent.event, memoryFootprint: 100));

  // Pin the chat specialist (always available)
  manager.pin(Intent.chat);

  return manager;
});

/// Provides the Dispatcher (StubDispatcher for now).
final dispatcherProvider = Provider<Dispatcher>((ref) {
  return StubDispatcher();
});
