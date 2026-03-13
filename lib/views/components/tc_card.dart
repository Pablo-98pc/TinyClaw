import 'package:flutter/material.dart';
import '../theme/theme.dart';

class TcCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry? padding;

  const TcCard({
    super.key,
    required this.child,
    this.accentColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TcColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: BorderRadius.circular(TcRadius.md),
        border: Border.all(color: colors.divider, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TcRadius.md),
        child: Row(
          children: [
            if (accentColor != null)
              Container(
                width: 3,
                constraints: const BoxConstraints(minHeight: 40),
                color: accentColor,
              ),
            Expanded(
              child: Padding(
                padding: padding ??
                    const EdgeInsets.all(TcSpacing.lg),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
