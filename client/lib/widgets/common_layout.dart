import 'package:flutter/material.dart';
import 'package:client/widgets/bottom_nav.dart';

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
      body: child,
      bottomNavigationBar: BottomNav(), // Added BottomNavScreen here
    );
  }
}
