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

@DriftDatabase(tables: [TaskItems, EventItems, Messages], daos: [TaskDao, EventDao, MessageDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor for testing with in-memory database.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tinyclaw.db'));
    return NativeDatabase.createInBackground(file);
  });
}
