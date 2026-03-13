import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../components/tc_card.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final String content;
  final String? tags;
  final String timeAgo;
  final VoidCallback? onTap;

  const NoteCard({
    super.key,
    required this.title,
    required this.content,
    this.tags,
    required this.timeAgo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TcColors.of(context);
    final tagList = tags?.split(',').where((t) => t.trim().isNotEmpty).toList() ?? [];

    return GestureDetector(
      onTap: onTap,
      child: TcCard(
        accentColor: colors.warning,
        padding: const EdgeInsets.all(TcSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title.isNotEmpty ? title : 'Untitled',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(timeAgo, style: TextStyle(fontSize: 11, color: colors.textTertiary)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (tagList.isNotEmpty) ...[
              const SizedBox(height: TcSpacing.sm),
              Wrap(
                spacing: 4,
                children: tagList.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.surface2,
                    borderRadius: BorderRadius.circular(TcRadius.sm),
                  ),
                  child: Text(tag.trim(), style: TextStyle(fontSize: 10, color: colors.textTertiary)),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
