import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/store/database.dart';
import 'package:tinyclaw/views/events/event_row.dart';

void main() {
  group('EventRow', () {
    testWidgets('renders title and formatted date', (tester) async {
      final event = EventItem(
        id: 1,
        title: 'Team Meeting',
        date: DateTime(2025, 3, 15),
        startTime: null,
        endTime: null,
        recurrence: null,
        notes: null,
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EventRow(event: event),
        ),
      ));

      expect(find.text('Team Meeting'), findsOneWidget);
      // EventRow formats as 'MMM D, YYYY'
      expect(find.text('Mar 15, 2025'), findsOneWidget);
    });

    testWidgets('renders time range when startTime and endTime are set',
        (tester) async {
      final event = EventItem(
        id: 2,
        title: 'Dentist',
        date: DateTime(2025, 6, 10),
        startTime: '9:00 AM',
        endTime: '10:00 AM',
        recurrence: null,
        notes: null,
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EventRow(event: event),
        ),
      ));

      expect(find.text('Dentist'), findsOneWidget);
      expect(find.text('9:00 AM - 10:00 AM'), findsOneWidget);
    });

    testWidgets('renders only startTime when endTime is absent', (tester) async {
      final event = EventItem(
        id: 3,
        title: 'Lunch',
        date: DateTime(2025, 7, 4),
        startTime: '12:30 PM',
        endTime: null,
        recurrence: null,
        notes: null,
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EventRow(event: event),
        ),
      ));

      expect(find.text('12:30 PM'), findsOneWidget);
      expect(find.textContaining('-'), findsNothing);
    });

    testWidgets('renders recurrence text when recurrence is set',
        (tester) async {
      final event = EventItem(
        id: 4,
        title: 'Yoga',
        date: DateTime(2025, 5, 1),
        startTime: '7:00 AM',
        endTime: '8:00 AM',
        recurrence: 'weekly',
        notes: null,
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EventRow(event: event),
        ),
      ));

      expect(find.text('Yoga'), findsOneWidget);
      expect(find.text('Repeats weekly'), findsOneWidget);
    });

    testWidgets('does not render recurrence text when recurrence is null',
        (tester) async {
      final event = EventItem(
        id: 5,
        title: 'One-time event',
        date: DateTime(2025, 8, 20),
        startTime: null,
        endTime: null,
        recurrence: null,
        notes: null,
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EventRow(event: event),
        ),
      ));

      expect(find.textContaining('Repeats'), findsNothing);
    });
  });
}
