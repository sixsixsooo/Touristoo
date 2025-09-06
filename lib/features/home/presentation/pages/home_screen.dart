import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/game_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/config/app_config.dart';
import '../../game/presentation/pages/game_screen.dart';
import '../../leaderboard/presentation/pages/leaderboard_screen.dart';
import '../../settings/presentation/pages/settings_screen.dart';
import '../../profile/presentation/pages/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer2<GameProvider, AuthProvider>(
            builder: (context, gameProvider, authProvider, child) {
              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildContent(context, gameProvider, authProvider),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, GameProvider gameProvider, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Заголовок
          const SizedBox(height: 40),
          Text(
            AppConfig.appName,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '3D Runner для RuStore',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),

          // Информация об игроке
          const SizedBox(height: 40),
          _buildPlayerInfo(authProvider),

          // Основные кнопки
          const SizedBox(height: 60),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPlayButton(context, gameProvider),
                const SizedBox(height: 20),
                _buildMenuButtons(context),
              ],
            ),
          ),

          // Нижняя панель
          _buildBottomPanel(authProvider),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(AuthProvider authProvider) {
    final player = authProvider.currentPlayer;
    if (player == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              player.name.isNotEmpty ? player.name[0].toUpperCase() : 'G',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.yellow, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${player.coins}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Уровень ${player.level}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context, GameProvider gameProvider) {
    return GestureDetector(
      onTap: () {
        gameProvider.startGame();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const GameScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
              SizedBox(width: 16),
              Text(
                'ИГРАТЬ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Column(
      children: [
        _buildMenuButton(
          context,
          'Рейтинг',
          Icons.leaderboard,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const LeaderboardScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 15),
        _buildMenuButton(
          context,
          'Настройки',
          Icons.settings,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 15),
        _buildMenuButton(
          context,
          'Профиль',
          Icons.person,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomButton(
            'Войти',
            Icons.login,
            () {
              // TODO: Показать экран входа
            },
          ),
          _buildBottomButton(
            'Регистрация',
            Icons.person_add,
            () {
              // TODO: Показать экран регистрации
            },
          ),
          _buildBottomButton(
            'О игре',
            Icons.info,
            () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppConfig.appName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Версия: ${AppConfig.appVersion}'),
            const SizedBox(height: 8),
            const Text('3D бегун для RuStore с поддержкой российских сервисов.'),
            const SizedBox(height: 8),
            const Text('Использует VK Cloud, Yandex Ads и RuStore.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
