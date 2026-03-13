import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/views/tasks/habit_row.dart';
import 'package:tinyclaw/views/theme/theme.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: TcTheme.dark(),
    home: Scaffold(body: child),
  );

  testWidgets('displays habit title and streak', (tester) async {
    await tester.pumpWidget(wrap(HabitRow(
      title: 'Meditate',
      frequency: 'daily',
      currentStreak: 7,
      isCompletedToday: false,
      onComplete: () {},
    )));
    expect(find.text('Meditate'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('daily'), findsOneWidget);
  });

  testWidgets('shows completed state', (tester) async {
    await tester.pumpWidget(wrap(HabitRow(
      title: 'Pushups',
      frequency: 'daily',
      currentStreak: 3,
      isCompletedToday: true,
      onComplete: () {},
    )));
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('onComplete callback fires on tap', (tester) async {
    var completed = false;
    await tester.pumpWidget(wrap(HabitRow(
      title: 'Pushups',
      frequency: 'daily',
      currentStreak: 0,
      isCompletedToday: false,
      onComplete: () => completed = true,
    )));
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));
    expect(completed, true);
  });
}
