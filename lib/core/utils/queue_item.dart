//Probably not needed, but we'll see.
import 'dart:convert';

class QueueItem {
  String id;
  String name;
  String status;
  Map<String, dynamic> details;

  QueueItem({required this.id, required this.name, required this.status, required this.details});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'details': json.encode(details),
    };
  }

  static QueueItem fromMap(Map<String, dynamic> map) {
    return QueueItem(
      id: map['id'],
      name: map['name'],
      status: map['status'],
      details: json.decode(map['details']),
    );
  }

  void updateDetails(String key, dynamic value) {
    details[key] = value;
  }



  // Dummy data generator
  static List<QueueItem> generateDummyQueueItems() {
    return List.generate(10, (index) => QueueItem(
      id: 'ID$index',
      name: 'Task $index',
      status: index % 2 == 0 ? 'Pending' : 'Completed',
      details: {'detail1': 'value1', 'detail2': 'value2','comment':'kommentar her.'} // Add more details as needed
    ));
  }
}
