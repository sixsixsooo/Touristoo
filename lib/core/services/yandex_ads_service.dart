import 'package:yandex_mobile_ads/mobile_ads.dart';
import '../config/app_config.dart';

class YandexAdsService {
  static YandexAdsService? _instance;
  static YandexAdsService get instance => _instance ??= YandexAdsService._();
  
  YandexAdsService._();

  bool _isInitialized = false;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Инициализация Yandex Mobile Ads
      await MobileAds.initialize();
      
      _isInitialized = true;
      print('Yandex Ads initialized successfully');
    } catch (e) {
      print('Failed to initialize Yandex Ads: $e');
      rethrow;
    }
  }

  // Создание баннерной рекламы
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: AppConfig.yandexAdsBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      adListener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
        },
        onAdOpened: (ad) {
          print('Banner ad opened');
        },
        onAdClosed: (ad) {
          print('Banner ad closed');
        },
      ),
    );
  }

  // Создание межстраничной рекламы
  Future<InterstitialAd?> createInterstitialAd() async {
    try {
      return InterstitialAd(
        adUnitId: AppConfig.yandexAdsInterstitialId,
        request: const AdRequest(),
        adListener: InterstitialAdListener(
          onAdLoaded: (ad) {
            print('Interstitial ad loaded');
          },
          onAdFailedToLoad: (ad, error) {
            print('Interstitial ad failed to load: $error');
          },
          onAdOpened: (ad) {
            print('Interstitial ad opened');
          },
          onAdClosed: (ad) {
            print('Interstitial ad closed');
            ad.dispose();
          },
        ),
      );
    } catch (e) {
      print('Failed to create interstitial ad: $e');
      return null;
    }
  }

  // Создание рекламы с наградой
  Future<RewardedAd?> createRewardedAd() async {
    try {
      return RewardedAd(
        adUnitId: AppConfig.yandexAdsRewardedId,
        request: const AdRequest(),
        adListener: RewardedAdListener(
          onAdLoaded: (ad) {
            print('Rewarded ad loaded');
          },
          onAdFailedToLoad: (ad, error) {
            print('Rewarded ad failed to load: $error');
          },
          onAdOpened: (ad) {
            print('Rewarded ad opened');
          },
          onAdClosed: (ad) {
            print('Rewarded ad closed');
            ad.dispose();
          },
          onRewarded: (ad, reward) {
            print('Rewarded ad rewarded: ${reward.amount} ${reward.type}');
          },
        ),
      );
    } catch (e) {
      print('Failed to create rewarded ad: $e');
      return null;
    }
  }

  // Показ межстраничной рекламы
  Future<bool> showInterstitialAd() async {
    try {
      final ad = await createInterstitialAd();
      if (ad != null) {
        await ad.load();
        await ad.show();
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to show interstitial ad: $e');
      return false;
    }
  }

  // Показ рекламы с наградой
  Future<bool> showRewardedAd() async {
    try {
      final ad = await createRewardedAd();
      if (ad != null) {
        await ad.load();
        await ad.show();
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to show rewarded ad: $e');
      return false;
    }
  }

  // Проверка доступности рекламы
  Future<bool> isAdAvailable(String adType) async {
    try {
      switch (adType) {
        case 'banner':
          return true; // Баннеры всегда доступны
        case 'interstitial':
          final ad = await createInterstitialAd();
          return ad != null;
        case 'rewarded':
          final ad = await createRewardedAd();
          return ad != null;
        default:
          return false;
      }
    } catch (e) {
      print('Failed to check ad availability: $e');
      return false;
    }
  }

  // Получение информации о рекламе
  Future<Map<String, dynamic>> getAdInfo() async {
    try {
      return {
        'banner_available': await isAdAvailable('banner'),
        'interstitial_available': await isAdAvailable('interstitial'),
        'rewarded_available': await isAdAvailable('rewarded'),
        'banner_id': AppConfig.yandexAdsBannerId,
        'interstitial_id': AppConfig.yandexAdsInterstitialId,
        'rewarded_id': AppConfig.yandexAdsRewardedId,
      };
    } catch (e) {
      print('Failed to get ad info: $e');
      return {};
    }
  }

  // Очистка ресурсов
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
