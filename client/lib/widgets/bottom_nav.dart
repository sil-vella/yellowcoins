// File: lib/widgets/bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/providers/auth_provider.dart';
import 'package:client/screens/home.dart';
import 'package:client/screens/account.dart';
import 'package:client/screens/signin.dart';

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SignInScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    bool isAuthenticated = authProvider.isAuthenticated;

    Widget selectedWidget;
    if (_selectedIndex == 1 && !isAuthenticated) {
      selectedWidget = SignInScreen();
    } else if (_selectedIndex == 1 && isAuthenticated) {
      selectedWidget = AccountScreen();
    } else {
      selectedWidget = _widgetOptions.elementAt(_selectedIndex);
    }

    return Column(
      children: [
        Expanded(child: selectedWidget),
        BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ],
    );
  }
}
