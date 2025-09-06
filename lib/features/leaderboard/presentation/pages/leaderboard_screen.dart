import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/game_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/game_models.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рейтинг'),
        backgroundColor: const Color(0xFF1E3C72),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
            ],
          ),
        ),
        child: Consumer2<GameProvider, AuthProvider>(
          builder: (context, gameProvider, authProvider, child) {
            if (gameProvider.leaderboard.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await gameProvider.initialize();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: gameProvider.leaderboard.length,
                itemBuilder: (context, index) {
                  final entry = gameProvider.leaderboard[index];
                  final isCurrentPlayer = authProvider.currentPlayer?.id == entry.id;
                  
                  return _buildLeaderboardEntry(
                    context,
                    entry,
                    index + 1,
                    isCurrentPlayer,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeaderboardEntry(
    BuildContext context,
    LeaderboardEntry entry,
    int rank,
    bool isCurrentPlayer,
  ) {
    Color rankColor;
    IconData rankIcon;
    
    switch (rank) {
      case 1:
        rankColor = const Color(0xFFFFD700);
        rankIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0);
        rankIcon = Icons.emoji_events;
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32);
        rankIcon = Icons.emoji_events;
        break;
      default:
        rankColor = Colors.white;
        rankIcon = Icons.person;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentPlayer 
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCurrentPlayer 
              ? Colors.white.withOpacity(0.5)
              : Colors.white.withOpacity(0.2),
          width: isCurrentPlayer ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: rankColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: rankColor, width: 2),
          ),
          child: Center(
            child: rank <= 3
                ? Icon(rankIcon, color: rankColor, size: 24)
                : Text(
                    '$rank',
                    style: TextStyle(
                      color: rankColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        title: Row(
          children: [
            Text(
              entry.playerName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (entry.isGuest) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Гость',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            if (isCurrentPlayer) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Вы',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${entry.score} очков',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '#$rank',
              style: TextStyle(
                color: rankColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (rank <= 3)
              Icon(
                rankIcon,
                color: rankColor,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
