import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:client/providers/messages_provider.dart';

class SignUpWidget extends StatefulWidget {
  final VoidCallback onLoginClicked;

  const SignUpWidget({required this.onLoginClicked, super.key});

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _paypalAccountController = TextEditingController();

  Future<void> _signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final name = _nameController.text;
    final paypalAccount = _paypalAccountController.text;
    final messagesProvider = Provider.of<MessagesProvider>(context, listen: false);

    final response = await http.post(
      Uri.parse('http://192.168.178.80:5000/api/signup'),  // Use your local machine's IP address
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'name': name,
        'paypalAccount': paypalAccount,
      }),
    );

    if (response.statusCode == 201) {
      messagesProvider.setMessage('Account created successfully. Please login.');
      widget.onLoginClicked();  // Navigate to the login screen
    } else {
      final responseData = json.decode(response.body);
      messagesProvider.setMessage(responseData['error'] ?? 'Failed to create account');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
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
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name (optional)'),
            ),
            TextField(
              controller: _paypalAccountController,
              decoration: const InputDecoration(labelText: 'PayPal Account (optional)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: widget.onLoginClicked,
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _paypalAccountController.dispose();
    super.dispose();
  }
}
