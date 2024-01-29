
// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import '../models/message_model.dart';


class MessageProvider with ChangeNotifier {
  List<Message> _inboxMessages = [];
  List<Message> _sentMessages = [];
  int _unreadCount = 0;

  List<Message> get inboxMessages => _inboxMessages;
  List<Message> get sentMessages => _sentMessages;
  int get unreadCount => _unreadCount;
  ParseUser? selectedUserForMessaging;

  void addInboxMessage(Message message) {
    _inboxMessages.add(message);
    if (!message.read) {
      _unreadCount++;
    }
    notifyListeners();
  }

  void addSentMessage(Message message) {
    _sentMessages.add(message);
    notifyListeners();
  }

  void setInboxMessages(List<Message> messages) {
    _inboxMessages = messages;
    notifyListeners();
  }

  void setSentMessages(List<Message> messages) {
    _sentMessages = messages;
    notifyListeners();
  }

  void removeMessage(Message message, bool isInbox) {
    if (isInbox) {
      _inboxMessages.removeWhere((m) => m.id == message.id);
    } else {
      _sentMessages.removeWhere((m) => m.id == message.id);
    }
    notifyListeners();
  }

   Future<void> markMessageAsRead(Message message) async {
    try {
      // Check if the message is already marked as read
      if (!message.read) {
        var messageToUpdate = ParseObject('Message')
          ..objectId = message.id
          ..set('read', true);

        final response = await messageToUpdate.save();

        if (response.success) {
          // Mark the message as read in the local list
          message.read = true;
          notifyListeners();
        } else {
          // Handle the case where updating the message failed
          throw Exception('Failed to mark message as read');
        }
      }
    } catch (e) {
      // Handle any exceptions that may occur
      print('Error marking message as read: $e');
    }
  }


  void setUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }

     void setSelectedUserForMessaging(ParseUser? user) {
    selectedUserForMessaging = user;
    notifyListeners(); // Notify listeners about the change
  }
}
