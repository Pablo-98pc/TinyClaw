import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/store/database.dart';
import 'package:tinyclaw/views/tasks/task_row.dart';

void main() {
  group('TaskRow', () {
    testWidgets('renders title and unchecked checkbox for incomplete task',
        (tester) async {
      final task = TaskItem(
        id: 1,
        title: 'Buy milk',
        dueDate: null,
        isCompleted: false,
        notes: null,
        createdAt: DateTime(2024, 1, 1),
      );

      bool toggled = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskRow(task: task, onToggle: () => toggled = true),
        ),
      ));

      expect(find.text('Buy milk'), findsOneWidget);
      expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
      expect(find.byIcon(Icons.check_box), findsNothing);
      expect(toggled, false);
    });

    testWidgets('renders checked checkbox for completed task', (tester) async {
      final task = TaskItem(
        id: 2,
        title: 'Walk dog',
        dueDate: null,
        isCompleted: true,
        notes: null,
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskRow(task: task, onToggle: () {}),
        ),
      ));

      expect(find.text('Walk dog'), findsOneWidget);
      expect(find.byIcon(Icons.check_box), findsOneWidget);
      expect(find.byIcon(Icons.check_box_outline_blank), findsNothing);
    });

    testWidgets('tapping checkbox calls onToggle', (tester) async {
      final task = TaskItem(
        id: 3,
        title: 'Read book',
        dueDate: null,
        isCompleted: false,
        notes: null,
        createdAt: DateTime(2024, 1, 1),
      );

      bool toggled = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskRow(task: task, onToggle: () => toggled = true),
        ),
      ));

      await tester.tap(find.byIcon(Icons.check_box_outline_blank));
      expect(toggled, true);
    });

    testWidgets('renders due date when present', (tester) async {
      final task = TaskItem(
        id: 4,
        title: 'Submit report',
        dueDate: DateTime(2025, 3, 15),
        isCompleted: false,
        notes: null,
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskRow(task: task, onToggle: () {}),
        ),
      ));

      expect(find.text('Submit report'), findsOneWidget);
      // TaskRow formats as M/D/YYYY
      expect(find.text('3/15/2025'), findsOneWidget);
    });

    testWidgets('does not render due date when null', (tester) async {
      final task = TaskItem(
        id: 5,
        title: 'No date task',
        dueDate: null,
        isCompleted: false,
        notes: null,
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskRow(task: task, onToggle: () {}),
        ),
      ));

      expect(find.text('No date task'), findsOneWidget);
      // No date text should appear besides the title
      expect(find.textContaining('/'), findsNothing);
    });
  });
}
