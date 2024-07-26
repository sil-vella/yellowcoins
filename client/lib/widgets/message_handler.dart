import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/providers/messages_provider.dart';

class MessageHandler extends StatelessWidget {
  final Widget child;

  const MessageHandler({required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<MessagesProvider>(
      builder: (context, messagesProvider, _) {
        final message = messagesProvider.message;
        print('Current message in MessageHandler: $message'); // Debug statement

        if (message.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('Executing Snackbar logic for message: $message'); // Debug statement
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            scaffoldMessenger.hideCurrentSnackBar(); // Ensure no other Snackbars are shown
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(message),
                duration: Duration(seconds: 3),
              ),
            ).closed.then((_) {
              messagesProvider.clearMessage();
              print('Snackbar closed, message cleared'); // Debug statement
            });
          });
        }
        return child;
      },
    );
  }
}
