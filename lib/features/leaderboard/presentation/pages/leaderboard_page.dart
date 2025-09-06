import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/game_providers.dart';
import '../../../../core/services/audio_service.dart';
import '../widgets/leaderboard_header_widget.dart';
import '../widgets/leaderboard_list_widget.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        audioService.playButtonSound();
                        context.go('/home');
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      'Leaderboard',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        audioService.playButtonSound();
                        // TODO: Refresh leaderboard
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Header
              LeaderboardHeaderWidget(player: player),
              
              const SizedBox(height: 16),
              
              // Time Range Selector
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFF4A90E2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  onTap: (index) {
                    setState(() {
                      _selectedTimeRange = ['all', 'weekly', 'monthly'][index];
                    });
                  },
                  tabs: const [
                    Tab(text: 'All Time'),
                    Tab(text: 'Weekly'),
                    Tab(text: 'Monthly'),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Leaderboard List
              Expanded(
                child: LeaderboardListWidget(
                  timeRange: _selectedTimeRange,
                  onPlayerTap: (playerId) {
                    audioService.playButtonSound();
                    // TODO: Show player profile
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
