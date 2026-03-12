import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/store/database.dart';

void main() {
  late AppDatabase db;
  late EventDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.eventDao;
  });

  tearDown(() => db.close());

  group('EventDao', () {
    test('insert and retrieve event', () async {
      await dao.insertEvent(EventItemsCompanion.insert(
        title: 'Team meeting',
        date: DateTime(2026, 3, 15),
        startTime: const Value('09:00'),
        endTime: const Value('10:00'),
      ));
      final events = await dao.allEvents();
      expect(events.length, 1);
      expect(events.first.title, 'Team meeting');
      expect(events.first.startTime, '09:00');
    });

    test('events in range', () async {
      await dao.insertEvent(EventItemsCompanion.insert(
        title: 'Past', date: DateTime(2026, 3, 1),
      ));
      await dao.insertEvent(EventItemsCompanion.insert(
        title: 'In range', date: DateTime(2026, 3, 15),
      ));
      await dao.insertEvent(EventItemsCompanion.insert(
        title: 'Future', date: DateTime(2026, 4, 1),
      ));

      final ranged = await dao.eventsInRange(DateTime(2026, 3, 10), DateTime(2026, 3, 20));
      expect(ranged.length, 1);
      expect(ranged.first.title, 'In range');
    });

    test('delete event', () async {
      final id = await dao.insertEvent(EventItemsCompanion.insert(
        title: 'Delete me', date: DateTime(2026, 3, 15),
      ));
      expect(await dao.allEvents(), hasLength(1));
      await dao.deleteEvent(id);
      expect(await dao.allEvents(), isEmpty);
    });
  });
}
