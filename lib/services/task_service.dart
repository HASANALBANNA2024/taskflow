import '../core/api_client.dart';
import '../models/task_model.dart';

/// Wraps the "User Task" folder of the Postman collection:
/// CreateTask, DeleteTask, UpdateTaskStatus, ListTaskByStatus, TaskStatusCount.
class TaskService {
  final ApiClient _api = ApiClient.instance;

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required TaskStatus status,
  }) async {
    final res = await _api.post(
      '/createTask',
      body: {
        'title': title,
        'description': description,
        'status': status.apiValue,
      },
    );
    return TaskModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  /// The API has no dedicated "list all" endpoint — the app fetches each
  /// status bucket via /listTaskByStatus/:status and merges the results.
  Future<List<TaskModel>> listTasksByStatus(TaskStatus status) async {
    final res = await _api.get('/listTaskByStatus/${status.apiValue}');
    final list = (res['data'] as List<dynamic>? ?? []);
    return list.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TaskModel>> listAllTasks() async {
    final results = await Future.wait(TaskStatus.values.map(listTasksByStatus));
    final all = results.expand((e) => e).toList();
    all.sort((a, b) {
      final ad = a.createdDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.createdDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
    return all;
  }

  Future<TaskStatusCount> statusCount() async {
    final res = await _api.get('/taskStatusCount');
    return TaskStatusCount.fromJsonList(res['data'] as List<dynamic>? ?? []);
  }

  Future<void> updateStatus({required String taskId, required TaskStatus status}) async {
    await _api.get('/updateTaskStatus/$taskId/${status.apiValue}');
  }

  Future<void> deleteTask(String taskId) async {
    await _api.get('/deleteTask/$taskId');
  }
}
