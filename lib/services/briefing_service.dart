import '../store/database.dart';
import '../store/habit_dao.dart';

/// Assembles a daily briefing string from task, event, and habit data.
class BriefingService {
  final TaskDao taskDao;
  final EventDao eventDao;
  final HabitDao habitDao;

  BriefingService({
    required this.taskDao,
    required this.eventDao,
    required this.habitDao,
  });

  /// Generate briefing text. Pure data aggregation — no model inference.
  Future<String> generate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final greeting = _greeting(now.hour);
    final parts = <String>[];

    // Tasks due today
    final allTasks = await taskDao.allTasks();
    final dueTasks = allTasks.where((t) =>
      !t.isCompleted &&
      t.dueDate != null &&
      t.dueDate!.isBefore(tomorrow) &&
      !t.dueDate!.isBefore(today)
    ).toList();

    final overdueTasks = allTasks.where((t) =>
      !t.isCompleted &&
      t.dueDate != null &&
      t.dueDate!.isBefore(today)
    ).toList();

    if (dueTasks.isNotEmpty) {
      parts.add('You have ${dueTasks.length} task${dueTasks.length == 1 ? '' : 's'} due today.');
    }
    if (overdueTasks.isNotEmpty) {
      parts.add('${overdueTasks.length} overdue task${overdueTasks.length == 1 ? '' : 's'}.');
    }

    // Events today
    final events = await eventDao.eventsInRange(today, tomorrow);
    for (final event in events) {
      final time = event.startTime != null ? ' at ${event.startTime}' : '';
      parts.add('${event.title}$time.');
    }

    // Habit streaks
    final habits = await habitDao.watchActiveHabits().first;
    for (final habit in habits) {
      if (habit.currentStreak > 0) {
        parts.add('${habit.title} streak: ${habit.currentStreak} day${habit.currentStreak == 1 ? '' : 's'}.');
      }
    }

    if (parts.isEmpty) {
      return '$greeting All clear today — no tasks due and no events. Enjoy the free time!';
    }

    return '$greeting ${parts.join(' ')}';
  }

  String _greeting(int hour) {
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }
}
