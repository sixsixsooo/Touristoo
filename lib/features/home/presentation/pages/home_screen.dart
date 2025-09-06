import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/game_provider.dart';
import '../../../../core/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  '🎮 Touristoo 3D Runner',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Версия 1.0.0',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 60),
                Consumer2<GameProvider, AuthProvider>(
                  builder: (context, gameProvider, authProvider, child) {
                    return Column(
                      children: [
                        if (authProvider.isLoggedIn)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Привет, ${authProvider.currentPlayer?.name ?? 'Игрок'}!',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Лучший результат: ${authProvider.currentPlayer?.bestScore ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 40),
                        _buildPlayButton(context, gameProvider),
                        const SizedBox(height: 20),
                        _buildMenuButton(
                          context,
                          '🏆 Рейтинг',
                          () => _showComingSoon(context),
                        ),
                        const SizedBox(height: 12),
                        _buildMenuButton(
                          context,
                          '⚙️ Настройки',
                          () => _showComingSoon(context),
                        ),
                        const SizedBox(height: 12),
                        _buildMenuButton(
                          context,
                          '👤 Профиль',
                          () => _showProfile(context, authProvider),
                        ),
                      ],
                    );
                  },
                ),
                const Spacer(),
                if (!Provider.of<AuthProvider>(context, listen: false).isLoggedIn)
                  _buildLoginButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context, GameProvider gameProvider) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          gameProvider.startGame();
          _showGameScreen(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          '🎮 ИГРАТЬ',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: ElevatedButton(
        onPressed: () {
          Provider.of<AuthProvider>(context, listen: false).loginAsGuest();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          '👤 Войти как гость',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showGameScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎮 Игра'),
        content: const Text('Игровой экран будет здесь!\n\nПока что это демо-версия.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<GameProvider>(context, listen: false).endGame();
            },
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚧 Скоро'),
        content: const Text('Эта функция будет добавлена в следующих версиях!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showProfile(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('👤 Профиль'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (authProvider.isLoggedIn) ...[
              Text('Имя: ${authProvider.currentPlayer?.name ?? 'Неизвестно'}'),
              Text('Уровень: ${authProvider.currentPlayer?.level ?? 0}'),
              Text('Монеты: ${authProvider.currentPlayer?.coins ?? 0}'),
              Text('Лучший результат: ${authProvider.currentPlayer?.bestScore ?? 0}'),
            ] else
              const Text('Вы не вошли в систему'),
          ],
        ),
        actions: [
          if (authProvider.isLoggedIn)
            TextButton(
              onPressed: () {
                authProvider.logout();
                Navigator.of(context).pop();
              },
              child: const Text('Выйти'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}