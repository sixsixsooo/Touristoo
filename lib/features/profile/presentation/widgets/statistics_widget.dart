import 'package:flutter/material.dart';

import '../../../../core/models/game_models.dart';

class StatisticsWidget extends StatelessWidget {
  final Player player;

  const StatisticsWidget({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Statistics Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildStatCard(
                context,
                title: 'Games Played',
                value: '42', // This would come from actual data
                icon: Icons.games,
                color: Colors.blue,
              ),
              _buildStatCard(
                context,
                title: 'Total Distance',
                value: '15.2 km', // This would come from actual data
                icon: Icons.straighten,
                color: Colors.green,
              ),
              _buildStatCard(
                context,
                title: 'Coins Collected',
                value: player.coins.toString(),
                icon: Icons.monetization_on,
                color: Colors.yellow,
              ),
              _buildStatCard(
                context,
                title: 'Best Streak',
                value: '8', // This would come from actual data
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
              _buildStatCard(
                context,
                title: 'Obstacles Avoided',
                value: '156', // This would come from actual data
                icon: Icons.dangerous,
                color: Colors.red,
              ),
              _buildStatCard(
                context,
                title: 'Power-ups Used',
                value: '23', // This would come from actual data
                icon: Icons.flash_on,
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
