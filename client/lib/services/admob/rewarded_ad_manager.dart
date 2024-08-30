import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:client/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:client/providers/messages_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RewardedAdManager {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'No Base URL';
  RewardedAd? _rewardedAd;
  late final String adUnitId;
  final BuildContext context;

  RewardedAdManager(this.context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    adUnitId = authProvider.rewardedAdUnitId ?? ''; // Fetch the ad unit ID dynamically
    print('RewardedAdManager initialized with adUnitId: $adUnitId');
    if (adUnitId.isEmpty) {
      print('Ad unit ID is not available');
    }
  }

  Future<void> loadAd() async {
    if (adUnitId.isEmpty) {
      print('No valid ad unit ID available.');
      return;
    }

    final messagesProvider = Provider.of<MessagesProvider>(context, listen: false);
    print('Attempting to load ad with adUnitId: $adUnitId');

    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('RewardedAd loaded successfully');
          _rewardedAd = ad;
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              print('Ad dismissed');
              ad.dispose();
              loadAd(); // Load a new ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('Failed to show ad: $error');
              ad.dispose();
              messagesProvider.setMessage('Ad failed to show: $error');
              loadAd(); // Load a new ad
            },
          );
          messagesProvider.setMessage('RewardedAd loaded.');
        },
        onAdFailedToLoad: (error) {
          print('Failed to load RewardedAd: $error');
          messagesProvider.setMessage('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void showAd(BuildContext context, Function(RewardItem) onUserEarnedReward) {
    final messagesProvider = Provider.of<MessagesProvider>(context, listen: false);
    print('Attempting to show ad');

    if (_rewardedAd != null) {
      print('Showing ad...');
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('User earned reward: ${reward.amount} ${reward.type}');
          onUserEarnedReward(reward);
          _updateCoinsAndEarnings(context, reward.amount.toInt()); // Update coins and earnings
          messagesProvider.setMessage('User earned reward: ${reward.amount} ${reward.type}');
        },
      );
      _rewardedAd = null;
    } else {
      print('Ad is not ready yet.');
      messagesProvider.setMessage('Ad is not ready yet.');
    }
  }

  void _updateCoinsAndEarnings(BuildContext context, int rewardAmount) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;
    final currentCoins = authProvider.coins;
    final ecpmRate = authProvider.ecpmRate;
    final newCoins = currentCoins + rewardAmount;
    final earnings = (rewardAmount * ecpmRate) / 1000;
    final newEarnings = authProvider.earnings + earnings;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/account/update-coins-earnings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'coins': newCoins,
          'earnings': newEarnings,
        }),
      );

      if (response.statusCode == 200) {
        print('Coins and earnings updated successfully on the server');
        authProvider.updateCoinsAndEarnings(newCoins, newEarnings);
      } else {
        print('Failed to update coins and earnings on the server: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred while updating coins and earnings: $e');
    }
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}
