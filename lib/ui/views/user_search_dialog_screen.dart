import 'dart:async';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';

import '../../core/providers/message_provider.dart';

class UserSearchDialog extends StatefulWidget {
  const UserSearchDialog({Key? key}) : super(key: key);

  @override
  _UserSearchDialogState createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<UserSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<ParseUser> searchResults = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchUsers(_searchController.text.trim());
    });
  }

  void _searchUsers(String searchTerm) async {
    if (searchTerm.isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    final ParseCloudFunction function = ParseCloudFunction('searchUsers');
    final ParseResponse response =
        await function.execute(parameters: {'searchTerm': searchTerm});

    if (response.success && response.result != null) {
      setState(() {
        searchResults = (response.result as List).map((user) {
          return ParseUser.forQuery()
            ..objectId = user['objectId']
            ..set('username', user['username'])
            ..set('email', user['email']);
        }).toList();
      });
    } else {
      // Handle error or no results
      setState(() => searchResults = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search Users'),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Enter username, email, or name',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) => _searchUsers(value),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final user = searchResults[index];
                  return ListTile(
                    title: Text(user.get<String>('username')!),
                    onTap: () {
                      Provider.of<MessageProvider>(context, listen: false)
                          .setSelectedUserForMessaging(user);
                      Navigator.of(context).pop(user);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
