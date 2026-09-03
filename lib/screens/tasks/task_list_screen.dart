import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/task_widgets.dart';
import 'task_details_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  TaskStatus? _filter; // null = all

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasksFor(_filter);
    final counts = provider.counts;

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 14, 18, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('My tasks', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                _FilterChip(label: 'All (${counts.total})', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'New (${counts.newCount})',
                  selected: _filter == TaskStatus.newTask,
                  onTap: () => setState(() => _filter = TaskStatus.newTask),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Completed (${counts.completedCount})',
                  selected: _filter == TaskStatus.completed,
                  onTap: () => setState(() => _filter = TaskStatus.completed),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<TaskProvider>().loadAll(),
              child: provider.isLoading && tasks.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.moss))
                  : tasks.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 80),
                            EmptyState(
                              icon: Icons.task_alt_outlined,
                              title: 'Nothing here yet',
                              message: 'Tasks in this status will show up here once you add or update them.',
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                          itemCount: tasks.length,
                          itemBuilder: (context, i) {
                            final task = tasks[i];
                            return TaskCard(
                              task: task,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task)),
                              ),
                              onToggleDone: (done) => context.read<TaskProvider>().updateStatus(
                                    taskId: task.id,
                                    status: done ? TaskStatus.completed : TaskStatus.newTask,
                                  ),
                              onDelete: () => _confirmDelete(context, task),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 18),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: AppColors.brickTint, borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.delete_outline, color: AppColors.brick, size: 26),
            ),
            const SizedBox(height: 16),
            const Text('Delete this task?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('"${task.title}" will be removed permanently.',
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: AppColors.inkFaint, height: 1.5)),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(child: AppButton(label: 'Cancel', outlined: true, onPressed: () => Navigator.pop(ctx))),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: 'Delete',
                    danger: true,
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<TaskProvider>().deleteTask(task.id);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.moss : AppColors.chipNeutral,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.inkSoft)),
      ),
    );
  }
}
