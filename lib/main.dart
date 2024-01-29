
// ignore_for_file: unused_import, unused_local_variable

import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/message_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/database_service.dart';
import 'ui/views/admin_screen.dart';
import 'ui/views/dashboard_screen.dart';
import 'ui/views/login_screen.dart';
import 'ui/views/registration_screen.dart';
import 'ui/views/settings_screen.dart';
import 'package:flutter/material.dart';



void main() async {
  // Initialize Parse
  final DatabaseHelper databaseHelper = DatabaseHelper();
  await databaseHelper.initializeParse();
 AuthProvider authProvider = AuthProvider();
  ThemeProvider themeNotifier = ThemeProvider(authProvider);
  MessageProvider messageNotifier = MessageProvider();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(authProvider)),
        // Add other providers as needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Buddy Action Center',
          theme: ThemeData.light().copyWith(
            primaryColor: Colors.blue, // Change the primary color to Blue for light mode
            hintColor: Colors.amber,
            textTheme: const TextTheme(
              titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold), // Use headline6 instead of titleLarge
              bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'), // Use bodyText2 instead of bodyMedium
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.grey[900], // Change the primary color to grey[900] for dark mode
          ),
          themeMode: themeNotifier.themeMode,
          routes: {
            '/': (context) => const LoginScreen(), // Set LoginScreen as the root
            '/registration': (context) => const RegistrationScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/admin': (context) => const AdminScreen(),
            '/settings': (context) => const SettingsScreen(),


          },
          initialRoute: '/', // Set the initial route
         // Start with LoginScreen
        );
      },
    );
  }
}
