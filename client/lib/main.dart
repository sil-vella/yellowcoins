import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/widgets/common_layout.dart';
import 'package:client/providers/auth_provider.dart';
import 'package:client/providers/messages_provider.dart';
import 'package:client/screens/home.dart';
import 'package:client/screens/signin.dart';
import 'package:client/screens/account.dart';

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
            body: Consumer<MessagesProvider>(
              builder: (context, messagesProvider, _) {
                final message = messagesProvider.message;
                print('Current message in MyApp: $message'); // Debug statement

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
                return child!;
              },
              child: child,
            ),
          ),
        );
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => CommonLayout(child: const HomeScreen(), title: 'Home'),
        '/home': (context) => CommonLayout(child: const HomeScreen(), title: 'Home'),
        '/account': (context) => CommonLayout(child: const AccountScreen(), title: 'Account'),
        '/sign_up': (context) => CommonLayout(child: const SignInScreen(), title: 'Sign Up'),
      },
    );
  }
}
