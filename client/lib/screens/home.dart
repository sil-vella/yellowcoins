import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/providers/messages_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Provider.of<MessagesProvider>(context, listen: false).setMessage('Test message');
        },
        child: const Text('Show Message'),
      ),
    );
  }
}
