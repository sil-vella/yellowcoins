import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  int? _userId;
  String? _email;
  String? _stripeAccountId;
  int _coins = 0; // Coins as integer
  double _earnings = 0.0; // Earnings calculated based on eCPM
  double _ecpmRate = 0.0; // eCPM Rate
  String? _adMobAccountId; // AdMob account ID
  Map<String, String>? _adUnitIds; // Ad unit IDs mapped by ad type
  String? _rewardedAdUnitId; // Rewarded Ad Unit ID

  bool get isAuthenticated => _isAuthenticated;
  int? get userId => _userId;
  String? get email => _email;
  String? get stripeAccountId => _stripeAccountId;
  int get coins => _coins; // Getter for coins
  double get earnings => _earnings; // Getter for earnings
  double get ecpmRate => _ecpmRate; // Getter for eCPM rate
  String? get adMobAccountId => _adMobAccountId;
  Map<String, String>? get adUnitIds => _adUnitIds; // Getter for ad unit IDs
  String? get rewardedAdUnitId {
    print('Accessing rewardedAdUnitId: $_rewardedAdUnitId');
    return _rewardedAdUnitId;
  } // Getter for Rewarded Ad Unit ID

  // Method to get a specific ad unit ID by ad type
  String? getAdUnitId(String adType) {
    print('Accessing ad unit ID for type $adType: ${_adUnitIds?[adType]}');
    return _adUnitIds?[adType];
  }

  void signIn(Map<String, dynamic> userData, Map<String, dynamic> admobConfig) {
    print('Signing in with user data: $userData');
    print('AdMob configuration received: $admobConfig');

    _isAuthenticated = true;
    _userId = userData['userId'];
    _email = userData['email'];
    _stripeAccountId = userData['stripeAccountId'];
    _coins = userData['coins'] ?? 0; // Set coins from userData
    _earnings = userData['earnings']?.toDouble() ?? 0.0; // Set earnings from userData
    _ecpmRate = userData['ecpmRate']?.toDouble() ?? 0.0; // Set eCPM rate from userData

    // Set AdMob configuration from the config data
    _adMobAccountId = admobConfig['accountId'];
    _adUnitIds = Map<String, String>.from(admobConfig['adUnitIds'] ?? {});
    _rewardedAdUnitId = admobConfig['rewardedAdUnitId']; // Set the rewarded ad unit ID

    print('User signed in: '
        'userId=$_userId, '
        'email=$_email, '
        'stripeAccountId=$_stripeAccountId, '
        'coins=$_coins, '
        'earnings=$_earnings, '
        'ecpmRate=$_ecpmRate, ' // Log the eCPM rate
        'adMobAccountId=$_adMobAccountId, '
        'adUnitIds=$_adUnitIds, '
        'rewardedAdUnitId=$_rewardedAdUnitId');

    notifyListeners();
  }

  void signOut() {
    print('Signing out userId=$_userId');

    _isAuthenticated = false;
    _userId = null;
    _email = null;
    _stripeAccountId = null;
    _coins = 0;
    _earnings = 0.0;
    _ecpmRate = 0.0; // Reset eCPM rate
    _adMobAccountId = null;
    _adUnitIds = null;
    _rewardedAdUnitId = null;

    print('User signed out');

    notifyListeners();
  }

  Future<void> _updateCoinsAndEarningsInServer(int coins, double earnings) async {
    if (_userId == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://192.168.178.80:5000/api/users/update-coins-earnings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': _userId,
          'coins': coins,
          'earnings': earnings,
        }),
      );

      if (response.statusCode == 200) {
        print('Coins and earnings successfully updated on the server');
      } else {
        print('Failed to update coins and earnings on the server: ${response.body}');
      }
    } catch (error) {
      print('Error updating coins and earnings on the server: $error');
    }
  }

  void updateCoinsAndEarnings(int coins, double earnings) {
    print('Updating coins to $coins and earnings to $earnings');
    _coins = coins;
    _earnings = earnings;
    print('Coins and earnings updated: $_coins, $_earnings');

    // Update the coins and earnings on the server
    _updateCoinsAndEarningsInServer(_coins, _earnings);

    notifyListeners();
  }
}
