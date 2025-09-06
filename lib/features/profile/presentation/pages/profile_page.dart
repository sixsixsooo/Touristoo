import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/game_providers.dart';
import '../../../../core/services/audio_service.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/achievements_widget.dart';
import '../widgets/statistics_widget.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
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
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 100,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  onPressed: () {
                    audioService.playButtonSound();
                    context.go('/home');
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                title: Text(
                  'Profile',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      audioService.playButtonSound();
                      context.go('/settings');
                    },
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              ),
              
              // Profile Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Header
                      ProfileHeaderWidget(player: player),
                      
                      const SizedBox(height: 24),
                      
                      // Statistics
                      StatisticsWidget(player: player),
                      
                      const SizedBox(height: 24),
                      
                      // Achievements
                      AchievementsWidget(player: player),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      _buildActionButtons(context, audioService),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AudioService audioService) {
    return Column(
      children: [
        // Edit Profile Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              audioService.playButtonSound();
              // TODO: Implement edit profile
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Edit Profile',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Logout Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              audioService.playButtonSound();
              // TODO: Implement logout
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE74C3C),
              side: const BorderSide(color: Color(0xFFE74C3C), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Logout',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
