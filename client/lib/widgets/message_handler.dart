import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/providers/messages_provider.dart';

class MessageHandler extends StatelessWidget {
  final Widget child;

  const MessageHandler({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MessagesProvider>(
      builder: (context, messagesProvider, _) {
        final message = messagesProvider.message;
        print('Current message in MessageHandler: $message');

        if (message.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('Executing Snackbar logic for message: $message');
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            scaffoldMessenger.hideCurrentSnackBar();
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(message),
                duration: Duration(seconds: 3),
              ),
            ).closed.then((_) {
              messagesProvider.clearMessage();
              print('Snackbar closed, message cleared');
            });
          });
        }
        return child;
      },
    );
  }
}
