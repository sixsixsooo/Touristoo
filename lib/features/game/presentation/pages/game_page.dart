import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/game_providers.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/ads_service.dart';
import '../widgets/game_ui_widget.dart';
import '../widgets/game_3d_widget.dart';
import '../widgets/pause_menu_widget.dart';
import '../../../ads/presentation/widgets/interstitial_ad_manager.dart';

class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key});

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage>
    with TickerProviderStateMixin {
  late AnimationController _uiController;
  late Animation<double> _uiAnimation;
  
  bool _isPaused = false;
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    
    _uiController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _uiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _uiController,
      curve: Curves.easeOut,
    ));
    
    _startGame();
  }

  @override
  void dispose() {
    _uiController.dispose();
    super.dispose();
  }

  void _startGame() {
    final gameState = ref.read(gameStateProvider);
    if (!gameState.isRunning) {
      ref.read(gameStateProvider.notifier).startGame();
      ref.read(analyticsServiceProvider).logGameStart();
    }
    _gameStarted = true;
    _uiController.forward();
  }

  void _pauseGame() {
    if (!_isPaused) {
      setState(() {
        _isPaused = true;
      });
      ref.read(gameStateProvider.notifier).pauseGame();
      ref.read(analyticsServiceProvider).logGamePause();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    }
  }

  void _resumeGame() {
    if (_isPaused) {
      setState(() {
        _isPaused = false;
      });
      ref.read(gameStateProvider.notifier).resumeGame();
      ref.read(analyticsServiceProvider).logGameResume();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    }
  }

  void _endGame() async {
    final gameState = ref.read(gameStateProvider);
    ref.read(gameStateProvider.notifier).endGame();
    ref.read(analyticsServiceProvider).logGameEnd(
      gameState.score,
      gameState.distance,
      gameState.currentLevel,
    );
    
    // Показываем рекламу после окончания игры
    await InterstitialAdManager.showAdAfterGameOver(ref);
    
    if (mounted) {
      context.go('/game-over', extra: gameState.score);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    
    return InterstitialAdManager(
      showAdOnGameOver: true,
      showAdOnLevelComplete: true,
      child: WillPopScope(
        onWillPop: () async {
          if (_isPaused) {
            _resumeGame();
          } else {
            _pauseGame();
          }
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
            // 3D Game View
            Game3DWidget(
              onGameOver: _endGame,
              onScoreUpdate: (score) {
                ref.read(gameStateProvider.notifier).updateScore(score);
              },
              onDistanceUpdate: (distance) {
                ref.read(gameStateProvider.notifier).updateDistance(distance);
              },
              onHealthUpdate: (health) {
                ref.read(gameStateProvider.notifier).updateHealth(health);
                if (health <= 0) {
                  _endGame();
                }
              },
              onCoinCollected: (coins) {
                ref.read(gameStateProvider.notifier).addCoins(coins);
                ref.read(analyticsServiceProvider).logCoinCollected(coins);
              },
              onObstacleHit: (obstacleType) {
                ref.read(analyticsServiceProvider).logObstacleHit(obstacleType);
              },
              onPowerUpCollected: (powerUpType) {
                ref.read(analyticsServiceProvider).logPowerUpCollected(powerUpType);
              },
              onLevelUp: (level) {
                ref.read(gameStateProvider.notifier).levelUp();
                ref.read(analyticsServiceProvider).logLevelUp(level);
              },
              isPaused: _isPaused,
            ),
            
            // Game UI
            if (_gameStarted)
              AnimatedBuilder(
                animation: _uiAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _uiAnimation.value,
                    child: GameUIWidget(
                      gameState: gameState,
                      onPause: _pauseGame,
                      onResume: _resumeGame,
                      isPaused: _isPaused,
                    ),
                  );
                },
              ),
            
            // Pause Menu
            if (_isPaused)
              PauseMenuWidget(
                onResume: _resumeGame,
                onRestart: () {
                  _resumeGame();
                  ref.read(gameStateProvider.notifier).startGame();
                },
                onHome: () {
                  ref.read(gameStateProvider.notifier).endGame();
                  context.go('/home');
                },
              ),
          ],
        ),
      ),
    );
  }
}
