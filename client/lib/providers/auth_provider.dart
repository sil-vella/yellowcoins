// File: lib/providers/auth_provider.dart
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void signIn(String email, String password) {
    // Add your authentication logic here
    _isAuthenticated = true;
    print('User signed in, isAuthenticated: $_isAuthenticated');
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    print('User signed out, isAuthenticated: $_isAuthenticated');
    notifyListeners();
  }
}
