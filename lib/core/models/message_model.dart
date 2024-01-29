import 'package:parse_server_sdk/parse_server_sdk.dart';

class Message {
  final String id;
  final ParseUser fromUser; // Update to ParseUser
  final ParseUser toUser;   // Update to ParseUser
  final String messageText;
  final DateTime createdAt;
  bool read; // To track read status

  Message({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.messageText,
    required this.createdAt,
    this.read = false,
  });

  factory Message.fromParse(ParseObject parseObject) {
    return Message(
      id: parseObject.objectId!,
      fromUser: parseObject.get<ParseUser>('fromUser')!, // Update this
      toUser: parseObject.get<ParseUser>('toUser')!,     // Update this
      messageText: parseObject.get<String>('messageText')!,
      createdAt: parseObject.createdAt!,
      read: parseObject.get<bool>('read') ?? false,
    );
  }
}
