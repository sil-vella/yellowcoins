// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:client/widgets/common_layout.dart';
import 'package:client/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CommonLayout(child: HomeScreen()),
    );
  }
}
