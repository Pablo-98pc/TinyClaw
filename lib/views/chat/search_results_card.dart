import 'package:flutter/material.dart' hide Intent;
import '../../core/intent.dart';
import '../theme/theme.dart';
import '../components/tc_card.dart';

class SearchResultsCard extends StatelessWidget {
  final List<SearchResultItem> notes;
  final List<SearchResultItem> tasks;
  final List<SearchResultItem> events;
  final void Function(Intent type, int id)? onTap;

  const SearchResultsCard({
    super.key,
    this.notes = const [],
    this.tasks = const [],
    this.events = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TcColors.of(context);

    return TcCard(
      accentColor: colors.intentColor(Intent.search),
      padding: const EdgeInsets.all(TcSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Results',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.intentColor(Intent.search),
              letterSpacing: 0.5,
            ),
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: TcSpacing.sm),
            _Section(label: 'Notes', items: notes, intent: Intent.note, onTap: onTap),
          ],
          if (tasks.isNotEmpty) ...[
            const SizedBox(height: TcSpacing.sm),
            _Section(label: 'Tasks', items: tasks, intent: Intent.task, onTap: onTap),
          ],
          if (events.isNotEmpty) ...[
            const SizedBox(height: TcSpacing.sm),
            _Section(label: 'Events', items: events, intent: Intent.event, onTap: onTap),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final List<SearchResultItem> items;
  final Intent intent;
  final void Function(Intent type, int id)? onTap;

  const _Section({
    required this.label,
    required this.items,
    required this.intent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TcColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: colors.textTertiary)),
        ...items.map((item) => GestureDetector(
          onTap: () => onTap?.call(intent, item.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              item.title,
              style: TextStyle(fontSize: 13, color: colors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )),
      ],
    );
  }
}

class SearchResultItem {
  final int id;
  final String title;
  const SearchResultItem({required this.id, required this.title});
}
