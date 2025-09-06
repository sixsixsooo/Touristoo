import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/game_providers.dart';
import '../../../../core/services/audio_service.dart';
import '../widgets/game_stats_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/character_preview_widget.dart';
import '../../../ads/presentation/widgets/banner_ad_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _characterController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _characterAnimation;

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _characterController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));
    
    _characterAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _characterController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _characterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final gameState = ref.watch(gameStateProvider);
    final audioService = ref.read(audioServiceProvider);

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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          player.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        audioService.playButtonSound();
                        context.go('/settings');
                      },
                      icon: const Icon(Icons.settings),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Character Preview
              Expanded(
                flex: 3,
                child: AnimatedBuilder(
                  animation: _characterAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _characterAnimation.value * 10),
                      child: const CharacterPreviewWidget(),
                    );
                  },
                ),
              ),
              
              // Game Stats
              Expanded(
                flex: 2,
                child: GameStatsWidget(
                  player: player,
                  gameState: gameState,
                ),
              ),
              
              // Quick Actions
              Expanded(
                flex: 2,
                child: QuickActionsWidget(
                  onPlay: () {
                    audioService.playButtonSound();
                    ref.read(gameStateProvider.notifier).startGame();
                    context.go('/game');
                  },
                  onShop: () {
                    audioService.playButtonSound();
                    context.go('/shop');
                  },
                  onLeaderboard: () {
                    audioService.playButtonSound();
                    context.go('/leaderboard');
                  },
                  onProfile: () {
                    audioService.playButtonSound();
                    context.go('/profile');
                  },
                ),
              ),
              
              // Banner Ad
              const BannerAdWidget(
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: Color(0xFF1A1A2E),
              ),
              
              // Bottom Navigation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.home,
                      label: 'Home',
                      isSelected: true,
                      onTap: () {},
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.shopping_bag,
                      label: 'Shop',
                      onTap: () {
                        audioService.playButtonSound();
                        context.go('/shop');
                      },
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.leaderboard,
                      label: 'Leaderboard',
                      onTap: () {
                        audioService.playButtonSound();
                        context.go('/leaderboard');
                      },
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.person,
                      label: 'Profile',
                      onTap: () {
                        audioService.playButtonSound();
                        context.go('/profile');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
