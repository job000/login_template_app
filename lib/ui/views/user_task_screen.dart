// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../../core/models/task_model.dart';
import 'task_screen.dart';


class UserTasksScreen extends StatefulWidget {
  const UserTasksScreen({super.key});

  @override
  _UserTasksScreenState createState() => _UserTasksScreenState();
}

class _UserTasksScreenState extends State<UserTasksScreen> {
  List<TaskList> taskLists = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTaskLists();
  }

Future<void> _loadTaskLists() async {
  setState(() {
    isLoading = true;
  });

  // Query the TaskList class for lists where the current user is a member
  final currentUser = await ParseUser.currentUser() as ParseUser;
  final taskListQuery = QueryBuilder<ParseObject>(ParseObject('TaskList'))
    ..whereEqualTo('members', currentUser.toPointer());

  final ParseResponse response = await taskListQuery.query();

  if (response.success && response.results != null) {
    final List<TaskList> tempTaskLists = [];

    for (var taskListParse in response.results as List<ParseObject>) {
      // Convert each ParseObject to a TaskList
      final taskList = await TaskList.fromParse(taskListParse);
      tempTaskLists.add(taskList);
    }

    setState(() {
      taskLists = tempTaskLists;
      isLoading = false;
    });
  } else {
    // Handle error retrieving task lists
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    // Build UI
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Task Lists'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: taskLists.length,
              itemBuilder: (context, index) {
                final taskList = taskLists[index];
                return ListTile(
                  title: Text(taskList.name),
                  subtitle: Text('Tasks: ${taskList.tasks.length}'),
                  onTap: () {
                    // Handle task list tap
                    // For example, navigate to task details screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TaskScreen(taskList: taskList),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}