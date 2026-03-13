import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/store/database.dart';
import 'package:tinyclaw/store/habit_dao.dart';

void main() {
  late AppDatabase db;
  late HabitDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = HabitDao(db);
  });

  tearDown(() => db.close());

  test('insertHabit and retrieve', () async {
    await dao.insertHabit('Drink water', 'every_2_hours');
    final habits = await dao.allHabits();
    expect(habits.length, 1);
    expect(habits.first.title, 'Drink water');
    expect(habits.first.frequency, 'every_2_hours');
    expect(habits.first.currentStreak, 0);
    expect(habits.first.isActive, true);
  });

  test('watchActiveHabits streams only active habits', () async {
    await dao.insertHabit('Active', 'daily');
    await dao.insertHabit('Inactive', 'daily');
    final habits = await dao.allHabits();
    await dao.deactivateHabit(habits.last.id);

    final active = await dao.watchActiveHabits().first;
    expect(active.length, 1);
    expect(active.first.title, 'Active');
  });

  test('completeHabit logs entry and updates streak', () async {
    await dao.insertHabit('Pushups', 'daily');
    final habits = await dao.allHabits();
    final id = habits.first.id;

    await dao.completeHabit(id);
    final updated = await dao.getHabit(id);
    expect(updated.currentStreak, 1);
    expect(updated.longestStreak, 1);
    expect(updated.lastCompletedAt, isNotNull);
  });

  test('completeHabit does not double-count same day', () async {
    await dao.insertHabit('Pushups', 'daily');
    final habits = await dao.allHabits();
    final id = habits.first.id;

    await dao.completeHabit(id);
    await dao.completeHabit(id); // same day
    final updated = await dao.getHabit(id);
    expect(updated.currentStreak, 1); // still 1
  });

  test('deleteHabit removes habit and logs', () async {
    await dao.insertHabit('Test', 'daily');
    final habits = await dao.allHabits();
    await dao.completeHabit(habits.first.id);
    await dao.deleteHabit(habits.first.id);
    expect(await dao.allHabits(), isEmpty);
  });
}
