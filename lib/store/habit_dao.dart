import 'package:drift/drift.dart';
import 'database.dart';

/// DAO for habit CRUD, completion logging, and streak calculation.
class HabitDao {
  final AppDatabase _db;
  HabitDao(this._db);

  /// Insert a new habit.
  Future<int> insertHabit(String title, String frequency, {String? targetTime}) {
    return _db.into(_db.habitItems).insert(HabitItemsCompanion.insert(
      title: title,
      frequency: frequency,
      targetTime: Value(targetTime),
    ));
  }

  /// Get all habits.
  Future<List<HabitItem>> allHabits() =>
    (_db.select(_db.habitItems)..orderBy([(h) => OrderingTerm.desc(h.createdAt)])).get();

  /// Get a single habit by ID.
  Future<HabitItem> getHabit(int id) =>
    (_db.select(_db.habitItems)..where((h) => h.id.equals(id))).getSingle();

  /// Stream active habits.
  Stream<List<HabitItem>> watchActiveHabits() =>
    (_db.select(_db.habitItems)
      ..where((h) => h.isActive.equals(true))
      ..orderBy([(h) => OrderingTerm.desc(h.createdAt)]))
    .watch();

  /// Mark a habit as completed for today.
  /// Returns false if already completed today (daily frequency).
  Future<bool> completeHabit(int id) async {
    final habit = await getHabit(id);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if already completed today
    if (habit.lastCompletedAt != null) {
      final lastDate = DateTime(
        habit.lastCompletedAt!.year,
        habit.lastCompletedAt!.month,
        habit.lastCompletedAt!.day,
      );
      if (lastDate == today) return false; // already done today
    }

    // Log completion
    await _db.into(_db.habitLogItems).insert(
      HabitLogItemsCompanion.insert(habitId: id),
    );

    // Calculate new streak
    final newStreak = habit.currentStreak + 1;
    final newLongest = newStreak > habit.longestStreak ? newStreak : habit.longestStreak;

    await (_db.update(_db.habitItems)..where((h) => h.id.equals(id))).write(
      HabitItemsCompanion(
        currentStreak: Value(newStreak),
        longestStreak: Value(newLongest),
        lastCompletedAt: Value(now),
      ),
    );

    return true;
  }

  /// Deactivate a habit (soft delete).
  Future<void> deactivateHabit(int id) =>
    (_db.update(_db.habitItems)..where((h) => h.id.equals(id)))
      .write(const HabitItemsCompanion(isActive: Value(false)));

  /// Hard delete a habit and its logs.
  Future<void> deleteHabit(int id) async {
    await (_db.delete(_db.habitLogItems)..where((l) => l.habitId.equals(id))).go();
    await (_db.delete(_db.habitItems)..where((h) => h.id.equals(id))).go();
  }
}
