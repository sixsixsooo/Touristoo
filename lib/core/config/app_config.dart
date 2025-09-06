class AppConfig {
  // App Information
  static const String appName = 'Touristoo Runner';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  
  // VK Cloud Configuration (РОССИЙСКИЙ - БЕСПЛАТНО)
  static const String vkCloudProjectId = 'touristoo-runner';
  static const String vkCloudApiKey = 'YOUR_VK_CLOUD_API_KEY';
  static const String vkCloudRegion = 'ru-1';
  
  // VK Cloud Functions (БЕСПЛАТНО - 1 млн вызовов)
  static const String vkCloudFunctionUrl = 'https://functions.vkcs.cloud';
  static const String vkCloudFunctionId = 'YOUR_FUNCTION_ID';
  
  // VK Cloud PostgreSQL (БЕСПЛАТНО - 1 ГБ)
  static const String vkCloudDatabaseUrl = 'postgresql://user:pass@host:port/db';
  static const String vkCloudDatabaseHost = 'YOUR_DB_HOST';
  static const int vkCloudDatabasePort = 5432;
  static const String vkCloudDatabaseName = 'touristoo';
  static const String vkCloudDatabaseUser = 'touristoo_user';
  static const String vkCloudDatabasePassword = 'YOUR_DB_PASSWORD';
  
  // VK Cloud Object Storage (БЕСПЛАТНО - 1 ГБ)
  static const String vkCloudStorageUrl = 'https://storage.vkcs.cloud';
  static const String vkCloudStorageBucket = 'touristoo-assets';
  static const String vkCloudStorageAccessKey = 'YOUR_STORAGE_ACCESS_KEY';
  static const String vkCloudStorageSecretKey = 'YOUR_STORAGE_SECRET_KEY';
  
  // Yandex Ads Configuration (РОССИЙСКИЙ - УЖЕ НАСТРОЕН)
  static const String yandexAdsAppId = 'YOUR_YANDEX_ADS_APP_ID';
  static const String yandexAdsBannerId = 'YOUR_YANDEX_ADS_BANNER_ID';
  static const String yandexAdsInterstitialId = 'YOUR_YANDEX_ADS_INTERSTITIAL_ID';
  static const String yandexAdsRewardedId = 'YOUR_YANDEX_ADS_REWARDED_ID';
  
  // VK Ads Configuration (РОССИЙСКИЙ - БЕСПЛАТНО)
  static const String vkAdsAppId = 'YOUR_VK_ADS_APP_ID';
  static const String vkAdsBannerId = 'YOUR_VK_ADS_BANNER_ID';
  static const String vkAdsInterstitialId = 'YOUR_VK_ADS_INTERSTITIAL_ID';
  
  // In-App Purchases (30% комиссия Google/Apple)
  static const String iapCoinPack1 = 'coin_pack_100';
  static const String iapCoinPack2 = 'coin_pack_500';
  static const String iapCoinPack3 = 'coin_pack_1000';
  
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
