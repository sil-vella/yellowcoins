import 'package:flutter/material.dart';
import 'package:client/widgets/bottom_nav.dart';
import 'package:client/widgets/messages_widget.dart'; // Import MessagesWidget

class CommonLayout extends StatelessWidget {
  final Widget child;
  final String title;

  CommonLayout({required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Stack(
        children: [
          child,
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: MessagesWidget(), // Add MessagesWidget to listen for messages
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(), // Added BottomNavScreen here
    );
  }
}
