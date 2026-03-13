import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/store/database.dart';
import 'package:tinyclaw/store/habit_dao.dart';
import 'package:tinyclaw/services/briefing_service.dart';

void main() {
  late AppDatabase db;
  late BriefingService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = BriefingService(
      taskDao: db.taskDao,
      eventDao: db.eventDao,
      habitDao: db.habitDao,
    );
  });

  tearDown(() => db.close());

  test('empty briefing when no data', () async {
    final briefing = await service.generate();
    expect(briefing, contains('All clear'));
  });

  test('includes task count when tasks due today', () async {
    await db.into(db.taskItems).insert(TaskItemsCompanion.insert(
      title: 'Buy milk',
      dueDate: Value(DateTime.now()),
    ));
    final briefing = await service.generate();
    expect(briefing, contains('1'));
    expect(briefing, contains('task'));
  });

  test('includes event when event is today', () async {
    final now = DateTime.now();
    await db.into(db.eventItems).insert(EventItemsCompanion.insert(
      title: 'Team standup',
      date: DateTime(now.year, now.month, now.day, 14, 0),
      startTime: const Value('14:00'),
    ));
    final briefing = await service.generate();
    expect(briefing, contains('Team standup'));
  });

  test('includes streak info for active habits', () async {
    final habitDao = HabitDao(db);
    await habitDao.insertHabit('Meditate', 'daily');
    final habits = await habitDao.allHabits();
    await habitDao.completeHabit(habits.first.id);

    final briefing = await service.generate();
    expect(briefing, contains('streak'));
  });
}
