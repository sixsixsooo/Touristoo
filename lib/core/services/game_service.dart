import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_models.dart';
import '../config/app_config.dart';

final gameServiceProvider = Provider<GameService>((ref) {
  return GameService();
});

class GameService {
  static final GameService _instance = GameService._internal();
  factory GameService() => _instance;
  GameService._internal();

  final Random _random = Random();

  // Game Logic
  double calculateGameSpeed(double distance, int level) {
    final baseSpeed = AppConfig.initialGameSpeed;
    final distanceMultiplier = distance / 1000; // Increase speed every 1000 units
    final levelMultiplier = level * 0.5;
    
    return (baseSpeed + distanceMultiplier + levelMultiplier)
        .clamp(AppConfig.initialGameSpeed, AppConfig.maxGameSpeed);
  }

  int calculateScore(double distance, int coins, int level) {
    final distanceScore = (distance / 10).round();
    final coinScore = coins * AppConfig.coinValue;
    final levelBonus = level * 100;
    
    return distanceScore + coinScore + levelBonus;
  }

  int calculateLevel(double distance) {
    return (distance / 1000).floor() + 1;
  }

  // Obstacle Generation
  List<Obstacle> generateObstacles(int count, double currentDistance) {
    final obstacles = <Obstacle>[];
    
    for (int i = 0; i < count; i++) {
      final obstacle = Obstacle(
        id: 'obstacle_${DateTime.now().millisecondsSinceEpoch}_$i',
        type: _getRandomObstacleType(),
        position: Vector3(
          _getRandomLanePosition(),
          0,
          -currentDistance - (i * 20) - 50,
        ),
        speed: calculateGameSpeed(currentDistance, calculateLevel(currentDistance)),
        isActive: true,
      );
      obstacles.add(obstacle);
    }
    
    return obstacles;
  }

  ObstacleType _getRandomObstacleType() {
    final types = ObstacleType.values;
    return types[_random.nextInt(types.length)];
  }

  double _getRandomLanePosition() {
    final lanes = [-2.0, 0.0, 2.0];
    return lanes[_random.nextInt(lanes.length)];
  }

  // Power-up Generation
  List<PowerUp> generatePowerUps(int count, double currentDistance) {
    final powerUps = <PowerUp>[];
    
    for (int i = 0; i < count; i++) {
      final powerUp = PowerUp(
        id: 'powerup_${DateTime.now().millisecondsSinceEpoch}_$i',
        type: _getRandomPowerUpType(),
        position: Vector3(
          _getRandomLanePosition(),
          1.5,
          -currentDistance - (i * 15) - 30,
        ),
        value: _getPowerUpValue(_getRandomPowerUpType()),
        isActive: true,
      );
      powerUps.add(powerUp);
    }
    
    return powerUps;
  }

  PowerUpType _getRandomPowerUpType() {
    final types = PowerUpType.values;
    return types[_random.nextInt(types.length)];
  }

  int _getPowerUpValue(PowerUpType type) {
    switch (type) {
      case PowerUpType.coin:
        return 1;
      case PowerUpType.health:
        return 20;
      case PowerUpType.speed:
        return 5;
      case PowerUpType.shield:
        return 1;
    }
  }

  // Collision Detection
  bool checkCollision(Vector3 playerPos, Vector3 objectPos, double radius) {
    final distance = sqrt(
      pow(playerPos.x - objectPos.x, 2) +
      pow(playerPos.y - objectPos.y, 2) +
      pow(playerPos.z - objectPos.z, 2),
    );
    return distance < radius;
  }

  // Game State Updates
  GameState updateGameState(
    GameState currentState,
    double deltaTime,
    List<Obstacle> obstacles,
    List<PowerUp> powerUps,
    Vector3 playerPosition,
  ) {
    final newDistance = currentState.distance + (currentState.isRunning ? deltaTime * calculateGameSpeed(currentState.distance, currentState.currentLevel) : 0);
    final newLevel = calculateLevel(newDistance);
    final newScore = calculateScore(newDistance, currentState.coins, newLevel);
    
    // Check for level up
    final levelUp = newLevel > currentState.currentLevel;
    
    // Check collisions with obstacles
    int newHealth = currentState.playerHealth;
    for (final obstacle in obstacles) {
      if (obstacle.isActive && checkCollision(playerPosition, obstacle.position, 1.0)) {
        newHealth = (newHealth - AppConfig.obstacleDamage).clamp(0, AppConfig.maxHealth);
        break;
      }
    }
    
    // Check collisions with power-ups
    int newCoins = currentState.coins;
    for (final powerUp in powerUps) {
      if (powerUp.isActive && checkCollision(playerPosition, powerUp.position, 0.8)) {
        switch (powerUp.type) {
          case PowerUpType.coin:
            newCoins += powerUp.value;
            break;
          case PowerUpType.health:
            newHealth = (newHealth + powerUp.value).clamp(0, AppConfig.maxHealth);
            break;
          case PowerUpType.speed:
            // Speed boost is handled in game speed calculation
            break;
          case PowerUpType.shield:
            // Shield logic would be implemented here
            break;
        }
        // Mark power-up as collected
        powerUp.isActive = false;
      }
    }
    
    return currentState.copyWith(
      score: newScore,
      distance: newDistance,
      coins: newCoins,
      currentLevel: newLevel,
      playerHealth: newHealth,
      isRunning: newHealth > 0 && currentState.isRunning,
    );
  }

  // Skin Management
  List<Skin> getAvailableSkins() {
    return [
      const Skin(
        id: 'default',
        name: 'Default Runner',
        description: 'The classic tourist runner',
        price: 0,
        isUnlocked: true,
        modelPath: 'models/characters/default.obj',
        texturePath: 'textures/characters/default.png',
        rarity: SkinRarity.common,
      ),
      const Skin(
        id: 'explorer',
        name: 'Explorer',
        description: 'An adventurous explorer',
        price: 100,
        isUnlocked: false,
        modelPath: 'models/characters/explorer.obj',
        texturePath: 'textures/characters/explorer.png',
        rarity: SkinRarity.rare,
      ),
      const Skin(
        id: 'ninja',
        name: 'Ninja Tourist',
        description: 'A stealthy ninja tourist',
        price: 500,
        isUnlocked: false,
        modelPath: 'models/characters/ninja.obj',
        texturePath: 'textures/characters/ninja.png',
        rarity: SkinRarity.epic,
      ),
      const Skin(
        id: 'cyber',
        name: 'Cyber Tourist',
        description: 'A futuristic cyber tourist',
        price: 1000,
        isUnlocked: false,
        modelPath: 'models/characters/cyber.obj',
        texturePath: 'textures/characters/cyber.png',
        rarity: SkinRarity.legendary,
      ),
    ];
  }

  // Achievement System
  List<String> checkAchievements(GameState gameState) {
    final achievements = <String>[];
    
    if (gameState.score >= 1000 && !gameState.isRunning) {
      achievements.add('first_thousand');
    }
    
    if (gameState.distance >= 5000 && !gameState.isRunning) {
      achievements.add('marathon_runner');
    }
    
    if (gameState.coins >= 100) {
      achievements.add('coin_collector');
    }
    
    if (gameState.currentLevel >= 10) {
      achievements.add('level_master');
    }
    
    return achievements;
  }
}
