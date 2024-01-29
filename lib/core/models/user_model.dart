import 'package:parse_server_sdk/parse_server_sdk.dart';

class User {
  late String firstname;
  late String lastname;
  late String username;
  late String password;
  late String email;
  late String themeMode;

     // Additional field

  User({
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.password,
    required this.email,
    this.themeMode = 'light',
  });

  // Convert User to ParseUser for registration
  ParseUser toParseUser() {
    var parseUser = ParseUser(
      username,
      password,
      email,
    )
      ..set('firstname', firstname)
      ..set('lastname', lastname)
      ..set('themeMode', themeMode);
    // Add any other fields you need to set

    return parseUser;
  }
}
