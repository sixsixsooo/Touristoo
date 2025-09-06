import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/game_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/config/app_config.dart';
import 'core/services/vk_cloud_service.dart';
import 'core/services/data_service.dart';
import 'core/services/yandex_ads_service.dart';
import 'features/home/presentation/pages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализируем сервисы
  await VKCloudService.instance.initialize();
  await DataService.instance.initialize();
  await YandexAdsService.instance.initialize();
  
  // Инициализируем провайдеры
  final gameProvider = GameProvider();
  final authProvider = AuthProvider();
  
  await gameProvider.initialize();
  await authProvider.initialize();
  
  runApp(TouristooApp(
    gameProvider: gameProvider,
    authProvider: authProvider,
  ));
}

class TouristooApp extends StatelessWidget {
  final GameProvider gameProvider;
  final AuthProvider authProvider;

  const TouristooApp({
    super.key,
    required this.gameProvider,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: gameProvider),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3C72),
            brightness: Brightness.light,
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
