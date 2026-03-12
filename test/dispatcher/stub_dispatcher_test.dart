import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/core/intent.dart';
import 'package:tinyclaw/dispatcher/stub_dispatcher.dart';

void main() {
  group('StubDispatcher', () {
    late StubDispatcher dispatcher;

    setUp(() {
      dispatcher = StubDispatcher();
    });

    test('classifies "summarize" keywords as summarize', () async {
      expect(await dispatcher.classify('Please summarize this'), Intent.summarize);
      expect(await dispatcher.classify('Give me a summary'), Intent.summarize);
      expect(await dispatcher.classify('TLDR'), Intent.summarize);
    });

    test('classifies "task" keywords as task', () async {
      expect(await dispatcher.classify('Add a task'), Intent.task);
      expect(await dispatcher.classify('Add to my todo list'), Intent.task);
      expect(await dispatcher.classify('Remind me to buy milk'), Intent.task);
    });

    test('classifies "event" keywords as event', () async {
      expect(await dispatcher.classify('Create an event'), Intent.event);
      expect(await dispatcher.classify('Schedule a meeting'), Intent.event);
      expect(await dispatcher.classify('I have a meeting tomorrow'), Intent.event);
    });

    test('classifies unknown input as chat', () async {
      expect(await dispatcher.classify('Hello there'), Intent.chat);
      expect(await dispatcher.classify('What is the weather?'), Intent.chat);
    });

    test('classification is case-insensitive', () async {
      expect(await dispatcher.classify('SUMMARIZE THIS'), Intent.summarize);
      expect(await dispatcher.classify('Schedule A MEETING'), Intent.event);
    });

    test('prioritizes summarize over other keywords', () async {
      expect(await dispatcher.classify('summarize this task'), Intent.summarize);
    });

    test('prioritizes task over event when both present', () async {
      expect(await dispatcher.classify('task for the meeting'), Intent.task);
    });
  });
}
