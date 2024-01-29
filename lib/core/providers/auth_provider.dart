
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  ParseUser? _currentUser;
  bool _isAdmin = false;

  ParseUser? get currentUser => _currentUser;
  bool get isAdmin => _isAdmin;

  Future<void> setUser(ParseUser user) async {
    _currentUser = user;
    List<String> roles = await getUserRoleNames(user);
    _isAdmin = roles.contains('admin');
    notifyListeners(); // Notify listeners about the change
  }

  Future<void> logout() async {
    if (_currentUser != null) {
      await _currentUser!.logout();
      _currentUser = null;
      _isAdmin = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('username');
      await prefs.remove('password');
      notifyListeners();
    }
  }

  Future<List<String>> getUserRoleNames(ParseUser user) async {
    List<String> roleNames = [];
    if (user.objectId == null) {
      return roleNames;
    }
    var roleQuery = QueryBuilder<ParseObject>(ParseObject('_Role'))
      ..whereEqualTo('users', ParseObject('_User')..objectId = user.objectId);
    final ParseResponse response = await roleQuery.query();
    if (response.success && response.results != null) {
      for (var role in response.results as List<ParseObject>) {
        String? roleName = role.get<String>('name');
        if (roleName != null) {
          roleNames.add(roleName);
        }
      }
    }
    return roleNames;
  }
}
