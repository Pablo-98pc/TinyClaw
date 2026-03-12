import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinyclaw/store/database.dart';
import 'package:tinyclaw/views/chat/message_bubble.dart';
import 'package:tinyclaw/views/chat/specialist_badge.dart';

void main() {
  group('MessageBubble', () {
    testWidgets('user message aligns to the right', (tester) async {
      final message = Message(
        id: 1,
        role: 'user',
        content: 'Hello there',
        specialistBadge: null,
        isVoiceInput: false,
        timestamp: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageBubble(message: message),
        ),
      ));

      expect(find.text('Hello there'), findsOneWidget);

      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('assistant message aligns to the left', (tester) async {
      final message = Message(
        id: 2,
        role: 'assistant',
        content: 'Hi! How can I help?',
        specialistBadge: null,
        isVoiceInput: false,
        timestamp: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageBubble(message: message),
        ),
      ));

      expect(find.text('Hi! How can I help?'), findsOneWidget);

      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('user message does not show specialist badge', (tester) async {
      final message = Message(
        id: 3,
        role: 'user',
        content: 'Add a task',
        specialistBadge: 'task',
        isVoiceInput: false,
        timestamp: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageBubble(message: message),
        ),
      ));

      expect(find.byType(SpecialistBadge), findsNothing);
    });

    testWidgets('assistant message with specialistBadge shows SpecialistBadge',
        (tester) async {
      final message = Message(
        id: 4,
        role: 'assistant',
        content: 'I created a task for you.',
        specialistBadge: 'task',
        isVoiceInput: false,
        timestamp: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageBubble(message: message),
        ),
      ));

      expect(find.text('I created a task for you.'), findsOneWidget);
      expect(find.byType(SpecialistBadge), findsOneWidget);
    });

    testWidgets('assistant message without specialistBadge hides SpecialistBadge',
        (tester) async {
      final message = Message(
        id: 5,
        role: 'assistant',
        content: 'Sure, let me help.',
        specialistBadge: null,
        isVoiceInput: false,
        timestamp: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageBubble(message: message),
        ),
      ));

      expect(find.byType(SpecialistBadge), findsNothing);
    });
  });
}
