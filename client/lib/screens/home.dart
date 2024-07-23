// File: lib/screens/home.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';
import 'package:client/services/admob/rewarded_ad_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RewardedAdManager _rewardedAdManager = RewardedAdManager();
  String _rewardMessage = '';

  @override
  void initState() {
    super.initState();

    // Keep the screen awake
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);

    _rewardedAdManager.loadAd();
  }

  @override
  void dispose() {
    _rewardedAdManager.dispose();
    // Allow the screen to turn off
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    super.dispose();
  }

  void _handleUserEarnedReward(RewardItem reward) {
    setState(() {
      _rewardMessage = 'User earned reward: ${reward.amount} ${reward.type}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AdMob Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _rewardedAdManager.showAd(_handleUserEarnedReward);
              },
              child: const Text('Show Rewarded Ad'),
            ),
            const SizedBox(height: 20),
            Text(_rewardMessage, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
