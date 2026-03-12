import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/store/database.dart';

void main() {
  late AppDatabase db;
  late TaskDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.taskDao;
  });

  tearDown(() => db.close());

  group('TaskDao', () {
    test('insert and retrieve task', () async {
      await dao.insertTask(TaskItemsCompanion.insert(title: 'Buy groceries'));
      final tasks = await dao.allTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Buy groceries');
      expect(tasks.first.isCompleted, false);
    });

    test('toggle complete', () async {
      final id = await dao.insertTask(TaskItemsCompanion.insert(title: 'Test task'));
      await dao.toggleComplete(id);
      final tasks = await dao.allTasks();
      expect(tasks.first.isCompleted, true);

      await dao.toggleComplete(id);
      final tasks2 = await dao.allTasks();
      expect(tasks2.first.isCompleted, false);
    });

    test('delete task', () async {
      final id = await dao.insertTask(TaskItemsCompanion.insert(title: 'Delete me'));
      expect(await dao.allTasks(), hasLength(1));
      await dao.deleteTask(id);
      expect(await dao.allTasks(), isEmpty);
    });

    test('watch emits updates', () async {
      final stream = dao.watchAllTasks();
      // First emission is empty list
      expectLater(
        stream,
        emitsInOrder([
          hasLength(0),
          hasLength(1),
        ]),
      );
      await dao.insertTask(TaskItemsCompanion.insert(title: 'Watched task'));
    });
  });
}
