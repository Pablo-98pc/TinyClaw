import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/database_provider.dart';
import '../../store/database.dart';
import '../theme/theme.dart';
import 'habit_row.dart';
import 'task_row.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskDao = ref.watch(taskDaoProvider);
    final habitDao = ref.watch(habitDaoProvider);
    final colors = TcColors.of(context);

    return Scaffold(
      backgroundColor: colors.surface0,
      appBar: AppBar(
        title: const Text('Tasks'),
        centerTitle: true,
        actions: [
          StreamBuilder<List<TaskItem>>(
            stream: taskDao.watchAllTasks(),
            builder: (context, snapshot) {
              final pending = (snapshot.data ?? []).where((t) => !t.isCompleted).length;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '$pending pending',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: TcSpacing.lg, vertical: TcSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tasks section header
            Padding(
              padding: const EdgeInsets.only(bottom: TcSpacing.sm),
              child: Row(
                children: [
                  Text(
                    'Tasks',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: TcSpacing.sm),
                  Expanded(child: Divider(color: colors.divider, height: 1)),
                ],
              ),
            ),
            // Tasks list
            StreamBuilder<List<TaskItem>>(
              stream: taskDao.watchAllTasks(),
              builder: (context, snapshot) {
                final tasks = snapshot.data ?? [];

                if (tasks.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: TcSpacing.lg),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, size: 48, color: colors.textTertiary),
                          const SizedBox(height: TcSpacing.sm),
                          Text('No tasks yet', style: TextStyle(color: colors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('Create tasks by chatting with TinyClaw', style: TextStyle(fontSize: 12, color: colors.textTertiary)),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: tasks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: TcSpacing.sm),
                    child: Dismissible(
                      key: ValueKey('task-${task.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: TcSpacing.lg),
                        decoration: BoxDecoration(
                          color: colors.error,
                          borderRadius: BorderRadius.circular(TcRadius.md),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => taskDao.deleteTask(task.id),
                      child: TaskRow(
                        task: task,
                        onToggle: () => taskDao.toggleComplete(task.id),
                      ),
                    ),
                  )).toList(),
                );
              },
            ),
            // Habits section header
            Padding(
              padding: const EdgeInsets.only(top: TcSpacing.md, bottom: TcSpacing.sm),
              child: Row(
                children: [
                  Text(
                    'Habits',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: TcSpacing.sm),
                  Expanded(child: Divider(color: colors.divider, height: 1)),
                ],
              ),
            ),
            // Habits list
            StreamBuilder<List<HabitItem>>(
              stream: habitDao.watchActiveHabits(),
              builder: (context, snapshot) {
                final habits = snapshot.data ?? [];

                if (habits.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: TcSpacing.lg),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department_outlined, size: 48, color: colors.textTertiary),
                          const SizedBox(height: TcSpacing.sm),
                          Text('No habits yet', style: TextStyle(color: colors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('Create habits by chatting with TinyClaw', style: TextStyle(fontSize: 12, color: colors.textTertiary)),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: habits.map((habit) {
                    final isCompletedToday = _isCompletedToday(habit.lastCompletedAt);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: TcSpacing.sm),
                      child: HabitRow(
                        title: habit.title,
                        frequency: habit.frequency,
                        currentStreak: habit.currentStreak,
                        isCompletedToday: isCompletedToday,
                        onComplete: () => habitDao.completeHabit(habit.id),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: TcSpacing.lg),
          ],
        ),
      ),
    );
  }

  bool _isCompletedToday(DateTime? lastCompletedAt) {
    if (lastCompletedAt == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(lastCompletedAt.year, lastCompletedAt.month, lastCompletedAt.day);
    return lastDate == today;
  }
}
