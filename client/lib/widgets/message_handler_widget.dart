import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/providers/messages_provider.dart';

class MessageHandlerWidget extends StatelessWidget {
  final Widget child;

  const MessageHandlerWidget({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Consumer<MessagesProvider>(
        builder: (context, messagesProvider, _) {
          final message = messagesProvider.message;
          print('Current message in MessageHandlerWidget: $message'); // Debug statement

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
      ),
    );
  }
}
