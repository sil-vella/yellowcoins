import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/providers/messages_provider.dart';

class MessagesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MessagesProvider>(
      builder: (context, messagesProvider, child) {
        final message = messagesProvider.message;
        if (message.isNotEmpty) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                duration: Duration(seconds: 3),
              ),
            ).closed.then((_) {
              messagesProvider.clearMessage();
            });
          });
        }
        return Column(
          children: [
            Text('Message:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (message.isNotEmpty) Text(message),
          ],
        );
      },
    );
  }
}
