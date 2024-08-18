import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/widgets/admob.dart';  // Import the AdMobWidget
import 'package:client/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Navigation',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Account'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/account');
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Sign Up'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/sign_up');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: AdMobWidget(),  // Use AdMobWidget here
      ),
    );
  }
}
