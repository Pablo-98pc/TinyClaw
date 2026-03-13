import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../components/tc_card.dart';

class BriefingCard extends StatefulWidget {
  final String text;
  final VoidCallback? onDismiss;

  const BriefingCard({super.key, required this.text, this.onDismiss});

  @override
  State<BriefingCard> createState() => _BriefingCardState();
}

class _BriefingCardState extends State<BriefingCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final colors = TcColors.of(context);
    final hour = DateTime.now().hour;
    final icon = hour < 17 ? Icons.wb_sunny_outlined : Icons.nightlight_outlined;

    return TcCard(
      accentColor: colors.warning,
      padding: const EdgeInsets.all(TcSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colors.warning),
              const SizedBox(width: TcSpacing.sm),
              Text(
                'Daily Briefing',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.warning,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: TcSpacing.sm),
            Text(
              widget.text,
              style: TextStyle(fontSize: 13, color: colors.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}
