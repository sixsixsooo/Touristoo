import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_mobileads/yandex_mobileads.dart';

import '../config/app_config.dart';
import '../models/game_models.dart';

final adsServiceProvider = Provider<AdsService>((ref) {
  return AdsService();
});

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  late InterstitialAd _interstitialAd;
  late RewardedAd _rewardedAd;
  late BannerAd _bannerAd;
  
  bool _isInitialized = false;
  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;
  bool _isBannerLoaded = false;
  
  // Ad Unit IDs (замените на ваши реальные ID)
  static const String _bannerAdUnitId = 'R-M-1234567-1';
  static const String _interstitialAdUnitId = 'R-M-1234567-2';
  static const String _rewardedAdUnitId = 'R-M-1234567-3';
  
  // Callbacks
  Function()? _onAdClosed;
  Function()? _onAdRewarded;
  Function(String)? _onAdFailedToLoad;
  Function()? _onAdLoaded;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Инициализация Yandex Mobile Ads
      await YandexMobileAds.initialize();
      
      // Настройка тестовых устройств (для разработки)
      await YandexMobileAds.setUserConsent(true);
      await YandexMobileAds.setLocationConsent(false);
      await YandexMobileAds.setAgeRestrictedUser(false);
      
      _isInitialized = true;
      print('Yandex Mobile Ads initialized successfully');
    } catch (e) {
      print('Failed to initialize Yandex Mobile Ads: $e');
    }
  }

  // Banner Ad
  Future<void> loadBannerAd({
    required Function() onAdLoaded,
    required Function(String) onAdFailedToLoad,
  }) async {
    if (!_isInitialized) await initialize();
    
    _onAdLoaded = onAdLoaded;
    _onAdFailedToLoad = onAdFailedToLoad;
    
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      onAdLoaded: () {
        _isBannerLoaded = true;
        _onAdLoaded?.call();
        print('Banner ad loaded successfully');
      },
      onAdFailedToLoad: (error) {
        _isBannerLoaded = false;
        _onAdFailedToLoad?.call(error.description);
        print('Banner ad failed to load: $error');
      },
      onAdClicked: () {
        print('Banner ad clicked');
        _trackAdEvent('banner_clicked');
      },
      onAdShown: () {
        print('Banner ad shown');
        _trackAdEvent('banner_shown');
      },
    );
    
    await _bannerAd.load();
  }

  BannerAd? getBannerAd() {
    return _isBannerLoaded ? _bannerAd : null;
  }

  void disposeBannerAd() {
    if (_isBannerLoaded) {
      _bannerAd.dispose();
      _isBannerLoaded = false;
    }
  }

  // Interstitial Ad
  Future<void> loadInterstitialAd({
    required Function() onAdClosed,
    required Function(String) onAdFailedToLoad,
  }) async {
    if (!_isInitialized) await initialize();
    
    _onAdClosed = onAdClosed;
    _onAdFailedToLoad = onAdFailedToLoad;
    
    _interstitialAd = InterstitialAd(
      adUnitId: _interstitialAdUnitId,
      onAdLoaded: () {
        _isInterstitialLoaded = true;
        print('Interstitial ad loaded successfully');
      },
      onAdFailedToLoad: (error) {
        _isInterstitialLoaded = false;
        _onAdFailedToLoad?.call(error.description);
        print('Interstitial ad failed to load: $error');
      },
      onAdShown: () {
        print('Interstitial ad shown');
        _trackAdEvent('interstitial_shown');
      },
      onAdDismissed: () {
        print('Interstitial ad dismissed');
        _trackAdEvent('interstitial_dismissed');
        _onAdClosed?.call();
      },
      onAdClicked: () {
        print('Interstitial ad clicked');
        _trackAdEvent('interstitial_clicked');
      },
    );
    
    await _interstitialAd.load();
  }

  Future<bool> showInterstitialAd() async {
    if (!_isInterstitialLoaded) {
      print('Interstitial ad not loaded');
      return false;
    }
    
    try {
      await _interstitialAd.show();
      return true;
    } catch (e) {
      print('Failed to show interstitial ad: $e');
      return false;
    }
  }

  // Rewarded Ad
  Future<void> loadRewardedAd({
    required Function() onAdRewarded,
    required Function() onAdClosed,
    required Function(String) onAdFailedToLoad,
  }) async {
    if (!_isInitialized) await initialize();
    
    _onAdRewarded = onAdRewarded;
    _onAdClosed = onAdClosed;
    _onAdFailedToLoad = onAdFailedToLoad;
    
    _rewardedAd = RewardedAd(
      adUnitId: _rewardedAdUnitId,
      onAdLoaded: () {
        _isRewardedLoaded = true;
        print('Rewarded ad loaded successfully');
      },
      onAdFailedToLoad: (error) {
        _isRewardedLoaded = false;
        _onAdFailedToLoad?.call(error.description);
        print('Rewarded ad failed to load: $error');
      },
      onAdShown: () {
        print('Rewarded ad shown');
        _trackAdEvent('rewarded_shown');
      },
      onAdDismissed: () {
        print('Rewarded ad dismissed');
        _trackAdEvent('rewarded_dismissed');
        _onAdClosed?.call();
      },
      onAdClicked: () {
        print('Rewarded ad clicked');
        _trackAdEvent('rewarded_clicked');
      },
      onRewarded: (reward) {
        print('Rewarded ad rewarded: ${reward.amount} ${reward.type}');
        _trackAdEvent('rewarded_earned', {
          'amount': reward.amount.toString(),
          'type': reward.type,
        });
        _onAdRewarded?.call();
      },
    );
    
    await _rewardedAd.load();
  }

  Future<bool> showRewardedAd() async {
    if (!_isRewardedLoaded) {
      print('Rewarded ad not loaded');
      return false;
    }
    
    try {
      await _rewardedAd.show();
      return true;
    } catch (e) {
      print('Failed to show rewarded ad: $e');
      return false;
    }
  }

  // Ad Status
  bool get isInterstitialLoaded => _isInterstitialLoaded;
  bool get isRewardedLoaded => _isRewardedLoaded;
  bool get isBannerLoaded => _isBannerLoaded;

  // Preload ads
  Future<void> preloadAds() async {
    await Future.wait([
      loadInterstitialAd(
        onAdClosed: () {},
        onAdFailedToLoad: (error) => print('Interstitial preload failed: $error'),
      ),
      loadRewardedAd(
        onAdRewarded: () {},
        onAdClosed: () {},
        onAdFailedToLoad: (error) => print('Rewarded preload failed: $error'),
      ),
    ]);
  }

  // Game-specific ad triggers
  Future<bool> showAdAfterGameOver() async {
    // Показываем рекламу после окончания игры
    return await showInterstitialAd();
  }

  Future<bool> showAdForExtraLife() async {
    // Показываем рекламу за дополнительную жизнь
    return await showRewardedAd();
  }

  Future<bool> showAdForCoins() async {
    // Показываем рекламу за монеты
    return await showRewardedAd();
  }

  Future<bool> showAdForSkin() async {
    // Показываем рекламу за скин
    return await showRewardedAd();
  }

  // Ad frequency control
  static const int _minAdInterval = 30; // секунды между рекламами
  static DateTime? _lastAdShown;
  
  bool canShowAd() {
    if (_lastAdShown == null) return true;
    
    final now = DateTime.now();
    final timeSinceLastAd = now.difference(_lastAdShown!).inSeconds;
    
    return timeSinceLastAd >= _minAdInterval;
  }

  void _markAdShown() {
    _lastAdShown = DateTime.now();
  }

  // Analytics
  void _trackAdEvent(String eventName, [Map<String, dynamic>? parameters]) {
    // Здесь можно добавить отправку аналитики
    print('Ad event: $eventName, parameters: $parameters');
    
    // Отправляем в Yandex AppMetrica
    // YandexAppmetrica.reportEventWithParameters(eventName, parameters ?? {});
  }

  // Revenue tracking
  void trackAdRevenue({
    required String adType,
    required double revenue,
    required String currency,
  }) {
    print('Ad revenue: $adType - $revenue $currency');
    
    // Здесь можно добавить отправку данных о доходе
    // в вашу аналитическую систему
  }

  // Dispose
  void dispose() {
    disposeBannerAd();
    _interstitialAd.dispose();
    _rewardedAd.dispose();
  }
}
