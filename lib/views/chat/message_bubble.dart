import 'package:flutter/material.dart' hide Intent;
import '../../core/intent.dart';
import '../../store/database.dart';
import 'specialist_badge.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  bool get _isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _isUser
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isUser && message.specialistBadge != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: SpecialistBadge(
                  intent: Intent.fromString(message.specialistBadge!),
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: _isUser
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
