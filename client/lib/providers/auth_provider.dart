import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  int? _userId;
  String? _email;
  String? _stripeAccountId;
  int _coins = 0; // Coins as integer
  double _ecpmRate = 0.0; // eCPM rate as double

  bool get isAuthenticated => _isAuthenticated;
  int? get userId => _userId;
  String? get email => _email;
  String? get stripeAccountId => _stripeAccountId;
  int get coins => _coins; // Getter for coins
  double get ecpmRate => _ecpmRate; // Getter for eCPM rate
  double get earnings => (_coins * _ecpmRate) / 1000; // Calculate earnings

  void signIn(Map<String, dynamic> userData) {
    _isAuthenticated = true;
    _userId = userData['userId'];
    _email = userData['email'];
    _stripeAccountId = userData['stripeAccountId'];
    _coins = userData['coins'] ?? 0; // Set coins from userData
    _ecpmRate = userData['ecpmRate']?.toDouble() ?? 0.0; // Set eCPM rate from userData
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    _userId = null;
    _email = null;
    _stripeAccountId = null;
    _coins = 0;
    _ecpmRate = 0.0;
    notifyListeners();
  }

  void incrementCoins(int amount) {
    _coins += amount;
    notifyListeners();
  }

  void updateCoins(int coins) {
    _coins = coins;
    notifyListeners();
  }
}
