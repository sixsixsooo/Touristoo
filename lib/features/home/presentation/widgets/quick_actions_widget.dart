import 'package:flutter/material.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onPlay;
  final VoidCallback onShop;
  final VoidCallback onLeaderboard;
  final VoidCallback onProfile;

  const QuickActionsWidget({
    super.key,
    required this.onPlay,
    required this.onShop,
    required this.onLeaderboard,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Play Button
          Container(
            width: double.infinity,
            height: 60,
            margin: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: onPlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF4A90E2).withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 32),
                  const SizedBox(width: 8),
                  Text(
                    'PLAY NOW',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.shopping_bag,
                  label: 'Shop',
                  color: const Color(0xFF7B68EE),
                  onTap: onShop,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.leaderboard,
                  label: 'Leaderboard',
                  color: const Color(0xFF2ECC71),
                  onTap: onLeaderboard,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
