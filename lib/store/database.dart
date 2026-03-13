import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ─── Tables ───

class TaskItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class EventItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get startTime => text().nullable()();
  TextColumn get endTime => text().nullable()();
  TextColumn get recurrence => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class NoteItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get content => text()();
  TextColumn get tags => text().nullable()();
  DateTimeColumn get extractedDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class HabitItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get frequency => text()(); // daily, weekdays, every_2_hours, weekly
  TextColumn get targetTime => text().nullable()();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastCompletedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class HabitLogItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(HabitItems, #id)();
  DateTimeColumn get completedAt => dateTime().withDefault(currentDateAndTime)();
}

class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get role => text()(); // 'user' or 'assistant'
  TextColumn get content => text()();
  TextColumn get specialistBadge => text().nullable()();
  BoolColumn get isVoiceInput => boolean().withDefault(const Constant(false))();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

// ─── DAOs ───

@DriftAccessor(tables: [TaskItems])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Future<List<TaskItem>> allTasks() => (select(taskItems)
    ..orderBy([
      (t) => OrderingTerm(expression: t.isCompleted),
      (t) => OrderingTerm(expression: t.dueDate),
    ]))
    .get();

  Stream<List<TaskItem>> watchAllTasks() => (select(taskItems)
    ..orderBy([
      (t) => OrderingTerm(expression: t.isCompleted),
      (t) => OrderingTerm(expression: t.dueDate),
    ]))
    .watch();

  Future<int> insertTask(TaskItemsCompanion entry) => into(taskItems).insert(entry);

  Future<bool> toggleComplete(int id) async {
    final task = await (select(taskItems)..where((t) => t.id.equals(id))).getSingle();
    return (update(taskItems)..where((t) => t.id.equals(id)))
      .write(TaskItemsCompanion(isCompleted: Value(!task.isCompleted)))
      .then((rows) => rows > 0);
  }

  Future<int> deleteTask(int id) => (delete(taskItems)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [EventItems])
class EventDao extends DatabaseAccessor<AppDatabase> with _$EventDaoMixin {
  EventDao(super.db);

  Future<List<EventItem>> allEvents() => (select(eventItems)
    ..orderBy([(e) => OrderingTerm(expression: e.date)]))
    .get();

  Stream<List<EventItem>> watchAllEvents() => (select(eventItems)
    ..orderBy([(e) => OrderingTerm(expression: e.date)]))
    .watch();

  Future<List<EventItem>> eventsInRange(DateTime start, DateTime end) =>
    (select(eventItems)..where((e) => e.date.isBiggerOrEqualValue(start) & e.date.isSmallerThanValue(end)))
    .get();

  Future<int> insertEvent(EventItemsCompanion entry) => into(eventItems).insert(entry);

  Future<int> deleteEvent(int id) => (delete(eventItems)..where((e) => e.id.equals(id))).go();
}

@DriftAccessor(tables: [NoteItems])
class NoteDao extends DatabaseAccessor<AppDatabase> with _$NoteDaoMixin {
  NoteDao(super.db);

  Stream<List<NoteItem>> watchAllNotes() => (select(noteItems)
    ..orderBy([(n) => OrderingTerm.desc(n.updatedAt)]))
    .watch();

  Stream<NoteItem> watchNoteById(int id) =>
    (select(noteItems)..where((n) => n.id.equals(id))).watchSingle();

  Future<int> insertNote(NoteItemsCompanion entry) =>
    into(noteItems).insert(entry);

  Future<bool> updateNote(NoteItem note) =>
    (update(noteItems)..where((n) => n.id.equals(note.id)))
      .write(NoteItemsCompanion(
        content: Value(note.content),
        tags: Value(note.tags),
        extractedDate: Value(note.extractedDate),
        updatedAt: Value(DateTime.now()),
      ))
      .then((rows) => rows > 0);

  Future<int> deleteNote(int id) =>
    (delete(noteItems)..where((n) => n.id.equals(id))).go();
}

@DriftAccessor(tables: [Messages])
class MessageDao extends DatabaseAccessor<AppDatabase> with _$MessageDaoMixin {
  MessageDao(super.db);

  Future<List<Message>> allMessages() => (select(messages)
    ..orderBy([(m) => OrderingTerm(expression: m.timestamp)]))
    .get();

  Stream<List<Message>> watchAllMessages() => (select(messages)
    ..orderBy([(m) => OrderingTerm(expression: m.timestamp)]))
    .watch();

  Future<int> insertMessage(MessagesCompanion entry) => into(messages).insert(entry);

  Future<int> deleteMessage(int id) => (delete(messages)..where((m) => m.id.equals(id))).go();

  Future<void> clearAll() => delete(messages).go();
}

// ─── Database ───

@DriftDatabase(
  tables: [TaskItems, EventItems, NoteItems, Messages, HabitItems, HabitLogItems],
  daos: [TaskDao, EventDao, NoteDao, MessageDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor for testing with in-memory database.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 3) {
        await m.addColumn(noteItems, noteItems.title);
        await m.createTable(habitItems);
        await m.createTable(habitLogItems);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tinyclaw.db'));
    return NativeDatabase.createInBackground(file);
  });
}
