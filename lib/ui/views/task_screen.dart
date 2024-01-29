// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, prefer_const_constructors, no_logic_in_create_state, unused_element, avoid_print

import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import '../../core/models/task_model.dart';
import 'task_dialog_screen.dart';

class TaskScreen extends StatefulWidget {
  final TaskList taskList;

  const TaskScreen({super.key, required this.taskList});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late List<Task> _tasks;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tasks = widget.taskList.tasks;
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    // Query tasks related to the selected task list
    final taskQuery = QueryBuilder<ParseObject>(ParseObject('Task'))
      ..whereEqualTo('taskList',
          ParseObject('TaskList')..objectId = widget.taskList.objectId);

    final ParseResponse response = await taskQuery.query();

    if (response.success && response.results != null) {
      final List<Task> tasks = (response.results as List<ParseObject>)
          .map((taskParse) => Task.fromParse(taskParse))
          .toList();
      setState(() {
        _tasks = tasks;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

 Future<void> _updateTask(Task task, String description, String status, ParseUser newAssignee) async {
    setState(() => _isLoading = true);

    final taskParseObj = ParseObject('Task')
      ..objectId = task.objectId
      ..set('description', description)
      ..set('status', status)
      ..set('assignedTo', newAssignee);

    if (newAssignee.objectId != task.assignedTo) {
      final acl = ParseACL(owner: newAssignee);
      acl.setPublicReadAccess(allowed: true);
      taskParseObj.setACL(acl);
    }

    final ParseResponse response = await taskParseObj.save();

    if (response.success) {
      setState(() {
        task.description = description;
        task.status = status;
        task.assignedTo = newAssignee.objectId!;
        _loadTasks(); // Reload tasks to reflect changes
      });
    } else {
      // Handle update error
      print('Error updating task: ${response.error?.message}');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to update task: ${response.error?.message}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _createTask(String description, String status) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // Get current user
    final currentUser = await ParseUser.currentUser() as ParseUser;

    // Create the ACL for the new task, granting read and write permissions only to the currentUser and possibly the admins
    final acl = ParseACL(owner: currentUser);
    acl.setPublicReadAccess(
        allowed: true); // if you want all users to be able to read tasks
    // If you have an admin role, you might want to set Write access for the admin role as well

    // Create new task object and assign the current user as 'assignedTo' and 'createdBy'
    final newTask = ParseObject('Task')
      ..set('description', description)
      ..set('status', status) // Status set by the user
      ..set('assignedTo', currentUser) // Assign the task to the current user
      ..set('taskList',
          ParseObject('TaskList')..objectId = widget.taskList.objectId)
      ..set('createdBy', currentUser)
      ..setACL(acl); // Set the ACL for the task

    final ParseResponse response = await newTask.save();

    setState(() {
      _isLoading = false; // Hide loading indicator
    });

    if (response.success && response.result != null) {
      final newTaskFromResponse =
          Task.fromParse(response.result as ParseObject);
      setState(() {
        _tasks.add(
            newTaskFromResponse); // Update local tasks list with the new task
      });
    } else {
      // If the operation failed, show an error
      print(response.error?.message ?? 'Failed to create task');
    }
  }

  Future<void> _deleteTask(Task task) async {
    // Delete task object from Parse
    final taskParseObj = ParseObject('Task')..objectId = task.objectId;

    final ParseResponse response = await taskParseObj.delete();
    if (response.success) {
      setState(() {
        _tasks.remove(task);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // The UI for your task screen which includes listing tasks, adding new tasks,
    // updating tasks, and deleting tasks
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskList.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (ctx, index) {
                final task = _tasks[index];
                return ListTile(
                  title: Text(task.description),
                  subtitle: Text(task.status),
                  trailing: PopupMenuButton(
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'edit') {
                        // Show dialog to edit task
                        final newTask = await showDialog<Task>(
                          context: context,
                          builder: (ctx) => TaskDialog(
                            task: task,
                            onSubmit: (description, status) async {
                              await _updateTask(task, description, status,
                                  task.assignedToUser!);
                              Navigator.of(ctx).pop();
                            },
                          ),
                        );

                        if (newTask != null) {
                          setState(() {
                            task.description = newTask.description;
                            task.status = newTask.status;
                          });
                        }
                      } else if (value == 'delete') {
                        // Delete task
                        await _deleteTask(task);
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Show dialog to create new task
          showDialog<void>(
            context: context,
            builder: (ctx) => TaskDialog(
              onSubmit: (description, status) {
                _createTask(description, status).then((_) {
                  // After creating, dismiss the task dialog and reload tasks
                  _loadTasks();
                  Navigator.of(ctx).pop();
                });
              },
            ),
          );
        },
      ),
    );
  }
}
