import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/views/chat/briefing_card.dart';
import 'package:tinyclaw/views/theme/theme.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: TcTheme.dark(),
    home: Scaffold(body: child),
  );

  testWidgets('displays briefing text', (tester) async {
    await tester.pumpWidget(wrap(const BriefingCard(
      text: 'Good morning! You have 3 tasks due today.',
    )));
    expect(find.text('Good morning! You have 3 tasks due today.'), findsOneWidget);
  });

  testWidgets('is collapsible', (tester) async {
    await tester.pumpWidget(wrap(const BriefingCard(
      text: 'Good morning!',
    )));
    final collapseButton = find.byIcon(Icons.expand_less);
    expect(collapseButton, findsOneWidget);
    await tester.tap(collapseButton);
    await tester.pump();
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
  });
}
