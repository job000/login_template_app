import 'package:flutter/material.dart';
import '../../core/models/task_model.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final Function(String description, String status) onSubmit;

  const TaskDialog({super.key, this.task, required this.onSubmit});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _descriptionController = TextEditingController();
  String _status = 'Queue';

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _descriptionController.text = widget.task!.description;
      _status = widget.task!.status;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Create Task' : 'Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _status,
              onChanged: (value) => setState(() => _status = value ?? _status),
              items: const [
                DropdownMenuItem(value: 'Queue', child: Text('Queue')),
                DropdownMenuItem(value: 'In progress', child: Text('In progress')),
                DropdownMenuItem(value: 'Blocked', child: Text('Blocked')),
                DropdownMenuItem(value: 'Finished', child: Text('Finished')),
              ],
              decoration: const InputDecoration(labelText: 'Status'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await widget.onSubmit(_descriptionController.text, _status);
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
