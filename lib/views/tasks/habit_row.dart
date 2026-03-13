import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../components/tc_card.dart';

class HabitRow extends StatelessWidget {
  final String title;
  final String frequency;
  final int currentStreak;
  final bool isCompletedToday;
  final VoidCallback onComplete;
  final VoidCallback? onLongPress;

  const HabitRow({
    super.key,
    required this.title,
    required this.frequency,
    required this.currentStreak,
    required this.isCompletedToday,
    required this.onComplete,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TcColors.of(context);

    return GestureDetector(
      onLongPress: onLongPress,
      child: TcCard(
        accentColor: colors.success,
        padding: const EdgeInsets.symmetric(
          horizontal: TcSpacing.md,
          vertical: TcSpacing.sm,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: isCompletedToday ? null : onComplete,
              child: Icon(
                isCompletedToday ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isCompletedToday ? colors.success : colors.textTertiary,
                size: 24,
              ),
            ),
            const SizedBox(width: TcSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    frequency,
                    style: TextStyle(fontSize: 11, color: colors.textTertiary),
                  ),
                ],
              ),
            ),
            if (currentStreak > 0) ...[
              Icon(Icons.local_fire_department, size: 16, color: colors.warning),
              const SizedBox(width: 2),
              Text(
                '$currentStreak',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.warning,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
