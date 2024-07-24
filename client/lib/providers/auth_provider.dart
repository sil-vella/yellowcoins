// File: lib/providers/auth_provider.dart
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void signIn(String email, String password) {
    // Add your authentication logic here
    // For now, we'll just set _isAuthenticated to true
    _isAuthenticated = true;
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
