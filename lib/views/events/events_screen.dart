import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/database_provider.dart';
import '../../store/database.dart';
import 'event_row.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventDao = ref.watch(eventDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<EventItem>>(
        stream: eventDao.watchAllEvents(),
        builder: (context, snapshot) {
          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Create events by chatting with TinyClaw', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // Group events into Today, This Week, Upcoming
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final tomorrow = today.add(const Duration(days: 1));

          // Calculate start of week (Monday)
          final weekday = today.weekday; // 1=Mon, 7=Sun
          final startOfWeek = today.subtract(Duration(days: weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 7));

          final todayEvents = events.where((e) =>
            e.date.isAfter(today.subtract(const Duration(seconds: 1))) &&
            e.date.isBefore(tomorrow)).toList();
          final thisWeekEvents = events.where((e) =>
            !todayEvents.contains(e) &&
            e.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
            e.date.isBefore(endOfWeek)).toList();
          final upcomingEvents = events.where((e) =>
            !todayEvents.contains(e) &&
            !thisWeekEvents.contains(e) &&
            e.date.isAfter(endOfWeek.subtract(const Duration(seconds: 1)))).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              if (todayEvents.isNotEmpty) ...[
                _sectionHeader(context, 'Today'),
                ...todayEvents.map((e) => _eventTile(e, eventDao)),
              ],
              if (thisWeekEvents.isNotEmpty) ...[
                _sectionHeader(context, 'This Week'),
                ...thisWeekEvents.map((e) => _eventTile(e, eventDao)),
              ],
              if (upcomingEvents.isNotEmpty) ...[
                _sectionHeader(context, 'Upcoming'),
                ...upcomingEvents.map((e) => _eventTile(e, eventDao)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _eventTile(EventItem event, EventDao eventDao) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(event.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) => eventDao.deleteEvent(event.id),
        child: EventRow(event: event),
      ),
    );
  }
}
