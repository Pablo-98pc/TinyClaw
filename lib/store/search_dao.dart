import 'package:drift/drift.dart';
import 'database.dart';

/// Cross-entity search results grouped by type.
class SearchResults {
  final List<NoteItem> notes;
  final List<TaskItem> tasks;
  final List<EventItem> events;
  final List<HabitItem> habits;

  const SearchResults({
    this.notes = const [],
    this.tasks = const [],
    this.events = const [],
    this.habits = const [],
  });

  bool get isEmpty => notes.isEmpty && tasks.isEmpty && events.isEmpty && habits.isEmpty;
}

/// Searches across notes, tasks, events, and habits using SQL LIKE queries.
///
/// Phase 1 uses simple LIKE matching. Phase 2 will upgrade to FTS5.
class SearchDao {
  final AppDatabase _db;
  SearchDao(this._db);

  /// Search across all entity types. Returns max 3 results per type.
  Future<SearchResults> search(String query) async {
    if (query.trim().isEmpty) return const SearchResults();

    final pattern = '%${query.trim()}%';

    final notes = await (_db.select(_db.noteItems)
      ..where((n) => n.content.like(pattern) | n.title.like(pattern))
      ..orderBy([(n) => OrderingTerm.desc(n.updatedAt)])
      ..limit(3))
    .get();

    final tasks = await (_db.select(_db.taskItems)
      ..where((t) => t.title.like(pattern))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(3))
    .get();

    final events = await (_db.select(_db.eventItems)
      ..where((e) => e.title.like(pattern))
      ..orderBy([(e) => OrderingTerm.desc(e.date)])
      ..limit(3))
    .get();

    final habits = await (_db.select(_db.habitItems)
      ..where((h) => h.title.like(pattern) & h.isActive.equals(true))
      ..orderBy([(h) => OrderingTerm.desc(h.createdAt)])
      ..limit(3))
    .get();

    return SearchResults(notes: notes, tasks: tasks, events: events, habits: habits);
  }
}
