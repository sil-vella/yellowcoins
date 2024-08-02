// File: lib/widgets/admob_widget.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:client/services/admob/rewarded_ad_manager.dart';
import 'package:client/providers/auth_provider.dart';

class AdMobWidget extends StatefulWidget {
  const AdMobWidget({super.key});

  @override
  _AdMobWidgetState createState() => _AdMobWidgetState();
}

class _AdMobWidgetState extends State<AdMobWidget> {
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
    final authProvider = Provider.of<AuthProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!authProvider.isAuthenticated)
          const Text(
            'You need to be logged in to get reward',
            style: TextStyle(fontSize: 16),
          ),
        if (!authProvider.isAuthenticated)
          const SizedBox(height: 10),
        ElevatedButton(
          onPressed: authProvider.isAuthenticated
              ? () {
                  _rewardedAdManager.showAd(context, _handleUserEarnedReward);
                }
              : null,
          child: const Text('Show Rewarded Ad'),
        ),
        const SizedBox(height: 20),
        Text(_rewardMessage, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
