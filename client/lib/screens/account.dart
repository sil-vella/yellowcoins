import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:client/providers/messages_provider.dart';
import 'package:client/providers/auth_provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _loginLinkUrl = '';
  String _accountLinkUrl = '';

  Future<void> _getLoginLink() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messagesProvider = Provider.of<MessagesProvider>(context, listen: false);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.178.80:5000/api/account/create-login-link'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': authProvider.userId}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _loginLinkUrl = responseData['loginLinkUrl'];
        });
        messagesProvider.setMessage('Login link generated successfully');
      } else if (response.statusCode == 400 && responseData['accountLinkUrl'] != null) {
        setState(() {
          _accountLinkUrl = responseData['accountLinkUrl'];
        });
        messagesProvider.setMessage('Please complete the onboarding process.');
      } else {
        messagesProvider.setMessage(responseData['error'] ?? 'Failed to generate login link');
      }
    } catch (error) {
      messagesProvider.setMessage('Error: $error');
    }
  }

  void _openLoginLink() async {
    final Uri url = Uri.parse(_loginLinkUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('Could not launch $_loginLinkUrl');
    }
  }

  void _openAccountLink() async {
    final Uri url = Uri.parse(_accountLinkUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('Could not launch $_accountLinkUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Email: ${authProvider.email}', style: TextStyle(fontSize: 20)),
        Text('Earnings: \$${authProvider.earnings.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _getLoginLink,
          child: Text('Get Stripe Login Link'),
        ),
        SizedBox(height: 20),
        if (_loginLinkUrl.isNotEmpty)
          ElevatedButton(
            onPressed: _openLoginLink,
            child: Text('Open Stripe Login Link'),
          ),
        if (_accountLinkUrl.isNotEmpty)
          ElevatedButton(
            onPressed: _openAccountLink,
            child: Text('Complete Stripe Onboarding'),
          ),
      ],
    );
  }
}
