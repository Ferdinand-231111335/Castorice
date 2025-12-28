import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class InterstitialAds {
  static InterstitialAd? _interstitialAd;
  static bool _isAdReady = false;

  static const String _adUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  static void load() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isAdReady = false;
              load();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isAdReady = false;
              load();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed: $error');
          _isAdReady = false;
        },
      ),
    );
  }

  static void show({required VoidCallback onAdClosed}) {
    if (_isAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      onAdClosed();
    } else {
      onAdClosed();
    }
  }
}
