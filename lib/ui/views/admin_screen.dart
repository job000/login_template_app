// ignore_for_file: unused_local_variable, use_build_context_synchronously, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<ParseUser> users = [];
  Map<ParseUser, bool> selectedUsers = {};
  List<String> availableRoles = ['user', 'admin', 'editor', 'viewer'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    final ParseResponse response = await ParseUser.all();
    if (response.success && response.results != null) {
      setState(() {
        users = response.results as List<ParseUser>;
        selectedUsers = {for (var user in users) user: false};
      });
    }
  }



  void _showEditUserDialog(ParseUser user) async {
    final _formKey = GlobalKey<FormState>();
    TextEditingController emailController = TextEditingController(text: user.get<String>('email'));
    TextEditingController passwordController = TextEditingController(); // Empty for security
    TextEditingController usernameController = TextEditingController(text: user.username);
    String? selectedRole;
    DateTime? timeAdded, timeUpdated;

    // Fetch the User's roles
    QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('_Role'))
      ..whereRelatedTo('users', '_Role', user.objectId!);
    var roleResponse = await query.query();

    if (roleResponse.success && roleResponse.results != null) {
      // For simplicity, we're assuming each user has only one role
      selectedRole = (roleResponse.results!.first as ParseObject).get<String>('name');
    }

 await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.7, // Set minimum width
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) => value!.isEmpty ? 'Email cannot be empty' : null,
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'New Password (leave empty if unchanged)'),
                      obscureText: true,
                    ),
                    DropdownButtonFormField(
                      value: selectedRole,
                      items: availableRoles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        selectedRole = newValue;
                      },
                      decoration: const InputDecoration(labelText: 'Role'),
                    ),
                    // Display additional attributes such as timeAdded and timeUpdated here
                    // ...
                  ],
                ),
              ),
            ),
          ),
          actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () async {
              await user.destroy();
              Navigator.of(context).pop();
              _loadUsers(); // Refresh the list after deletion
            },
          ),
           TextButton(
                child: const Text('Save'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    bool shouldUpdateRole = user.get<String>('role') != selectedRole;

                    // Update the ParseUser fields
                    user.emailAddress = emailController.text;
                    if (passwordController.text.trim().isNotEmpty) {
                      user.password = passwordController.text.trim();
                    }

                    // Attempt to save the user
                    final ParseResponse saveResponse = await user.save();
                    if (saveResponse.success) {
                      // Update the role if a new one was selected
                      if (shouldUpdateRole && selectedRole != null) {
                        await _updateUserRole(user, selectedRole!);
                      }
                      Navigator.of(context).pop();
                      _loadUsers(); // Refresh the users list
                    } else {
                      _showError(saveResponse.error);
                    }
                  }
                },
              ),
            
          ],
        );
      },
    );
  }


void _deleteSelectedUsers() async {
  for (var user in selectedUsers.entries) {
    if (user.value) {
      await user.key.destroy();
    }
  }
  _loadUsers(); // Refresh the list after deletion
}

 Future<void> _updateUserRole(ParseUser user, String roleName) async {
    final ParseCloudFunction function = ParseCloudFunction('updateUserRole');
    final Map<String, dynamic> params = <String, String>{
      'userId': user.objectId!,
      'roleName': roleName,
    };
    final ParseResponse result = await function.execute(parameters: params);

    if (!result.success) {
      _showError(result.error);
    }
  }

  void _showError(ParseError? error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error?.message ?? 'An error occurred'),
        backgroundColor: Colors.red,
      ),
    );
  }
@override
Widget build(BuildContext context) {
  bool isAnyUserSelected = selectedUsers.values.any((isSelected) => isSelected);
  return Scaffold(
    appBar: AppBar(
      title: const Text('Admin Panel'),
      backgroundColor: Colors.blueGrey,
      actions: isAnyUserSelected ? [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _deleteSelectedUsers,
        ),
      ] : [],
    ),
    body: ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(8),
          child: Row(
            children: [
              Checkbox(
                value: selectedUsers[user] ?? false,
                onChanged: (bool? value) {
                  setState(() {
                    selectedUsers[user] = value!;
                  });
                },
              ),
              Expanded(
                child: ListTile(
                  onTap: () => _showEditUserDialog(user),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Text(user.get<String>('firstname')?.substring(0, 1) ?? 'N'),
                  ),
                  title: Text(user.get<String>('username') ?? 'Unknown user', 
                           style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Username: ${user.username}'),
                      Text('Email: ${user.get<String>('email') ?? 'No email'}'),
                      Text('Role: ${user.get<String>('role') ?? 'No role'}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
}