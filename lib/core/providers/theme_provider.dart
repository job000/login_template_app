import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'auth_provider.dart';


class ThemeProvider with ChangeNotifier {
  String _themeMode = '';
   AuthProvider? userModel; // Make this nullable
  ParseUser? get _currentUser => userModel?.currentUser; // Assuming UserModel has a currentUser getter

  ThemeProvider(this.userModel) {
    fetchThemeMode();
  }

  ThemeMode get themeMode => _themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light;

  // Add this new method
  void setUserModel(AuthProvider userModel) {
    this.userModel = userModel;
    fetchThemeMode();
  }

  Future<void> fetchThemeMode() async {
    if (_currentUser != null) {
      await _currentUser!.fetch();
      _themeMode = _currentUser!.get<String>('themeMode') ?? 'light';
      notifyListeners();
    }
  }

Future<bool> updateThemeMode(String newThemeMode) async {
  if (_currentUser != null) {
    _currentUser!.set('themeMode', newThemeMode);
    var response = await _currentUser!.save();

    if (response.success) {
      print("Theme mode updated successfully.");
      _themeMode = newThemeMode;
      notifyListeners();
      return true;
    } else {
      print("Failed to update theme mode: ${response.error?.message}");
      return false;
    }
  } else {
    print("No current user found for updating theme mode.");
    return false;
  }
}



void setThemeMode(String themeModeValue) {
  _themeMode = themeModeValue;
  notifyListeners();  // Notify listeners about the theme change
}



  void toggleTheme() async {
    String newThemeMode = _themeMode == 'light' ? 'dark' : 'light';
    await updateThemeMode(newThemeMode);
  }
}
