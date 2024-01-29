// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import 'admin_screen.dart';
import 'login_screen.dart';
import 'message_screen.dart';
import 'settings_screen.dart';
import 'user_task_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});



  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final ParseUser? user = authProvider.currentUser;
    final bool isAdmin = authProvider.isAdmin;
    print("isAdmin: " + isAdmin.toString());

Future<String?> getUserProfileImage(BuildContext context) async {
  // Retrieve the profile picture as a dynamic type to avoid type casting errors
  var profilePicture = authProvider.currentUser?.get<dynamic>('profilePicture');
  
  if (profilePicture != null) {
    // Check if the profile picture is a web file and handle accordingly
    if (profilePicture is ParseWebFile) {
      return profilePicture.url;
    } else if (profilePicture is ParseFile) {
      return profilePicture.url;
    }
  }
  return null;
}


    Widget createDrawerHeader(BuildContext context) {
      return DrawerHeader(
        decoration: const BoxDecoration(color: Colors.blue),
        child: Column(
          children: [
            FutureBuilder<String?>(
              future: getUserProfileImage(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(snapshot.data!),
                    backgroundColor: Colors.transparent,
                  );
                } else {
                  return CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.person, size: 50),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            Text(
              user?.username ?? 'No Username',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    Widget createDrawerItem({
      required String title,
      required IconData icon,
      required String routeName,
      VoidCallback? onTap,
    }) {
      final bool isCurrentPage =
          ModalRoute.of(context)?.settings.name == routeName;

      return ListTile(
        leading: Icon(icon, color: isCurrentPage ? Colors.blue : null),
        title: Text(title,
            style: TextStyle(color: isCurrentPage ? Colors.blue : null)),
        tileColor: isCurrentPage
            ? Colors.grey[300]
            : null, // Highlight if current page
        onTap: isCurrentPage ? null : onTap, // Disable onTap if current page
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MessagesScreen()),
          );
        },
        child: const Icon(Icons.message),
        // Add logic to display the number of unread messages
      ),
      appBar: AppBar(
        title: Text(isAdmin ? 'Dashboard - Administrator' : 'Dashboard'),
        actions: <Widget>[
          
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            createDrawerHeader(context),
            createDrawerItem(
              title: 'Dashboard',
              icon: Icons.dashboard,
              routeName: '/',
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            if (isAdmin)
              createDrawerItem(
                title: 'Admin',
                icon: Icons.admin_panel_settings,
                routeName: '/admin',
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminScreen()),
                  );
                },
              ),
            /*
            createDrawerItem(
              title: 'Task List',
              icon: Icons.list,
              routeName: '/tasklist',
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TaskListScreen(userRole: "admin")),
                );
              },
            ),
            */
            createDrawerItem(
              title: 'Task List',
              icon: Icons.list,
              routeName: '/tasklist',
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserTasksScreen()),
                );
              },
            ),
            createDrawerItem(
              title: 'Messages',
              icon: Icons.message,
              routeName: '/messages',
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MessagesScreen()),
                );
              },
            ),
            createDrawerItem(
              title: 'Settings',
              icon: Icons.settings,
              routeName: '/settings',
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingsScreen()),
                );
              },
            ),
            const Divider(),
            createDrawerItem(
              title: 'Logout',
              icon: Icons.logout,
              routeName: '/logout',
              onTap: () async {
                // Call the logout method from the UserModel
                
                await authProvider.logout();
                Navigator.pop(context); // Close the drawer
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('View Tasks'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserTasksScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
