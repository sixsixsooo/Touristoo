import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/game_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/config/app_config.dart';
import '../widgets/game_renderer.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _uiAnimationController;
  late Animation<double> _uiAnimation;

  @override
  void initState() {
    super.initState();
    _uiAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _uiAnimation = CurvedAnimation(
      parent: _uiAnimationController,
      curve: Curves.easeInOut,
    );
    _uiAnimationController.forward();
  }

  @override
  void dispose() {
    _uiAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<GameProvider, AuthProvider>(
        builder: (context, gameProvider, authProvider, child) {
          return Stack(
            children: [
              // 3D Игровой рендерер
              GameRenderer(
                gameState: gameProvider.gameState,
                onPlayerMove: (position) {
                  gameProvider.updatePlayerPosition(position);
                },
                onJump: () {
                  gameProvider.jump();
                },
              ),

              // UI Overlay
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _uiAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _uiAnimation.value,
                      child: _buildGameUI(context, gameProvider, authProvider),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGameUI(BuildContext context, GameProvider gameProvider, AuthProvider authProvider) {
    return Stack(
      children: [
        // Верхняя панель с информацией
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Счет
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Счет: ${gameProvider.gameState.score}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Здоровье
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${gameProvider.gameState.health}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Кнопка паузы
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 20,
          child: GestureDetector(
            onTap: () {
              if (gameProvider.gameState.isPaused) {
                gameProvider.resumeGame();
              } else {
                gameProvider.pauseGame();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                gameProvider.gameState.isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),

        // Нижняя панель с монетами
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 20,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Монеты
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.yellow, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${authProvider.currentPlayer?.coins ?? 0}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Дистанция
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.straighten, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${gameProvider.gameState.distance.toStringAsFixed(0)}м',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Экран паузы
        if (gameProvider.gameState.isPaused)
          Container(
            color: Colors.black.withOpacity(0.8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ПАУЗА',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      gameProvider.resumeGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text(
                      'Продолжить',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      gameProvider.endGame();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text(
                      'Выйти',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Экран окончания игры
        if (!gameProvider.gameState.isPlaying && !gameProvider.gameState.isPaused)
          Container(
            color: Colors.black.withOpacity(0.8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ИГРА ОКОНЧЕНА',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Счет: ${gameProvider.gameState.score}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Дистанция: ${gameProvider.gameState.distance.toStringAsFixed(0)}м',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      gameProvider.startGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text(
                      'Играть снова',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text(
                      'Главное меню',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
