import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import '../../core/models/message_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/message_provider.dart';
import 'new_message_screen.dart';
import 'user_search_dialog_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool isLoading = true;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  
  }

Future<void> _loadMessages() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final messageProvider = Provider.of<MessageProvider>(context, listen: false);
  var currentUser = authProvider.currentUser;
  if (currentUser == null) return;

  try {
    // Create a pointer based on the currentUser's objectId
    var userPointer = ParseUser.forQuery()
      ..objectId = currentUser.objectId;

    // Query for messages sent by the currentUser
    var sentQuery = QueryBuilder(ParseObject('Message'))
      ..whereEqualTo('fromUser', userPointer)
      ..orderByDescending('createdAt')
      ..includeObject(['fromUser', 'toUser']);

    // Query for messages received by the currentUser
    var receivedQuery = QueryBuilder(ParseObject('Message'))
      ..whereEqualTo('toUser', userPointer)
      ..orderByDescending('createdAt')
      ..includeObject(['fromUser', 'toUser']);

    // Execute the queries
    final sentResponse = await sentQuery.query();
    final receivedResponse = await receivedQuery.query();

    if (sentResponse.success &&
        sentResponse.results != null &&
        receivedResponse.success &&
        receivedResponse.results != null) {
      var allSentMessages =
          sentResponse.results!.map((e) => Message.fromParse(e)).toList();
      var allReceivedMessages =
          receivedResponse.results!.map((e) => Message.fromParse(e)).toList();

      messageProvider.setSentMessages(allSentMessages);
      messageProvider.setInboxMessages(allReceivedMessages);

      // Count unread messages
      int unreadMessageCount = allReceivedMessages.where((message) => !message.read).length;
      print('Unread messages: $unreadMessageCount'); 
      messageProvider.setUnreadCount(unreadMessageCount); // Update the unread count in the UserModel

      setState(() {
        this.unreadCount = unreadMessageCount; // Update local state if needed
      });
    }

    setState(() => isLoading = false);
  } catch (e) {
    setState(() => isLoading = false);
    _showErrorDialog('Error loading messages: $e');
  }
}





  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          bottom: TabBar(
            tabs: [
              Consumer<MessageProvider>(
                builder: (context, userModel, child) {
                  return Tab(
                      text: 'Inbox (${unreadCount})');
                },
              ),
              const Tab(text: 'Sent'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: _loadMessages,
                    child: _buildMessagesList(
                        context, Provider.of<MessageProvider>(context).inboxMessages, true),
                  ),
                  RefreshIndicator(
                    onRefresh: _loadMessages,
                    child: _buildMessagesList(
                        context, Provider.of<MessageProvider>(context).sentMessages, false),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _selectUserForNewMessage,
          child: const Icon(Icons.add),
          tooltip: 'Compose New Message',
        ),
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, List<Message> messages, bool isInbox) {
    return messages.isEmpty
        ? const Center(child: Text('No messages found'))
        : ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return ListTile(
                title: Text(
                  message.messageText,
                  style: TextStyle(
                    fontWeight: isInbox && !message.read
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text('Sent at ${message.createdAt}'),
                onTap: () => _showMessageDetails(context, message, isInbox),
                trailing: IconButton(
                  icon: const Icon(Icons.reply, color: Colors.blue),
                  onPressed: () => _composeNewMessage(context, replyTo: message),
                  tooltip: 'Reply',
                ),
              );
            },
          );
  }

void _showMessageDetails(BuildContext context, Message message, bool isInbox) {
  if (isInbox && !message.read) {
    _markAsRead(message);
  }

  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // Rounded corners
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7, // Use 80% of screen width or a fixed value
        height: MediaQuery.of(context).size.height * 0.5, // Use 50% of screen height or a fixed value
        child: AlertDialog(
          title: const Text('Message Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('From: ${message.fromUser.username}', style: TextStyle(fontSize: 16)),
                Text('To: ${message.toUser.username}', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8), // Reduced space
                Text('Message: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(message.messageText, style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8), // Reduced space
                Text('Sent at: ${message.createdAt}', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Answer'),
              onPressed: () {
                Navigator.of(context). pop();
                _composeNewMessage(context, replyTo: message);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMessage(message, isInbox);
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    ),
  );
}


  Future<void> _markAsRead(Message message) async {
    var messageToUpdate = ParseObject('Message')
      ..objectId = message.id
      ..set('read', true);

    await messageToUpdate.save();

    if (!mounted) return; // Check if the widget is still in the widget tree

    final userModel = Provider.of<MessageProvider>(context, listen: false);
    userModel.markMessageAsRead(message);
    
  }

  Future<void> _deleteMessage(Message message, bool isInbox) async {
    try {
      var messageToDelete = ParseObject('Message')..objectId = message.id;
      await messageToDelete.delete();

      if (!mounted) return; // Check if the widget is still in the widget tree

      final userModel = Provider.of<MessageProvider>(context, listen: false);
      userModel.removeMessage(message, isInbox);
     

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return; // Also check here before showing the dialog
      _showErrorDialog('Error deleting message: $e');
    }
  }

  void _composeNewMessage(BuildContext context, {Message? replyTo}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewMessageScreen(replyTo: replyTo),
      ),
    );
  }

  void _selectUserForNewMessage() async {
    final ParseUser? selectedUser = await showDialog<ParseUser>(
      context: context,
      builder: (context) => const UserSearchDialog(),
    );

    if (selectedUser != null) {
      final messageProvider = Provider.of<MessageProvider>(context, listen: false);
      messageProvider.setSelectedUserForMessaging(selectedUser);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const NewMessageScreen(),
        ),
      );
    }
  }
}
