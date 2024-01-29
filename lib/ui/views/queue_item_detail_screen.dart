// ignore_for_file: dead_code

import 'package:flutter/material.dart';

import '../../core/utils/queue_item.dart';

class QueueItemDetailScreen extends StatefulWidget {
  final QueueItem item;


  QueueItemDetailScreen({required this.item});

  @override
  _QueueItemDetailScreenState createState() => _QueueItemDetailScreenState();
}


class _QueueItemDetailScreenState extends State<QueueItemDetailScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _statusController;
  late Map<String, TextEditingController> _detailControllers;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _statusController = TextEditingController(text: widget.item.status);

    _detailControllers = {};
    widget.item.details.forEach((key, value) {
      _detailControllers[key] = TextEditingController(text: value.toString());
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    _detailControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  bool isEditable = true; // Assuming 'admin' role can edit

  return Scaffold(
    appBar: AppBar(
      title: const Text('Task Details'),
      actions: isEditable ? [
        IconButton(
          icon: Icon(Icons.save),
          onPressed: _saveTask,
        )
      ] : [],
    ),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
            enabled: isEditable,
          ),
          TextFormField(
            controller: _statusController,
            decoration: InputDecoration(labelText: 'Status'),
            enabled: isEditable,
          ),
          ..._buildDetailTextFields(isEditable),
        ],
      ),
    ),
  );
}

List<Widget> _buildDetailTextFields(bool isEditable) {
  return _detailControllers.entries.map((entry) {
    return TextFormField(
      controller: entry.value,
      decoration: InputDecoration(labelText: entry.key),
      enabled: isEditable,
    );
  }).toList();
}


  void _saveTask() {
    setState(() {
      widget.item.name = _nameController.text;
      widget.item.status = _statusController.text;
      _detailControllers.forEach((key, controller) {
        widget.item.details[key] = controller.text;
      });
    });
    Navigator.pop(context); // Optionally, return to the previous screen
  }
}
