// File: lib/screens/home.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client/widgets/admob.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/bloc/bloc/auth_bloc.dart';
import 'package:client/bloc/bloc_state/auth_state.dart';
import 'package:client/screens/account.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Keep the screen awake
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);
  }

  @override
  void dispose() {
    // Allow the screen to turn off
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    super.dispose();
  }

  void _navigateToAccount(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Welcome to our app! Here is how you can use it:\n\n'
                '1. Log in or sign up to your account.\n'
                '2. Once logged in, you can watch ads to earn rewards.\n'
                '3. Connect your PayPal account to receive payments.\n\n'
                'Enjoy!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return const AdMobWidget(); // Show AdMobWidget if user is authenticated
                } else {
                  return ElevatedButton(
                    onPressed: () => _navigateToAccount(context),
                    child: const Text('Sign In'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
