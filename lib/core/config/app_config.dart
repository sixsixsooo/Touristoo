class AppConfig {
  // App Information
  static const String appName = 'Touristoo Runner';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  
  // API Configuration
  static const String baseUrl = 'https://api.touristoo.run';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Yandex Cloud Configuration
  static const String yandexCloudApiKey = 'YOUR_YANDEX_CLOUD_API_KEY';
  static const String yandexCloudFunctionUrl = 'https://functions.yandexcloud.net';
  
  // YooKassa Configuration
  static const String yookassaShopId = 'YOUR_YOOKASSA_SHOP_ID';
  static const String yookassaSecretKey = 'YOUR_YOOKASSA_SECRET_KEY';
  static const String yookassaApiUrl = 'https://api.yookassa.ru/v3';
  
  // RuStore Configuration
  static const String russtoreAppId = 'ru.touristoo.runner';
  static const String russtorePackageName = 'ru.touristoo.runner';
  
  // Game Configuration
  static const double initialGameSpeed = 5.0;
  static const double maxGameSpeed = 25.0;
  static const double speedIncreaseRate = 0.1;
  static const int maxHealth = 100;
  static const int coinValue = 10;
  static const int obstacleDamage = 20;
  
  // 3D Graphics Configuration
  static const double fieldOfView = 60.0;
  static const double nearPlane = 0.1;
  static const double farPlane = 1000.0;
  static const double cameraDistance = 5.0;
  static const double cameraHeight = 2.0;
  
  // Audio Configuration
  static const double masterVolume = 1.0;
  static const double musicVolume = 0.7;
  static const double sfxVolume = 0.8;
  
  // Analytics Configuration
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;
  
  // Debug Configuration
  static const bool enableDebugMode = false;
  static const bool enableLogging = true;
  static const bool enablePerformanceOverlay = false;
}
