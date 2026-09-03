import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/task_widgets.dart';
import '../tasks/task_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final user = auth.currentUser;
    final recent = taskProvider.tasks.take(5).toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<TaskProvider>().loadAll(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Good to see you', style: TextStyle(fontSize: 12.5, color: AppColors.inkFaint, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(user?.fullName.trim().isNotEmpty == true ? user!.fullName : 'there',
                        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                  ],
                ),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.mossTint, borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Text(user?.initials ?? '?',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.mossDeep, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (taskProvider.isLoading && taskProvider.tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: AppColors.moss)),
              )
            else ...[
              Row(
                children: [
                  StatCard(
                    value: '${taskProvider.counts.total}',
                    label: 'Total tasks',
                    background: AppColors.chipNeutral,
                    foreground: AppColors.ink,
                  ),
                  const SizedBox(width: 10),
                  StatCard(
                    value: '${taskProvider.counts.newCount}',
                    label: 'New',
                    background: AppColors.amberTint,
                    foreground: AppColors.amber,
                  ),
                  const SizedBox(width: 10),
                  StatCard(
                    value: '${taskProvider.counts.completedCount}',
                    label: 'Completed',
                    background: AppColors.mossTint,
                    foreground: AppColors.mossDeep,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text('Recent tasks', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              if (recent.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: EmptyState(
                    icon: Icons.task_alt_outlined,
                    title: 'No tasks yet',
                    message: 'Tap the + button below to add your first task.',
                  ),
                )
              else
                ...recent.map((task) => TaskCard(
                      task: task,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task)),
                      ),
                      onToggleDone: (done) => context.read<TaskProvider>().updateStatus(
                            taskId: task.id,
                            status: done ? TaskStatus.completed : TaskStatus.newTask,
                          ),
                    )),
            ],
          ],
        ),
      ),
    );
  }
}
