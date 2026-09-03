/// The API's live data only ever showed "New" and "Completed" as task
/// statuses. "In Progress" is added here as a natural third state for a
/// more complete workflow — remove it if your backend doesn't support it.
enum TaskStatus { newTask, inProgress, completed }

extension TaskStatusX on TaskStatus {
  /// Exact string the API expects, e.g. in
  /// GET /updateTaskStatus/:id/:status and GET /listTaskByStatus/:status
  String get apiValue {
    switch (this) {
      case TaskStatus.newTask:
        return 'New';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.newTask:
        return 'New';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  static TaskStatus fromApi(String? value) {
    switch (value) {
      case 'Completed':
        return TaskStatus.completed;
      case 'In Progress':
        return TaskStatus.inProgress;
      case 'New':
      default:
        return TaskStatus.newTask;
    }
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final String email;
  final DateTime? createdDate;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.email,
    this.createdDate,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: TaskStatusX.fromApi(json['status']?.toString()),
      email: json['email']?.toString() ?? '',
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'].toString())
          : null,
    );
  }

  TaskModel copyWith({TaskStatus? status}) {
    return TaskModel(
      id: id,
      title: title,
      description: description,
      status: status ?? this.status,
      email: email,
      createdDate: createdDate,
    );
  }
}

/// Parsed shape of GET /taskStatusCount:
/// { "data": [ { "_id": "Completed", "sum": 1 }, { "_id": "New", "sum": 2 } ] }
class TaskStatusCount {
  final int newCount;
  final int inProgressCount;
  final int completedCount;

  TaskStatusCount({
    this.newCount = 0,
    this.inProgressCount = 0,
    this.completedCount = 0,
  });

  int get total => newCount + inProgressCount + completedCount;

  factory TaskStatusCount.fromJsonList(List<dynamic> list) {
    var newC = 0, inProgC = 0, doneC = 0;
    for (final item in list) {
      final id = item['_id']?.toString();
      final sum = (item['sum'] as num?)?.toInt() ?? 0;
      switch (id) {
        case 'New':
          newC = sum;
          break;
        case 'In Progress':
          inProgC = sum;
          break;
        case 'Completed':
          doneC = sum;
          break;
      }
    }
    return TaskStatusCount(newCount: newC, inProgressCount: inProgC, completedCount: doneC);
  }
}
