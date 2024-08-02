import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/providers/auth_provider.dart';
import 'package:client/providers/messages_provider.dart';
import 'package:client/screens/home.dart';
import 'package:client/screens/signin.dart';
import 'package:client/screens/account.dart';
import 'package:client/widgets/message_handler.dart'; // Import MessageHandler

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MessagesProvider()), // Add MessagesProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return ScaffoldMessenger(
          child: Scaffold(
            body: MessageHandler(
              child: child!,
            ),
          ),
        );
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/account': (context) => const AccountScreen(),
        '/sign_up': (context) => const SignInScreen(),
      },
    );
  }
}
