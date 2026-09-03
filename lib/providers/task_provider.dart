import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<TaskModel> tasks = [];
  TaskStatusCount counts = TaskStatusCount();
  bool isLoading = false;
  String? errorMessage;

  List<TaskModel> tasksFor(TaskStatus? status) {
    if (status == null) return tasks;
    return tasks.where((t) => t.status == status).toList();
  }

  Future<void> loadAll() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _taskService.listAllTasks(),
        _taskService.statusCount(),
      ]);
      tasks = results[0] as List<TaskModel>;
      counts = results[1] as TaskStatusCount;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> createTask({
    required String title,
    required String description,
    required TaskStatus status,
  }) async {
    try {
      await _taskService.createTask(title: title, description: description, status: status);
      await loadAll();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus({required String taskId, required TaskStatus status}) async {
    // Optimistic update so the UI feels instant.
    final idx = tasks.indexWhere((t) => t.id == taskId);
    final previous = idx != -1 ? tasks[idx] : null;
    if (idx != -1) {
      tasks[idx] = tasks[idx].copyWith(status: status);
      notifyListeners();
    }
    try {
      await _taskService.updateStatus(taskId: taskId, status: status);
      await loadAll();
      return true;
    } catch (e) {
      if (idx != -1 && previous != null) tasks[idx] = previous;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    final removed = tasks.where((t) => t.id == taskId).toList();
    tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
    try {
      await _taskService.deleteTask(taskId);
      await loadAll();
      return true;
    } catch (e) {
      if (removed.isNotEmpty) tasks.add(removed.first);
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
