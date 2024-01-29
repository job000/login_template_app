// ignore_for_file: unused_local_variable, unused_import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/services/database_service.dart';
import 'login_screen.dart';



class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Add controllers for text fields
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Clean up controllers when disposing
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

// Assuming you have an instance of DatabaseHelper
  DatabaseHelper dbHelper = DatabaseHelper();

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      var response = await dbHelper.registerUser(
        _usernameController.text,
        _passwordController.text,
        _emailController.text,
      );

      setState(() => _isLoading = false);

      if (response.success) {
        _showDialog('User successfully registered!');
      } else {
        _showDialog(response.error?.message ?? 'Failed to register user.');
      }
    }
  }

  void _showDialog(String message) {
    if (!_isLoading) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(message.contains('successfully') ? 'Success' : 'Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _usernameController.clear();
                  _emailController.clear();
                  _passwordController.clear();
                  _confirmPasswordController.clear();
                  /*Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                   
                    );*/
                  // If the user registered successfully, navigate to login screen
                  if (message.contains('successfully')) {
                    // Use pushReplacementNamed to avoid going back to registration screen
                    Navigator.pushReplacementNamed(context, '/');
                  }
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get device width and height
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Theme.of(context).primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () =>
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Left side of the split screen
                Container(
                  width: deviceWidth / 2,
                  color: Theme.of(context).colorScheme.secondary,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Welcome!",
                          style: TextStyle(
                              fontSize: 44, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "You are where you find the best you are looking for!",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(height: 40),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text('Login',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right side of the split screen
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              controller: _usernameController,
                              decoration:
                                  const InputDecoration(labelText: 'Username'),
                              validator: (value) =>
                                  value!.isEmpty ? 'Enter username' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration:
                                  const InputDecoration(labelText: 'Email'),
                              validator: (value) =>
                                  value!.isEmpty ? 'Enter email' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration:
                                  const InputDecoration(labelText: 'Password'),
                              obscureText: !_isPasswordVisible,
                              validator: (value) =>
                                  value!.isEmpty ? 'Enter password' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: const InputDecoration(
                                  labelText: 'Confirm Password'),
                              obscureText: !_isPasswordVisible,
                              validator: (value) =>
                                  value != _passwordController.text
                                      ? "Passwords do not match"
                                      : null,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _registerUser,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text("Sign Up"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
