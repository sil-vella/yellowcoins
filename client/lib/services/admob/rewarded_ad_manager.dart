import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

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
        },
      );
      _rewardedAd = null; // Reset the ad reference after showing
    } else {
      print('Rewarded ad is not ready yet.');
    }
  }

  /// Disposes the rewarded ad.
  void dispose() {
    _rewardedAd?.dispose();
  }
}
