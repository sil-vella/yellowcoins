// File: lib/providers/auth_provider.dart

import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  int? _userId;
  String? _email;
  String? _stripeAccountId;
  double _earnings = 0.0;

  bool get isAuthenticated => _isAuthenticated;
  int? get userId => _userId;
  String? get email => _email;
  String? get stripeAccountId => _stripeAccountId;
  double get earnings => _earnings;

  void signIn(Map<String, dynamic> userData) {
    _isAuthenticated = true;
    _userId = userData['userId'];
    _email = userData['email'];
    _stripeAccountId = userData['stripeAccountId'];
    _earnings = userData['earnings'] / 100.0; // Convert from cents to dollars
    print('User signed in, isAuthenticated: $_isAuthenticated, userId: $_userId');
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    _userId = null;
    _email = null;
    _stripeAccountId = null;
    _earnings = 0.0;
    print('User signed out, isAuthenticated: $_isAuthenticated');
    notifyListeners();
  }
}
