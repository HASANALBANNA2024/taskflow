import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/task_widgets.dart';
import 'add_edit_task_screen.dart';

class TaskDetailsScreen extends StatelessWidget {
  final TaskModel task;
  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    // Keep showing the freshest copy of this task if the provider has it.
    final current = provider.tasks.firstWhere((t) => t.id == task.id, orElse: () => task);

    return Scaffold(
      appBar: AppBar(title: const Text('Task details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
          children: [
            StatusChip(status: current.status),
            const SizedBox(height: 12),
            Text(current.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              current.description.isNotEmpty ? current.description : 'No description added.',
              style: const TextStyle(fontSize: 13, color: AppColors.inkFaint, height: 1.6),
            ),
            const SizedBox(height: 22),
            _kvRow('Owner', current.email),
            _kvRow('Created', current.createdDate != null ? DateFormat('d MMM, yyyy').format(current.createdDate!) : '—'),
            _kvRow('Task ID', current.id),
            const SizedBox(height: 22),
            const Text('Change status', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(
              children: TaskStatus.values.map((s) {
                final selected = s == current.status;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.read<TaskProvider>().updateStatus(taskId: current.id, status: s),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.mossTint : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: selected ? AppColors.moss : AppColors.line, width: 1.6),
                      ),
                      alignment: Alignment.center,
                      child: Text(s.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: selected ? AppColors.mossDeep : AppColors.inkSoft)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Edit',
                    outlined: true,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AddEditTaskScreen(existing: current)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: 'Delete',
                    danger: true,
                    onPressed: () => _confirmDelete(context, current),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kvRow(String k, String v) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(fontSize: 11.5, color: AppColors.inkFaint, fontWeight: FontWeight.w600)),
          Flexible(
            child: Text(v,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('Delete this task?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text('"${task.title}" will be removed permanently.',
            style: const TextStyle(fontSize: 13, color: AppColors.inkFaint)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<TaskProvider>().deleteTask(task.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.brick, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
