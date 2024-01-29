
//TODO: Delete this file
/*
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'message_model.dart';

class UserModel with ChangeNotifier {
  ParseUser? _currentUser;
  bool _isAdmin = false;
  ParseUser? _selectedUserForMessaging;
  List<Message> _inboxMessages = [];
  List<Message> _sentMessages = [];
  int _unreadCount = 0;
  String _themeMode = 'light'; // Default theme mode
  String get themeMode => _themeMode;


  ParseUser? get currentUser => _currentUser;
  bool get isAdmin => _isAdmin;
  ParseUser? get selectedUserForMessaging => _selectedUserForMessaging;
  List<Message> get inboxMessages => _inboxMessages;
  List<Message> get sentMessages => _sentMessages;
  int get unreadCount => _unreadCount;

  Future<void> setUser(ParseUser user) async {
    _currentUser = user;
    List<String> roles = await getUserRoleNames(user);
    _isAdmin = roles.contains('admin');
    notifyListeners(); // Notify listeners about the change
  }

    void removeMessage(Message message, bool isInbox) {
    if (isInbox) {
      inboxMessages.removeWhere((m) => m.id == message.id);
    } else {
      sentMessages.removeWhere((m) => m.id == message.id);
    }
    notifyListeners();
  }

 Future<void> logout() async {
  // Check if there is a current user to log out
  if (_currentUser != null) {
    await _currentUser!.logout(); // Logout the current user
    
    _currentUser = null; // Set the current user to null after successful logout
    _isAdmin = false; // Reset the admin flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
  }
  notifyListeners(); // Notify listeners about the change
}


  Future<bool> checkIfUserIsAdmin(ParseUser user) async {
    List<String> roles = await getUserRoleNames(user);
    bool isAdmin = false;

    for (String role in roles) {
      if (role.toLowerCase() == 'admin') {
        isAdmin = true;
        break; // Stop the loop as we found the Admin role
      }
    }

    print(isAdmin ? 'User is an Admin' : 'User is not an Admin');
    return isAdmin;
  }

  Future<List<String>> getUserRoleNames(ParseUser user) async {
    List<String> roleNames = [];

    // Ensure that the user is logged in and has a valid session
    if (user.objectId == null) {
      return roleNames; // User is not logged in or invalid, return empty list
    }

    // Create a query on the Role class
    var roleQuery = QueryBuilder<ParseObject>(ParseObject('_Role'))
      ..whereEqualTo('users', ParseObject('_User')..objectId = user.objectId);

    // Execute the query
    final ParseResponse response = await roleQuery.query();

    if (response.success && response.results != null) {
      // Iterate over all roles and collect their names
      for (var role in response.results as List<ParseObject>) {
        String? roleName = role.get<String>('name');
        if (roleName != null) {
          roleNames.add(roleName);
          print('User role: $roleName');
        }
      }
    } else {
      // Handle the error, could log or throw
      print('Failed to retrieve user roles: ${response.error?.message}');
    }

    return roleNames; // Return the list of role names
  }
 void setSelectedUserForMessaging(ParseUser? user) {
    _selectedUserForMessaging = user;
    notifyListeners(); // Notify listeners about the change
  }

  void addInboxMessage(Message message) {
    _inboxMessages.add(message);
    if (!message.read) {
      _unreadCount++;
    }
    notifyListeners(); // Notify listeners about the change
  }

  void addSentMessage(Message message) {
    _sentMessages.add(message);
    notifyListeners(); // Notify listeners about the change
  }

 void setInboxMessages(List<Message> messages) {
    _inboxMessages = messages;
    notifyListeners();
  }

  void setSentMessages(List<Message> messages) {
    _sentMessages = messages;
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


  // Fetch the current theme mode from the database
  Future<void> fetchThemeMode() async {
    if (_currentUser != null) {
      await _currentUser!.fetch();
      _themeMode = _currentUser!.get<String>('themeMode') ?? 'light';
      notifyListeners();
    }
  }

  Future<void> updateThemeMode(String newThemeMode) async {
    if (_currentUser != null) {
      _currentUser!.set('themeMode', newThemeMode);
      await _currentUser!.save();
      _themeMode = newThemeMode;
      notifyListeners();
    }
  }
  
void setUnreadCount(int count) {
  _unreadCount = count;
  notifyListeners(); // Notify listeners about the change
}



}
*/