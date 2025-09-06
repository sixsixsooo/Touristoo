import 'package:flutter/material.dart';

import '../../../../core/models/game_models.dart';

class AchievementsWidget extends StatelessWidget {
  final Player player;

  const AchievementsWidget({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    final achievements = _getAchievements();
    
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
            'Achievements',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Achievements List
          ...achievements.map((achievement) => _buildAchievementItem(
            context,
            achievement: achievement,
          )),
        ],
      ),
    );
  }

  List<Achievement> _getAchievements() {
    return [
      Achievement(
        id: 'first_game',
        title: 'First Steps',
        description: 'Play your first game',
        icon: Icons.play_arrow,
        isUnlocked: true,
        progress: 1.0,
        color: Colors.blue,
      ),
      Achievement(
        id: 'score_1000',
        title: 'Rising Star',
        description: 'Score 1000 points in a single game',
        icon: Icons.star,
        isUnlocked: player.totalScore >= 1000,
        progress: (player.totalScore / 1000).clamp(0.0, 1.0),
        color: Colors.amber,
      ),
      Achievement(
        id: 'coins_100',
        title: 'Coin Collector',
        description: 'Collect 100 coins',
        icon: Icons.monetization_on,
        isUnlocked: player.coins >= 100,
        progress: (player.coins / 100).clamp(0.0, 1.0),
        color: Colors.yellow,
      ),
      Achievement(
        id: 'level_10',
        title: 'Level Master',
        description: 'Reach level 10',
        icon: Icons.trending_up,
        isUnlocked: player.level >= 10,
        progress: (player.level / 10).clamp(0.0, 1.0),
        color: Colors.green,
      ),
      Achievement(
        id: 'skins_5',
        title: 'Fashionista',
        description: 'Unlock 5 different skins',
        icon: Icons.palette,
        isUnlocked: player.skins.length >= 5,
        progress: (player.skins.length / 5).clamp(0.0, 1.0),
        color: Colors.purple,
      ),
      Achievement(
        id: 'perfect_game',
        title: 'Perfect Run',
        description: 'Complete a game without hitting obstacles',
        icon: Icons.dangerous,
        isUnlocked: false, // This would be tracked separately
        progress: 0.0,
        color: Colors.red,
      ),
    ];
  }

  Widget _buildAchievementItem(
    BuildContext context, {
    required Achievement achievement,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.isUnlocked 
            ? achievement.color.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked 
              ? achievement.color.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Achievement Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: achievement.isUnlocked 
                  ? achievement.color.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              achievement.icon,
              color: achievement.isUnlocked 
                  ? achievement.color
                  : Colors.white.withOpacity(0.3),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Achievement Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: achievement.isUnlocked 
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: achievement.isUnlocked 
                        ? Colors.white70
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Progress Bar
                if (!achievement.isUnlocked)
                  LinearProgressIndicator(
                    value: achievement.progress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
                    minHeight: 4,
                  ),
              ],
            ),
          ),
          
          // Unlock Status
          if (achievement.isUnlocked)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: achievement.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.check,
                color: achievement.color,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final double progress;
  final Color color;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.progress,
    required this.color,
  });
}
