import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/database_provider.dart';
import '../../store/database.dart';
import 'task_row.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskDao = ref.watch(taskDaoProvider);

    return Scaffold(
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
      body: StreamBuilder<List<TaskItem>>(
        stream: taskDao.watchAllTasks(),
        builder: (context, snapshot) {
          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Create tasks by chatting with TinyClaw', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Dismissible(
                  key: ValueKey(task.id),
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
                  onDismissed: (_) => taskDao.deleteTask(task.id),
                  child: TaskRow(
                    task: task,
                    onToggle: () => taskDao.toggleComplete(task.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
