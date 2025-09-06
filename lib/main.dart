import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/home/presentation/pages/home_screen.dart';
import 'core/providers/game_provider.dart';
import 'core/providers/auth_provider.dart';

void main() {
  runApp(const TouristooApp());
}

class TouristooApp extends StatelessWidget {
  const TouristooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Touristoo 3D Runner',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}