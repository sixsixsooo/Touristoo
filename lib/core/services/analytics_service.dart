import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:yandex_appmetrica/yandex_appmetrica.dart';

import '../config/app_config.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  late FirebaseAnalytics _firebaseAnalytics;
  late FirebaseCrashlytics _crashlytics;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (AppConfig.enableAnalytics) {
      _firebaseAnalytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;
      
      // Initialize Yandex AppMetrica
      await YandexAppmetrica.activateWithApiKey('YOUR_YANDEX_METRICA_API_KEY');
    }

    _isInitialized = true;
  }

  // Game Events
  Future<void> logGameStart() async {
    if (!_isInitialized || !AppConfig.enableAnalytics) return;
    
    await _firebaseAnalytics.logEvent(
      name: 'game_start',
      parameters: {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
    
    await YandexAppmetrica.reportEvent('game_start');
  }

  Future<void> logGameEnd(int score, double distance, int level) async {
    if (!_isInitialized || !AppConfig.enableAnalytics) return;
    
    await _firebaseAnalytics.logEvent(
      name: 'game_end',
      parameters: {
        'score': score,
        'distance': distance,
        'level': level,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
    
    await YandexAppmetrica.reportEventWithParameters('game_end', {
      'score': score.toString(),
      'distance': distance.toString(),
      'level': level.toString(),
    });
  }

  Future<void> logGamePause() async {
    if (!_isInitialized || !AppConfig.enableAnalytics) return;
    
    await _firebaseAnalytics.logEvent(name: 'game_pause');
    await YandexAppmetrica.reportEvent('game_pause');
  }

  Future<void> logGameResume() async {
    if (!_isInitialized || !AppConfig.enableAnalytics) return;
    
    await _firebaseAnalytics.logEvent(name: 'game_resume');
    await YandexAppmetrica.reportEvent('game_resume');
  }

  Future<void> logCoinCollected(int totalCoins) async {
    if (!_isInitialized || !AppConfig.enableAnalytics) return;
    
    await _firebaseAnalytics.logEvent(
      name: 'coin_collected',
      parameters: {
        'total_coins': totalCoins,
      },
    );
    
    await YandexAppmetrica.reportEventWithParameters('coin_collected', {
      'total_coins': totalCoins.toString(),
    });
  }

  Future<void> logObstacleHit(String obstacleType) async {
    if (!_isInitialized || !AppConfig.enableAnalytics) return;
    
    await _firebaseAnalytics.logEvent(
      name: 'obstacle_hit',
      parameters: {
        'obstacle_type': obstacleType,
      },
    );
    
    await YandexAppmetrica.reportEventWithParameters('obstacle_hit', {
      'obstacle_type': obstacleType,
    });
  }

  Future<void> logPowerUpCollected(String powerUpType) async {
    if (!_isInitialized || !AppConfig.enableAnalytics) return;
    
    await _firebaseAnalytics.logEvent(
      name: 'powerup_collected',
      parameters: {
        'powerup_type': powerUpType,
      },
    );
    
    await YandexAppmetrica.reportEventWithParameters('powerup_collected', {
      'powerup_type': powerUpType,
    });
  }

  Future<void> logLevelUp(int newLevel) async {
    if (!_isInitialized || !AppConfig.enableAnalytics) return;
    
    await _firebaseAnalytics.logEvent(
      name: 'level_up',
      parameters: {
        'new_level': newLevel,
      },
    );
    
    await YandexAppmetrica.reportEventWithParameters('level_up', {
      'new_level': newLevel.toString(),
    });
  }

  // Shop Events
  Future<void> logPurchase(String itemId, String itemType, int price, String currency) async {
    if (!_isInitialized || !AppConfig.enableAnalytics) return;
    
    await _firebaseAnalytics.logPurchase(
      currency: currency,
      value: price.toDouble(),
      parameters: {
        'item_id': itemId,
        'item_type': itemType,
      },
    );
    
    await YandexAppmetrica.reportEventWithParameters('purchase', {
      'item_id': itemId,
      'item_type': itemType,
      'price': price.toString(),
      'currency': currency,
    });
  }

  Future<void> logShopOpened() async {
    if (!_isInitialized || !AppConfig.enableAnalytics) return;
    
    await _firebaseAnalytics.logEvent(name: 'shop_opened');
    await YandexAppmetrica.reportEvent('shop_opened');
  }

  Future<void> logSkinChanged(String skinId) async {
    if (!_isInitialized || !AppConfig.enableAnalytics) return;
    
    await _firebaseAnalytics.logEvent(
      name: 'skin_changed',
      parameters: {
        'skin_id': skinId,
      },
    );
    
    await YandexAppmetrica.reportEventWithParameters('skin_changed', {
      'skin_id': skinId,
    });
  }

  // User Events
  Future<void> logUserLogin(String method) async {
    if (!_isInitialized || !AppConfig.enableAnalytics) return;
    
    await _firebaseAnalytics.logLogin(loginMethod: method);
    await YandexAppmetrica.reportEventWithParameters('user_login', {
      'method': method,
    });
  }

  Future<void> logUserRegister(String method) async {
    if (!_isInitialized || !AppConfig.enableAnalytics) return;
    
    await _firebaseAnalytics.logEvent(
      name: 'user_register',
      parameters: {
        'method': method,
      },
    );
    
    await YandexAppmetrica.reportEventWithParameters('user_register', {
      'method': method,
    });
  }

  // Settings Events
  Future<void> logSettingsChanged(String setting, dynamic value) async {
    if (!_isInitialized || !AppConfig.enableAnalytics) return;
    
    await _firebaseAnalytics.logEvent(
      name: 'settings_changed',
      parameters: {
        'setting': setting,
        'value': value.toString(),
      },
    );
    
    await YandexAppmetrica.reportEventWithParameters('settings_changed', {
      'setting': setting,
      'value': value.toString(),
    });
  }

  // Error Reporting
  Future<void> logError(String error, StackTrace? stackTrace) async {
    if (!_isInitialized || !AppConfig.enableCrashReporting) return;
    
    await _crashlytics.recordError(error, stackTrace);
  }

  // Custom Events
  Future<void> logCustomEvent(String eventName, Map<String, dynamic>? parameters) async {
    if (!_isInitialized || !AppConfig.enableAnalytics) return;
    
    await _firebaseAnalytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
    
    if (parameters != null) {
      final yandexParams = parameters.map((key, value) => MapEntry(key, value.toString()));
      await YandexAppmetrica.reportEventWithParameters(eventName, yandexParams);
    } else {
      await YandexAppmetrica.reportEvent(eventName);
    }
  }
}
