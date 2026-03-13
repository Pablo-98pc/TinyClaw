import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../store/database.dart';
import '../store/habit_dao.dart';
import '../store/search_dao.dart';

/// Provides the singleton AppDatabase instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Provides the TaskDao from the database.
final taskDaoProvider = Provider<TaskDao>((ref) {
  return ref.watch(databaseProvider).taskDao;
});

/// Provides the EventDao from the database.
final eventDaoProvider = Provider<EventDao>((ref) {
  return ref.watch(databaseProvider).eventDao;
});

/// Provides the MessageDao from the database.
final messageDaoProvider = Provider<MessageDao>((ref) {
  return ref.watch(databaseProvider).messageDao;
});

/// Provides the NoteDao from the database.
final noteDaoProvider = Provider<NoteDao>((ref) {
  return ref.watch(databaseProvider).noteDao;
});

/// Provides the HabitDao from the database.
final habitDaoProvider = Provider<HabitDao>((ref) {
  return ref.watch(databaseProvider).habitDao;
});

/// Provides the SearchDao from the database.
final searchDaoProvider = Provider<SearchDao>((ref) {
  return ref.watch(databaseProvider).searchDao;
});
