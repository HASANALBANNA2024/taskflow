import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common_widgets.dart';

/// Handles both creating a new task and "editing" an existing one.
///
/// Note: the API only exposes createTask, deleteTask and updateTaskStatus —
/// there is no endpoint to update a task's title/description in place.
/// So editing here is implemented as delete-then-recreate, which keeps the
/// UI honest about what's actually happening while still giving users a
/// normal-feeling edit flow. If your backend gains a real update-task
/// endpoint, swap the logic in [_submit] for a single call to it.
class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? existing;
  const AddEditTaskScreen({super.key, this.existing});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _description = TextEditingController(text: widget.existing?.description ?? '');
  late TaskStatus _status = widget.existing?.status ?? TaskStatus.newTask;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.existing != null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final provider = context.read<TaskProvider>();
    bool ok;
    if (_isEditing) {
      ok = await provider.deleteTask(widget.existing!.id);
      if (ok) {
        ok = await provider.createTask(
          title: _title.text.trim(),
          description: _description.text.trim(),
          status: _status,
        );
      }
    } else {
      ok = await provider.createTask(
        title: _title.text.trim(),
        description: _description.text.trim(),
        status: _status,
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = provider.errorMessage ?? 'Could not save the task.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit task' : 'Add task')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null) InlineError(message: _error!),
                AppTextField(
                  label: 'Title',
                  controller: _title,
                  hint: 'e.g. Prepare client presentation',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                AppTextField(
                  label: 'Description',
                  controller: _description,
                  hint: 'Add any useful details',
                  maxLines: 4,
                ),
                const Text('Status', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
                const SizedBox(height: 8),
                Row(
                  children: TaskStatus.values.map((s) {
                    final selected = s == _status;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _status = s),
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
                const SizedBox(height: 26),
                AppButton(label: _isEditing ? 'Save changes' : 'Save task', onPressed: _submit, loading: _saving),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
