import 'dart:io';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../core/models/message_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/providers/auth_provider.dart';
import '../../core/providers/message_provider.dart';

class NewMessageScreen extends StatefulWidget {
  final Message? replyTo;

  const NewMessageScreen({Key? key, this.replyTo}) : super(key: key);

  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  bool _isEmojiPickerVisible = false;
  AuthProvider? authProvider;
  MessageProvider? messageProvider;


  @override
  void initState() {
    super.initState();
    if (widget.replyTo != null) {
      _messageController.text = 'Re: ${widget.replyTo!.messageText}';
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      messageProvider = Provider.of<MessageProvider>(context, listen: false);
    }
  }

   void _sendMessage() async {
    if (_messageController.text.isNotEmpty && !_isSending) {
      setState(() => _isSending = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final messageProvider = Provider.of<MessageProvider>(context, listen: false);

      var currentUser = authProvider.currentUser;
      var toUser = widget.replyTo?.fromUser ?? messageProvider.selectedUserForMessaging;

      if (currentUser == null || toUser == null) {
        _showErrorDialog('User information is not set.');
        setState(() => _isSending = false);
        return;
      }

      var message = ParseObject('Message')
        ..set('messageText', _messageController.text)
        ..set('fromUser', ParseUser.forQuery()..objectId = currentUser.objectId)
        ..set('toUser', ParseUser.forQuery()..objectId = toUser.objectId);

      try {
        final response = await message.save().timeout(Duration(seconds: 10));
        if (response.success) {
          messageProvider.addSentMessage(Message.fromParse(response.result));
          Navigator.of(context).pop();
        } else {
          _showErrorDialog(response.error?.message ?? 'Failed to send message');
        }
      } catch (e) {
        _showErrorDialog('An error occurred: $e');
      } finally {
        if (mounted) {
          setState(() => _isSending = false);
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleEmojiPicker() {
    setState(() {
      _isEmojiPickerVisible = !_isEmojiPickerVisible;
    });
  }

Widget _buildEmojiPicker() {
  // Determine if the theme is dark or light
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  // Set colors based on the theme
  Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
  Color iconColor = isDarkMode ? Colors.white : Colors.black87;
  Color iconSelectedColor = Theme.of(context).colorScheme.primary;

  return Container(
    height: 220, // Reduced height for a more compact design
    decoration: BoxDecoration(
      color: backgroundColor,
      border: Border(
        top: BorderSide(color: iconColor.withOpacity(0.2)),
      ),
    ),
    child: EmojiPicker(
      onEmojiSelected: (Category? category, Emoji emoji) {
        setState(() {
          _messageController.text += emoji.emoji;
        });
      },
      config: Config(
        columns: 7,
        emojiSizeMax: 32 * (!kIsWeb && Platform.isIOS ? 1.30 : 1.0),
        verticalSpacing: 0,
        horizontalSpacing: 0,
        gridPadding: EdgeInsets.zero,
        initCategory: Category.RECENT,
        bgColor: backgroundColor,
        indicatorColor: iconSelectedColor,
        iconColor: iconColor,
        iconColorSelected: iconSelectedColor,
        backspaceColor: iconSelectedColor,
        skinToneDialogBgColor: backgroundColor,
        skinToneIndicatorColor: iconColor,
        enableSkinTones: true,
        categoryIcons: CategoryIcons(),
        buttonMode: ButtonMode.MATERIAL,
      ),
    ),
  );
}



@override
Widget build(BuildContext context) {

  var toUser = widget.replyTo?.fromUser ?? messageProvider?.selectedUserForMessaging;
  ThemeData theme = Theme.of(context);
  ColorScheme colorScheme = theme.colorScheme;

  return Scaffold(
    appBar: AppBar(
      title: Text('Message to ${toUser?.get<String>('username') ?? 'User'}'),
      backgroundColor: colorScheme.primary,
    ),
    body: GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          _isEmojiPickerVisible = false;
        });
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              'Compose New Message',
              style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Type your message here',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.emoji_emotions_outlined),
                  onPressed: _toggleEmojiPicker,
                ),
              ),
              minLines: 3,
              maxLines: 5,
            ),
            _isEmojiPickerVisible ? _buildEmojiPicker() : Container(), // Emoji picker wrapped in Flexible
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sendMessage,
                    child: _isSending
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Send'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colorScheme.onPrimary, backgroundColor: colorScheme.primary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary, minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    ),);
  }
}
