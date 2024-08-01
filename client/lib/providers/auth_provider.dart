import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  int? _userId;

  bool get isAuthenticated => _isAuthenticated;
  int? get userId => _userId;

  void signIn(String email, String password, int userId) {
    _isAuthenticated = true;
    _userId = userId;
    print('User signed in, isAuthenticated: $_isAuthenticated, userId: $_userId');
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    _userId = null;
    print('User signed out, isAuthenticated: $_isAuthenticated, userId: $_userId');
    notifyListeners();
  }
}
