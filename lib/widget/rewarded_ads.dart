import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class RewardedAds {
  static bool isTest = false;
  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;

  static const String _adUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static void load() {
    if (isTest) return;
    if (_isLoading || _rewardedAd != null) return;

    _isLoading = true;

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isLoading = false;
          debugPrint('Rewarded Ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Rewarded Ad gagal: $error');
          _rewardedAd = null;
          _isLoading = false;
        },
      ),
    );
  }


  static void show({
    required VoidCallback onUserEarnedReward,
    required VoidCallback onAdClosed,
  }) {
    if (isTest) {
      onUserEarnedReward();
      onAdClosed();
      return;
    }
    if (_rewardedAd == null) {
      debugPrint('Rewarded Ad belum ada');
      load();
      return;
    }

    _rewardedAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        load();
        onAdClosed.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        load();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint(
          'Hadiah didapat: ${reward.amount} ${reward.type}',
        );
        onUserEarnedReward();
      },
    );
  }
}
