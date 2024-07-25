import 'package:flutter/material.dart';
import 'package:client/widgets/login.dart'; // Adjust the import path as needed
import 'package:client/widgets/signup.dart'; // Adjust the import path as needed

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
    return showLogin ? LoginWidget(onSignUpClicked: toggleView) : SignUpWidget(onLoginClicked: toggleView);
  }
}
