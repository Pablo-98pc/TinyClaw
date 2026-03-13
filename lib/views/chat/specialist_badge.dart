import 'package:flutter/material.dart' hide Intent;
import '../../core/intent.dart';

class SpecialistBadge extends StatelessWidget {
  final Intent? intent;

  const SpecialistBadge({super.key, this.intent});

  Color _badgeColor() {
    return switch (intent) {
      Intent.chat => Colors.grey,
      Intent.summarize => Colors.orange,
      Intent.task => Colors.blue,
      Intent.event => Colors.purple,
      Intent.note => Colors.amber,
      Intent.habit => Colors.green,
      Intent.draft => Colors.indigo,
      Intent.search => Colors.pink,
      null => Colors.grey,
    };
  }

  String _label() {
    return intent?.name ?? 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _badgeColor().withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _badgeColor(),
        ),
      ),
    );
  }
}
