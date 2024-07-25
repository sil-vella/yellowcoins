// File: lib/screens/signin.dart
import 'package:flutter/material.dart';
import 'package:client/widgets/login.dart';
import 'package:client/widgets/signup.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool showLogin = true;

  void toggleView() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: showLogin
          ? LoginWidget(onSignUpClicked: toggleView)
          : SignUpWidget(onLoginClicked: toggleView),
    );
  }
}
