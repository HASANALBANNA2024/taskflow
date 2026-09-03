import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/task_model.dart';

class StatusChip extends StatelessWidget {
  final TaskStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color fg;
    switch (status) {
      case TaskStatus.newTask:
        bg = AppColors.amberTint;
        fg = AppColors.amber;
        break;
      case TaskStatus.inProgress:
        bg = AppColors.chipNeutral;
        fg = AppColors.inkSoft;
        break;
      case TaskStatus.completed:
        bg = AppColors.mossTint;
        fg = AppColors.mossDeep;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color background;
  final Color foreground;
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: foreground, height: 1)),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: foreground)),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggleDone;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleDone,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final done = task.status == TaskStatus.completed;
    final card = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => onToggleDone(!done),
              child: Container(
                width: 22, height: 22,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: done ? AppColors.moss : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: done ? AppColors.moss : AppColors.line, width: 2),
                ),
                child: done ? const Icon(Icons.check, size: 15, color: Colors.white) : null,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done ? AppColors.inkFaint : AppColors.ink,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      task.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.inkFaint),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      StatusChip(status: task.status),
                      const SizedBox(width: 8),
                      if (task.createdDate != null)
                        Text(
                          DateFormat('d MMM').format(task.createdDate!),
                          style: const TextStyle(fontSize: 10, color: AppColors.inkFaint, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onDelete == null) return card;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 18),
        decoration: BoxDecoration(color: AppColors.brick, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete!.call();
        return false; // deletion handled by the caller (optimistic update)
      },
      child: card,
    );
  }
}
