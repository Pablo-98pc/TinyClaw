import 'package:flutter/material.dart';
import '../../store/database.dart';

class EventRow extends StatelessWidget {
  final EventItem event;

  const EventRow({super.key, required this.event});

  Color get _accentColor => event.recurrence != null ? Colors.purple : Colors.blue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _formatDate(event.date),
                      style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                    ),
                    if (event.startTime != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        event.endTime != null
                            ? '${event.startTime} - ${event.endTime}'
                            : event.startTime!,
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
                if (event.recurrence != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Repeats ${event.recurrence}',
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
