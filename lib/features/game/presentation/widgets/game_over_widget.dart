import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/game_providers.dart';
import '../../../ads/presentation/widgets/rewarded_ad_button.dart';

class GameOverWidget extends ConsumerWidget {
  final int score;
  final double distance;
  final bool isNewRecord;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;
  final VoidCallback onShare;

  const GameOverWidget({
    super.key,
    required this.score,
    required this.distance,
    required this.isNewRecord,
    required this.onPlayAgain,
    required this.onHome,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Game Over Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_esports,
                  color: Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  'GAME OVER',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // New Record Badge
            if (isNewRecord)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'NEW RECORD!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            
            if (isNewRecord) const SizedBox(height: 24),
            
            // Score Display
            Container(
              padding: const EdgeInsets.all(24),
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
                  // Score
                  Text(
                    'SCORE',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    score.toString(),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Distance
                  Text(
                    'DISTANCE',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${distance.toStringAsFixed(0)}m',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: const Color(0xFF4A90E2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
              // Action Buttons
              Column(
                children: [
                  // Play Again Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onPlayAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF4A90E2).withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'PLAY AGAIN',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Rewarded Ad Buttons
                  RewardedAdButton(
                    title: 'Получить дополнительную жизнь',
                    description: 'Посмотрите рекламу',
                    icon: Icons.favorite,
                    onRewardEarned: () {
                      // Дать игроку дополнительную жизнь
                      ref.read(gameStateProvider.notifier).updateHealth(50);
                      onPlayAgain();
                    },
                    backgroundColor: const Color(0xFFE74C3C),
                  ),
                  
                  RewardedAdButton(
                    title: 'Получить бонусные монеты',
                    description: 'Посмотрите рекламу',
                    icon: Icons.monetization_on,
                    onRewardEarned: () {
                      // Дать игроку бонусные монеты
                      ref.read(gameStateProvider.notifier).addCoins(50);
                    },
                    backgroundColor: const Color(0xFFFFD700),
                    textColor: Colors.black,
                  ),
                
                const SizedBox(height: 16),
                
                // Share and Home Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: onShare,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF7B68EE),
                            side: const BorderSide(color: Color(0xFF7B68EE), width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.share, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                'SHARE',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: onHome,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE74C3C),
                            side: const BorderSide(color: Color(0xFFE74C3C), width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.home, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                'HOME',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
