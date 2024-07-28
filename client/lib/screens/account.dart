import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/providers/auth_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Account Screen'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              print('User logged out'); // Debug statement
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
