import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/core/intent.dart';
import 'package:tinyclaw/dispatcher/stub_dispatcher.dart';

void main() {
  late StubDispatcher dispatcher;

  setUp(() => dispatcher = StubDispatcher());

  // ── Summarize ──
  test('summarize keywords', () async {
    expect(await dispatcher.classify('Summarize this article'), Intent.summarize);
    expect(await dispatcher.classify('Give me the key points'), Intent.summarize);
    expect(await dispatcher.classify('TLDR of this'), Intent.summarize);
  });

  // ── Search ──
  test('search keywords', () async {
    expect(await dispatcher.classify('What was the plumber number?'), Intent.search);
    expect(await dispatcher.classify('Find my notes about cooking'), Intent.search);
    expect(await dispatcher.classify('Search for dentist'), Intent.search);
    expect(await dispatcher.classify('Where did I put the recipe?'), Intent.search);
    expect(await dispatcher.classify('Look up that phone number'), Intent.search);
  });

  // ── Note ──
  test('note keywords', () async {
    expect(await dispatcher.classify('Note that the wifi password is blue'), Intent.note);
    expect(await dispatcher.classify('Remember that Sarah likes tea'), Intent.note);
    expect(await dispatcher.classify('Jot down eggs milk bread'), Intent.note);
    expect(await dispatcher.classify('Save this: meeting room 4B'), Intent.note);
  });

  // ── Habit (recurring) ──
  test('habit keywords', () async {
    expect(await dispatcher.classify('Remind me to drink water every 2 hours'), Intent.habit);
    expect(await dispatcher.classify('I want to meditate every morning'), Intent.habit);
    expect(await dispatcher.classify('Track my daily pushups'), Intent.habit);
    expect(await dispatcher.classify('How is my meditation streak?'), Intent.habit);
    expect(await dispatcher.classify('Start a habit of reading daily'), Intent.habit);
  });

  // ── Draft ──
  test('draft keywords', () async {
    expect(await dispatcher.classify('Write a polite email declining'), Intent.draft);
    expect(await dispatcher.classify('Draft a message to my boss'), Intent.draft);
    expect(await dispatcher.classify('Compose a birthday greeting'), Intent.draft);
    expect(await dispatcher.classify('Rewrite this more professionally'), Intent.draft);
    expect(await dispatcher.classify('Make this sound more casual'), Intent.draft);
    expect(await dispatcher.classify('Rephrase this sentence'), Intent.draft);
  });

  // ── Task (one-time) ──
  test('task keywords', () async {
    expect(await dispatcher.classify('Remind me to buy milk tomorrow'), Intent.task);
    expect(await dispatcher.classify('Add a task to call the dentist'), Intent.task);
    expect(await dispatcher.classify('I need to finish the report'), Intent.task);
    expect(await dispatcher.classify('Todo: pick up dry cleaning'), Intent.task);
  });

  // ── Event ──
  test('event keywords', () async {
    expect(await dispatcher.classify('Schedule a meeting at 3pm'), Intent.event);
    expect(await dispatcher.classify('I have a dinner on Friday'), Intent.event);
    expect(await dispatcher.classify('Appointment with Dr Lee at 10am'), Intent.event);
  });

  // ── Disambiguation ──
  test('remind with every = habit, not task', () async {
    expect(await dispatcher.classify('Remind me to take vitamins every morning'), Intent.habit);
  });

  test('remind without every = task', () async {
    expect(await dispatcher.classify('Remind me to take vitamins tomorrow'), Intent.task);
  });

  test('write a email = draft, not task', () async {
    expect(await dispatcher.classify('Write a thank you email'), Intent.draft);
  });

  test('write down = note, not draft', () async {
    expect(await dispatcher.classify('Write down that the code is 4521'), Intent.note);
  });

  // ── Chat fallback ──
  test('general chat fallback', () async {
    expect(await dispatcher.classify('Hello how are you?'), Intent.chat);
    expect(await dispatcher.classify('Tell me a joke'), Intent.chat);
    expect(await dispatcher.classify('What is the meaning of life?'), Intent.chat);
  });
}
