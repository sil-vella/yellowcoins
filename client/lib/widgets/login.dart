// File: lib/widgets/login.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:client/providers/auth_provider.dart';
import 'package:client/providers/messages_provider.dart';

class LoginWidget extends StatefulWidget {
  final VoidCallback onSignUpClicked;

  const LoginWidget({required this.onSignUpClicked, super.key});

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final messagesProvider = Provider.of<MessagesProvider>(context, listen: false);

    try {
      print('Sending login request for email: $email');

      final response = await http.post(
        Uri.parse('http://192.168.178.80:5000/api/users/login'), // Ensure this matches your backend route
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Received response with status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Login successful, userId: ${responseData['userId']}');
        Provider.of<AuthProvider>(context, listen: false).signIn(responseData);
        messagesProvider.setMessage('Login successful');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final responseData = jsonDecode(response.body);
        print('Login failed, error: ${responseData['error']}');
        messagesProvider.setMessage(responseData['error'] ?? 'Login failed');
      }
    } catch (error) {
      print('Login error: $error');
      messagesProvider.setMessage('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _login,
            child: const Text('Login'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onSignUpClicked,
            child: const Text("Don't have an account? Sign up"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
