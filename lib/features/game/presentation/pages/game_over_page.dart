import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/game_providers.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../widgets/game_over_widget.dart';

class GameOverPage extends ConsumerStatefulWidget {
  final int score;
  final double distance;

  const GameOverPage({
    super.key,
    required this.score,
    required this.distance,
  });

  @override
  ConsumerState<GameOverPage> createState() => _GameOverPageState();
}

class _GameOverPageState extends ConsumerState<GameOverPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _startAnimations();
    _updatePlayerStats();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  void _updatePlayerStats() {
    final player = ref.read(playerProvider);
    final gameState = ref.read(gameStateProvider);
    
    // Update player's best score
    if (widget.score > player.totalScore) {
      ref.read(playerProvider.notifier).updateScore(widget.score);
    }
    
    // Add coins from the game
    ref.read(playerProvider.notifier).updateCoins(player.coins + gameState.coins);
    
    // Log analytics
    ref.read(analyticsServiceProvider).logGameEnd(
      widget.score,
      widget.distance,
      gameState.currentLevel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F0F23),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: GameOverWidget(
                    score: widget.score,
                    distance: widget.distance,
                    isNewRecord: widget.score > player.totalScore,
                    onPlayAgain: () {
                      ref.read(audioServiceProvider).playButtonSound();
                      ref.read(gameStateProvider.notifier).startGame();
                      context.go('/game');
                    },
                    onHome: () {
                      ref.read(audioServiceProvider).playButtonSound();
                      context.go('/home');
                    },
                    onShare: () {
                      ref.read(audioServiceProvider).playButtonSound();
                      _shareScore();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _shareScore() {
    // Implement sharing functionality
    // This would typically use a sharing package like share_plus
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Score sharing feature coming soon!'),
        backgroundColor: Color(0xFF4A90E2),
      ),
    );
  }
}
