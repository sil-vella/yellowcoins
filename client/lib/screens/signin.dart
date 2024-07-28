import 'package:flutter/material.dart';
import 'package:client/widgets/login.dart';
import 'package:client/widgets/signup.dart';
import 'package:client/widgets/message_handler.dart';

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
    return MessageHandler(
      child: showLogin
          ? LoginWidget(onSignUpClicked: toggleView)
          : SignUpWidget(onLoginClicked: toggleView),
    );
  }
}
