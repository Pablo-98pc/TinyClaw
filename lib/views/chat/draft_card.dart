import 'package:flutter/material.dart' hide Intent;
import '../../core/intent.dart';
import '../theme/theme.dart';
import '../components/tc_card.dart';

class DraftCard extends StatelessWidget {
  final String content;
  final VoidCallback onCopy;
  final ValueChanged<String>? onTweak;
  final VoidCallback? onEnhance;
  final bool showEnhance;

  const DraftCard({
    super.key,
    required this.content,
    required this.onCopy,
    this.onTweak,
    this.onEnhance,
    this.showEnhance = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TcColors.of(context);

    return TcCard(
      accentColor: colors.intentColor(Intent.draft),
      padding: const EdgeInsets.all(TcSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Draft',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: TcSpacing.sm),
          Text(
            content,
            style: TextStyle(fontSize: 14, color: colors.textPrimary, height: 1.5),
          ),
          const SizedBox(height: TcSpacing.md),
          Row(
            children: [
              _ActionChip(label: 'Copy', icon: Icons.copy, onTap: onCopy),
              const SizedBox(width: TcSpacing.sm),
              _ActionChip(
                label: 'Tweak',
                icon: Icons.edit,
                onTap: onTweak != null ? () => _showTweakDialog(context) : null,
              ),
              if (showEnhance) ...[
                const SizedBox(width: TcSpacing.sm),
                _ActionChip(label: 'Enhance', icon: Icons.auto_awesome, onTap: onEnhance),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showTweakDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tweak draft'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g., "make it shorter"'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onTweak?.call(controller.text);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionChip({required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = TcColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surface2,
          borderRadius: BorderRadius.circular(TcRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: colors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
