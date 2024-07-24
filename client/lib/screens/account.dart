// File: lib/screens/account.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/providers/auth_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final email = emailController.text;
                final password = passwordController.text;
                authProvider.signIn(email, password);
                Navigator.pop(context);
              },
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to sign-up screen or add sign-up logic here
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
