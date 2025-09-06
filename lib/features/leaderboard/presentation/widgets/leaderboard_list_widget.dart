import 'package:flutter/material.dart';

import '../../../../core/models/game_models.dart';

class LeaderboardListWidget extends StatelessWidget {
  final String timeRange;
  final Function(String) onPlayerTap;

  const LeaderboardListWidget({
    super.key,
    required this.timeRange,
    required this.onPlayerTap,
  });

  @override
  Widget build(BuildContext context) {
    final leaderboard = _getLeaderboardData();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final entry = leaderboard[index];
        return _buildLeaderboardItem(context, entry, index + 1);
      },
    );
  }

  List<LeaderboardEntry> _getLeaderboardData() {
    // This would come from actual API data
    return [
      const LeaderboardEntry(
        id: '1',
        playerName: 'ProGamer123',
        score: 15420,
        rank: 1,
        isGuest: false,
      ),
      const LeaderboardEntry(
        id: '2',
        playerName: 'SpeedRunner',
        score: 14200,
        rank: 2,
        isGuest: false,
      ),
      const LeaderboardEntry(
        id: '3',
        playerName: 'TouristMaster',
        score: 13850,
        rank: 3,
        isGuest: false,
      ),
      const LeaderboardEntry(
        id: '4',
        playerName: 'Guest_456',
        score: 12500,
        rank: 4,
        isGuest: true,
      ),
      const LeaderboardEntry(
        id: '5',
        playerName: 'RunnerPro',
        score: 11800,
        rank: 5,
        isGuest: false,
      ),
      const LeaderboardEntry(
        id: '6',
        playerName: 'Guest_789',
        score: 11200,
        rank: 6,
        isGuest: true,
      ),
      const LeaderboardEntry(
        id: '7',
        playerName: 'FastFeet',
        score: 10800,
        rank: 7,
        isGuest: false,
      ),
      const LeaderboardEntry(
        id: '8',
        playerName: 'TouristKing',
        score: 10200,
        rank: 8,
        isGuest: false,
      ),
      const LeaderboardEntry(
        id: '9',
        playerName: 'Guest_321',
        score: 9800,
        rank: 9,
        isGuest: true,
      ),
      const LeaderboardEntry(
        id: '10',
        playerName: 'SpeedDemon',
        score: 9500,
        rank: 10,
        isGuest: false,
      ),
    ];
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    LeaderboardEntry entry,
    int position,
  ) {
    final isTopThree = position <= 3;
    final rankColor = _getRankColor(position);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTopThree 
            ? rankColor.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTopThree 
              ? rankColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTopThree 
                  ? rankColor.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: isTopThree
                  ? Icon(
                      _getRankIcon(position),
                      color: rankColor,
                      size: 20,
                    )
                  : Text(
                      position.toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Player Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4A90E2).withOpacity(0.8),
                  const Color(0xFF7B68EE).withOpacity(0.8),
                ],
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 20,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Player Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.playerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (entry.isGuest)
                  Text(
                    'Guest Player',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
          
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.score.toString(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isTopThree ? rankColor : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'points',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.orange;
      default:
        return Colors.white;
    }
  }

  IconData _getRankIcon(int position) {
    switch (position) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.medal;
      case 3:
        return Icons.military_tech;
      default:
        return Icons.person;
    }
  }
}
