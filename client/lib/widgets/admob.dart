import 'package:flutter/material.dart';
import 'package:client/services/admob/rewarded_ad_manager.dart';
import 'package:provider/provider.dart';
import 'package:client/providers/auth_provider.dart';
import 'package:client/providers/messages_provider.dart';

class AdMobWidget extends StatefulWidget {
  const AdMobWidget({super.key});

  @override
  _AdMobWidgetState createState() => _AdMobWidgetState();
}

class _AdMobWidgetState extends State<AdMobWidget> {
  late RewardedAdManager _rewardedAdManager;

  @override
  void initState() {
    super.initState();
    _rewardedAdManager = RewardedAdManager(context);
    _rewardedAdManager.loadAd();
  }

  @override
  void dispose() {
    _rewardedAdManager.dispose();
    super.dispose();
  }

  void _showMessage(BuildContext context) {
    final messagesProvider = Provider.of<MessagesProvider>(context, listen: false);
    final message = messagesProvider.message;

    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      messagesProvider.clearMessage(); // Clear the message after showing it in the Snackbar
    }
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
                  _rewardedAdManager.showAd(
                    context, // First argument: BuildContext
                    (reward) {
                      _showMessage(context); // Second argument: Callback for when the user earns a reward
                    },
                  );
                }
              : null,
          child: const Text('Show Rewarded Ad'),
        ),
      ],
    );
  }
}
