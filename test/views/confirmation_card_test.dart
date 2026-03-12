import 'package:flutter/material.dart' hide Intent;
import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/core/intent.dart';
import 'package:tinyclaw/views/chat/confirmation_card.dart';

void main() {
  group('ConfirmationCard', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ConfirmationCard(
            title: 'Task Created',
            subtitle: 'Buy groceries',
            intent: Intent.task,
          ),
        ),
      ));

      expect(find.text('Task Created'), findsOneWidget);
      expect(find.text('Buy groceries'), findsOneWidget);
    });

    testWidgets('uses blue accent color for task intent', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ConfirmationCard(
            title: 'Task Created',
            subtitle: 'Walk the dog',
            intent: Intent.task,
          ),
        ),
      ));

      // Find the accent bar Container (the 3px wide left border)
      final containers = tester.widgetList<Container>(find.byType(Container));
      final accentBar = containers.firstWhere(
        (c) {
          final decoration = c.decoration;
          if (decoration is BoxDecoration) {
            return decoration.color == Colors.blue;
          }
          return false;
        },
      );

      final decoration = accentBar.decoration as BoxDecoration;
      expect(decoration.color, Colors.blue);
    });

    testWidgets('uses purple accent color for event intent', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ConfirmationCard(
            title: 'Event Created',
            subtitle: 'Team standup',
            intent: Intent.event,
          ),
        ),
      ));

      final containers = tester.widgetList<Container>(find.byType(Container));
      final accentBar = containers.firstWhere(
        (c) {
          final decoration = c.decoration;
          if (decoration is BoxDecoration) {
            return decoration.color == Colors.purple;
          }
          return false;
        },
      );

      final decoration = accentBar.decoration as BoxDecoration;
      expect(decoration.color, Colors.purple);
    });

    testWidgets('title text uses accent color for task intent', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ConfirmationCard(
            title: 'Task Added',
            subtitle: 'Buy milk',
            intent: Intent.task,
          ),
        ),
      ));

      final titleText = tester.widget<Text>(find.text('Task Added'));
      expect(titleText.style?.color, Colors.blue);
    });

    testWidgets('title text uses accent color for event intent', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ConfirmationCard(
            title: 'Event Added',
            subtitle: 'Doctor appointment',
            intent: Intent.event,
          ),
        ),
      ));

      final titleText = tester.widget<Text>(find.text('Event Added'));
      expect(titleText.style?.color, Colors.purple);
    });
  });
}
