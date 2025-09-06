import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/ads_service.dart';
import '../../../../core/services/analytics_service.dart';

class InterstitialAdManager extends ConsumerWidget {
  final Widget child;
  final bool showAdOnGameOver;
  final bool showAdOnLevelComplete;
  final bool showAdOnShopOpen;
  final int adFrequency; // Показывать рекламу каждые N действий

  const InterstitialAdManager({
    super.key,
    required this.child,
    this.showAdOnGameOver = true,
    this.showAdOnLevelComplete = true,
    this.showAdOnShopOpen = false,
    this.adFrequency = 3,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsService = ref.read(adsServiceProvider);
    final analyticsService = ref.read(analyticsServiceProvider);

    // Загружаем рекламу при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adsService.loadInterstitialAd(
        onAdClosed: () {
          analyticsService.logCustomEvent('interstitial_ad_closed');
        },
        onAdFailedToLoad: (error) {
          analyticsService.logCustomEvent('interstitial_ad_failed', {
            'error': error,
          });
        },
      );
    });

    return child;
  }

  // Методы для показа рекламы в разных ситуациях
  static Future<void> showAdAfterGameOver(WidgetRef ref) async {
    final adsService = ref.read(adsServiceProvider);
    final analyticsService = ref.read(analyticsServiceProvider);
    
    if (adsService.canShowAd()) {
      analyticsService.logCustomEvent('interstitial_ad_requested', {
        'trigger': 'game_over',
      });
      
      final success = await adsService.showAdAfterGameOver();
      if (success) {
        analyticsService.logCustomEvent('interstitial_ad_shown', {
          'trigger': 'game_over',
        });
      }
    }
  }

  static Future<void> showAdOnLevelComplete(WidgetRef ref) async {
    final adsService = ref.read(adsServiceProvider);
    final analyticsService = ref.read(analyticsServiceProvider);
    
    if (adsService.canShowAd()) {
      analyticsService.logCustomEvent('interstitial_ad_requested', {
        'trigger': 'level_complete',
      });
      
      final success = await adsService.showInterstitialAd();
      if (success) {
        analyticsService.logCustomEvent('interstitial_ad_shown', {
          'trigger': 'level_complete',
        });
      }
    }
  }

  static Future<void> showAdOnShopOpen(WidgetRef ref) async {
    final adsService = ref.read(adsServiceProvider);
    final analyticsService = ref.read(analyticsServiceProvider);
    
    if (adsService.canShowAd()) {
      analyticsService.logCustomEvent('interstitial_ad_requested', {
        'trigger': 'shop_open',
      });
      
      final success = await adsService.showInterstitialAd();
      if (success) {
        analyticsService.logCustomEvent('interstitial_ad_shown', {
          'trigger': 'shop_open',
        });
      }
    }
  }

  static Future<void> showAdWithFrequency(WidgetRef ref, String trigger) async {
    final adsService = ref.read(adsServiceProvider);
    final analyticsService = ref.read(analyticsServiceProvider);
    
    // Здесь можно добавить логику частоты показа рекламы
    // Например, показывать рекламу каждые N действий
    
    if (adsService.canShowAd()) {
      analyticsService.logCustomEvent('interstitial_ad_requested', {
        'trigger': trigger,
      });
      
      final success = await adsService.showInterstitialAd();
      if (success) {
        analyticsService.logCustomEvent('interstitial_ad_shown', {
          'trigger': trigger,
        });
      }
    }
  }
}
