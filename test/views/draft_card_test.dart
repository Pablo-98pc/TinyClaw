import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/views/chat/draft_card.dart';
import 'package:tinyclaw/views/theme/theme.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: TcTheme.dark(),
    home: Scaffold(body: child),
  );

  testWidgets('displays draft content', (tester) async {
    await tester.pumpWidget(wrap(DraftCard(
      content: 'Dear John, thank you for the invitation.',
      onCopy: () {},
    )));
    expect(find.text('Dear John, thank you for the invitation.'), findsOneWidget);
  });

  testWidgets('shows Copy and Tweak buttons', (tester) async {
    await tester.pumpWidget(wrap(DraftCard(
      content: 'Draft text',
      onCopy: () {},
    )));
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Tweak'), findsOneWidget);
  });

  testWidgets('Copy button calls onCopy', (tester) async {
    var copied = false;
    await tester.pumpWidget(wrap(DraftCard(
      content: 'Draft text',
      onCopy: () => copied = true,
    )));
    await tester.tap(find.text('Copy'));
    expect(copied, true);
  });
}
