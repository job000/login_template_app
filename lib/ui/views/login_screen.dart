import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import 'dashboard_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();

  
}



class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _obscureText = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
void initState() {
  super.initState();
  _checkCredentials();
}

Future<void> _checkCredentials() async {
  final prefs = await SharedPreferences.getInstance();
  final savedUsername = prefs.getString('username');
  final savedPassword = prefs.getString('password');

  if (savedUsername != null && savedPassword != null) {
    setState(() {
      _username = savedUsername;
      _password = savedPassword;
      _rememberMe = true;
    });
    // Optionally, automatically log in the user
    //_login();
  }
}


void _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    _formKey.currentState!.save();

    final ParseUser user = ParseUser(_username, _password, null);
    var response = await user.login();

   if (response.success) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setUser(user); // Set the user in AuthProvider

        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        themeProvider.setUserModel(authProvider); // Update ThemeProvider with the new AuthProvider
        await themeProvider.fetchThemeMode(); // Fetch the theme mode


      // Save credentials if 'Remember Me' is checked
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', _username);
        await prefs.setString('password', _password);
      }

    

      setState(() {
        _isLoading = false;
      });

      // Navigate to the Dashboard Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      // Error handling
      setState(() {
        _isLoading = false;
      });
      String errorMessage = 'Login failed';
      if (response.error != null) {
        errorMessage = response.error!.message;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}




  @override
  Widget build(BuildContext context) {
    const double maxCardWidth = 600.0;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxCardWidth),
                  child: GestureDetector(
                    onTap: () {
                      // Dismiss the keyboard when tapped outside of the text fields
                      FocusScope.of(context).unfocus();
                    },
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Image.asset('assets/images/uipath-2.png',
                              height: 160),
                          const SizedBox(height: 30),
                          Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 24,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.color),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'You are logging in on organization "Default"',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color),
                          ),
                          const SizedBox(height: 30),
                          Card(
                            color: Theme.of(context).cardColor,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Username or email',
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      ),
                                    ),
                                    onSaved: (value) => _username = value!,
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'Please enter your username'
                                            : null,
                                    onFieldSubmitted: (_) {
                                      _login();
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureText
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                      ),
                                    ),
                                    obscureText: _obscureText,
                                    onSaved: (value) => _password = value!,
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'Please enter your password'
                                            : null,
                                    onFieldSubmitted: (_) {
                                      _login();
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Checkbox(
                                            value: _rememberMe,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                _rememberMe = value ?? false;
                                              });
                                            },
                                          ),
                                          Text(
                                            'Remember me',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Forgot your password?',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[300],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Log in',
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Divider(
                                      color: Theme.of(context).dividerColor),
                                  SizedBox(height: 20),
                                  InkWell(
                                    child: Image.asset(
                                        'assets/images/uipath-2.png',
                                        height: 60),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RegistrationScreen()),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RegistrationScreen()),
                                      );
                                    },
                                    child: Text(
                                      'Register',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.color),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          DropdownButton<String>(
                            value: 'English',
                            items: <String>['English', 'Español', 'Français']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.color,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (_) {},
                            dropdownColor: Theme.of(context).cardColor,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Terms and Conditions',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
