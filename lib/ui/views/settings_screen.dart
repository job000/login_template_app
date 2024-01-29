import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    // Access UserModel from the provider
    final userModel = Provider.of<AuthProvider>(context, listen: false);
    usernameController =
        TextEditingController(text: userModel.currentUser?.username);
    emailController =
        TextEditingController(text: userModel.currentUser?.emailAddress);
    passwordController = TextEditingController(); // Initialized empty
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final currentUser = authProvider.currentUser;

    if (currentUser != null) {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      currentUser.emailAddress = email;

      if (password.isNotEmpty) {
        currentUser.password = password;
      }

      var response = await currentUser.save();
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Settings saved successfully'),
              backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(response.error?.message ?? 'Failed to save settings'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              readOnly: true,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: Provider.of<ThemeProvider>(context).themeMode ==
                  ThemeMode.dark,
              onChanged: (bool value) async {
                final themeProvider =
                    Provider.of<ThemeProvider>(context, listen: false);
                // Use simple string values directly
                final newThemeMode = value ? 'dark' : 'light';

                print('Changing theme mode to $newThemeMode');
                await themeProvider.updateThemeMode(newThemeMode);

                themeProvider.setThemeMode(newThemeMode);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
