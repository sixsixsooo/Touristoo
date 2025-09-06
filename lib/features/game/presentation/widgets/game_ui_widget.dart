import 'package:flutter/material.dart';

import '../../../../core/models/game_models.dart';

class GameUIWidget extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final bool isPaused;

  const GameUIWidget({
    super.key,
    required this.gameState,
    required this.onPause,
    required this.onResume,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Top UI Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score and Distance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score: ${gameState.score}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Distance: ${gameState.distance.toStringAsFixed(0)}m',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        shadows: [
                          const Shadow(
                            color: Colors.black,
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Health Bar
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 120 * (gameState.playerHealth / 100),
                        height: 20,
                        decoration: BoxDecoration(
                          color: _getHealthColor(gameState.playerHealth),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Center(
                        child: Text(
                          '${gameState.playerHealth}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 2,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Pause Button
                IconButton(
                  onPressed: isPaused ? onResume : onPause,
                  icon: Icon(
                    isPaused ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                    size: 32,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Bottom UI
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Coins
                _buildStatItem(
                  context,
                  icon: Icons.monetization_on,
                  value: gameState.coins.toString(),
                  color: Colors.yellow,
                ),
                
                // Level
                _buildStatItem(
                  context,
                  icon: Icons.trending_up,
                  value: gameState.currentLevel.toString(),
                  color: Colors.blue,
                ),
                
                // Speed
                _buildStatItem(
                  context,
                  icon: Icons.speed,
                  value: '${(gameState.distance / 100).floor() + 1}x',
                  color: Colors.green,
                ),
              ],
            ),
          ),
          
          // Controls Hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Tap left/right to change lanes',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                shadows: [
                  const Shadow(
                    color: Colors.black,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              shadows: [
                const Shadow(
                  color: Colors.black,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getHealthColor(int health) {
    if (health > 70) return Colors.green;
    if (health > 40) return Colors.yellow;
    if (health > 20) return Colors.orange;
    return Colors.red;
  }
}
