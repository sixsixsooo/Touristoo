import 'package:flutter/material.dart';

import '../../../../core/models/game_models.dart';

class GameStatsWidget extends StatelessWidget {
  final Player player;
  final GameState gameState;

  const GameStatsWidget({
    super.key,
    required this.player,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your Stats',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.star,
                label: 'Best Score',
                value: player.totalScore.toString(),
                color: Colors.amber,
              ),
              _buildStatItem(
                context,
                icon: Icons.trending_up,
                label: 'Level',
                value: player.level.toString(),
                color: Colors.blue,
              ),
              _buildStatItem(
                context,
                icon: Icons.monetization_on,
                label: 'Coins',
                value: player.coins.toString(),
                color: Colors.yellow,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
