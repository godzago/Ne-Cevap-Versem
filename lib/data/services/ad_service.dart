import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  
  // Test IDs for Android
  final String _appOpenAdUnitId = 'ca-app-pub-3940256099942544/9257395921';
  final String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  final String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  // --- App Open Ad ---
  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          showAppOpenAdIfAvailable();
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  void showAppOpenAdIfAvailable() {
    if (_appOpenAd == null || _isShowingAd) {
      return;
    }
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
    );
    _appOpenAd!.show();
  }

  // --- Banner Ad ---
  BannerAd createBannerAd({required VoidCallback onAdLoaded, required void Function(LoadAdError error) onAdFailedToLoad}) {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
    );
  }

  // --- Rewarded Ad ---
  void showRewardedAd({required VoidCallback onRewarded, VoidCallback? onAdClosed}) {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (onAdClosed != null) onAdClosed();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              if (onAdClosed != null) onAdClosed();
            },
          );

          ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            onRewarded();
          });
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: $error');
          if (onAdClosed != null) onAdClosed();
        },
      ),
    );
  }
}
