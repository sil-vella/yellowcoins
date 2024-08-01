import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:client/providers/auth_provider.dart';

class RewardedAdManager {
  RewardedAd? _rewardedAd;
  final String adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  /// Loads a rewarded ad.
  Future<void> loadAd() async {
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              loadAd(); // Load a new ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              loadAd(); // Load a new ad
            },
          );
          print('RewardedAd loaded.');
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  /// Shows the rewarded ad.
  void showAd(Function(RewardItem) onUserEarnedReward) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onUserEarnedReward(reward);
          _logAdView(reward);
        },
      );
      _rewardedAd = null; // Reset the ad reference after showing
    } else {
      print('Rewarded ad is not ready yet.');
    }
  }

  /// Logs the ad view to the backend
  void _logAdView(RewardItem reward) async {
    // Assuming you have access to the AuthProvider to get the userId
    final userId = AuthProvider().userId;
    if (userId == null) {
      print('User not logged in, cannot log ad view.');
      return;
    }

    final response = await http.post(
      Uri.parse('http://your-server-address/api/log-ad-view'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'adType': 'rewarded',
        'rewardAmount': reward.amount,
        'rewardType': reward.type,
      }),
    );

    if (response.statusCode != 200) {
      print('Failed to log ad view');
    }
  }

  /// Disposes the rewarded ad.
  void dispose() {
    _rewardedAd?.dispose();
  }
}
