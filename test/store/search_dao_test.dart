import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:tinyclaw/store/database.dart';
import 'package:tinyclaw/store/search_dao.dart';

void main() {
  late AppDatabase db;
  late SearchDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = SearchDao(db);
  });

  tearDown(() => db.close());

  test('search finds notes by content', () async {
    await db.into(db.noteItems).insert(NoteItemsCompanion.insert(
      content: 'The plumber number is 555-1234',
      title: Value('Plumber'),
    ));
    final results = await dao.search('plumber');
    expect(results.notes.length, 1);
    expect(results.notes.first.content, contains('555-1234'));
  });

  test('search finds tasks by title', () async {
    await db.into(db.taskItems).insert(TaskItemsCompanion.insert(
      title: 'Buy groceries for dinner',
    ));
    final results = await dao.search('groceries');
    expect(results.tasks.length, 1);
  });

  test('search finds events by title', () async {
    await db.into(db.eventItems).insert(EventItemsCompanion.insert(
      title: 'Dentist appointment',
      date: DateTime(2026, 3, 15),
    ));
    final results = await dao.search('dentist');
    expect(results.events.length, 1);
  });

  test('search returns empty for no matches', () async {
    final results = await dao.search('nonexistent');
    expect(results.isEmpty, true);
  });

  test('search returns max 3 per entity type', () async {
    for (var i = 0; i < 5; i++) {
      await db.into(db.noteItems).insert(NoteItemsCompanion.insert(
        content: 'Apple note number $i',
        title: Value('Apple $i'),
      ));
    }
    final results = await dao.search('apple');
    expect(results.notes.length, lessThanOrEqualTo(3));
  });
}
