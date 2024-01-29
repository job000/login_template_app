// Define Task Data Model
import 'package:parse_server_sdk/parse_server_sdk.dart';

class Task {
  final String objectId;
  late final String description;
  late final String status;
  final DateTime? dueDate;
  late final String assignedTo;
  final String taskListId;

  Task({
    required this.objectId,
    required this.description,
    required this.status,
    this.dueDate,
    required this.assignedTo,
    required this.taskListId,
  });

  // Add method to convert a ParseObject to Task
  factory Task.fromParse(ParseObject parseObject) {
    return Task(
      objectId: parseObject.objectId!,
      description: parseObject.get<String>('description')!,
      status: parseObject.get<String>('status')!,
      dueDate: parseObject.get<DateTime>('dueDate'),
      assignedTo: parseObject.get<ParseUser>('assignedTo')!.objectId!,
      taskListId: parseObject.get<ParseObject>('taskList')!.objectId!,
    );
  }

  get assignedToUser => null;
}

// Define TaskList Data Model
class TaskList {
  final String objectId;
  final String name;
  final List<Task> tasks;

  TaskList({
    required this.objectId,
    required this.name,
    required this.tasks,
  });

  // Add method to convert a ParseObject to TaskList and query tasks
  static Future<TaskList> fromParse(ParseObject parseObject) async {
    // Query for tasks that belong to this taskList
    final taskQuery = QueryBuilder<ParseObject>(ParseObject('Task'))
      ..whereEqualTo('taskList', ParseObject('TaskList')..set('objectId', parseObject.objectId));

    final taskResponse = await taskQuery.query();
    final tasks = (taskResponse.results as List<ParseObject>?)?.map((task) => Task.fromParse(task)).toList() ?? [];

    return TaskList(
      objectId: parseObject.objectId!,
      name: parseObject.get<String>('name')!,
      tasks: tasks,
    );
  }
}