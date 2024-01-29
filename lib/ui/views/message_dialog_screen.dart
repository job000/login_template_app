import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../../core/models/message_model.dart';
 // Import your message model

class MessageDialogScreen extends StatefulWidget {
  const MessageDialogScreen({Key? key}) : super(key: key);

  @override
  _MessageDialogScreenState createState() => _MessageDialogScreenState();
}

class _MessageDialogScreenState extends State<MessageDialogScreen> {
  late List<Message> messages;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    // Query to fetch messages for a specific dialog
    var query = QueryBuilder(ParseObject('Message'))
      ..whereEqualTo('conversationId', 'your_conversation_id') // Update this
      ..orderByDescending('createdAt');
    final response = await query.query();

    if (response.success && response.results != null) {
      setState(() {
        messages = response.results!.map((e) => Message.fromParse(e)).toList();
      });
    } else {
      // Handle errors or empty results
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      // Logic to send message
      var message = ParseObject('Message')
        ..set('messageText', _messageController.text)
        ..set('fromUser', ParseUser.currentUser)
        // Set other necessary fields like 'toUser', 'conversationId', etc.
        ..set('conversationId', 'your_conversation_id'); // Update this
        
      await message.save();

      _messageController.clear();
      _loadMessages(); // Reload messages
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Dialog'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Text(message.messageText),
                  subtitle: Text('Sent at ${message.createdAt}'),
                  // Customize each message bubble
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
