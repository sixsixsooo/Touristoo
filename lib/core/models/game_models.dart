// Простые модели данных для игры
import 'dart:math';

// Game State
class GameState {
  final int score;
  final double distance;
  final int coins;
  final bool isRunning;
  final bool isPaused;
  final int currentLevel;
  final int playerHealth;
  final int maxHealth;
  final int currentLane; // 0 = левая, 1 = центр, 2 = правая
  final double gameSpeed;
  final List<PowerUp> collectedPowerUps;
  final bool isBossFight;
  final int bossHealth;
  final int maxBossHealth;

  const GameState({
    required this.score,
    required this.distance,
    required this.coins,
    required this.isRunning,
    required this.isPaused,
    required this.currentLevel,
    required this.playerHealth,
    required this.maxHealth,
    required this.currentLane,
    required this.gameSpeed,
    required this.collectedPowerUps,
    required this.isBossFight,
    required this.bossHealth,
    required this.maxBossHealth,
  });

  factory GameState.initial() => const GameState(
    score: 0,
    distance: 0.0,
    coins: 0,
    isRunning: false,
    isPaused: false,
    currentLevel: 1,
    playerHealth: 100,
    maxHealth: 100,
    currentLane: 1, // Начинаем в центральной дорожке
    gameSpeed: 5.0,
    collectedPowerUps: [],
    isBossFight: false,
    bossHealth: 0,
    maxBossHealth: 0,
  );

  GameState copyWith({
    int? score,
    double? distance,
    int? coins,
    bool? isRunning,
    bool? isPaused,
    int? currentLevel,
    int? playerHealth,
    int? maxHealth,
    int? currentLane,
    double? gameSpeed,
    List<PowerUp>? collectedPowerUps,
    bool? isBossFight,
    int? bossHealth,
    int? maxBossHealth,
  }) {
    return GameState(
      score: score ?? this.score,
      distance: distance ?? this.distance,
      coins: coins ?? this.coins,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      currentLevel: currentLevel ?? this.currentLevel,
      playerHealth: playerHealth ?? this.playerHealth,
      maxHealth: maxHealth ?? this.maxHealth,
      currentLane: currentLane ?? this.currentLane,
      gameSpeed: gameSpeed ?? this.gameSpeed,
      collectedPowerUps: collectedPowerUps ?? this.collectedPowerUps,
      isBossFight: isBossFight ?? this.isBossFight,
      bossHealth: bossHealth ?? this.bossHealth,
      maxBossHealth: maxBossHealth ?? this.maxBossHealth,
    );
  }
}

// Player
class Player {
  final String id;
  final String name;
  final int level;
  final int coins;
  final int bestScore;
  final DateTime createdAt;

  const Player({
    required this.id,
    required this.name,
    required this.level,
    required this.coins,
    required this.bestScore,
    required this.createdAt,
  });

  factory Player.guest() => Player(
    id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
    name: 'Гость',
    level: 1,
    coins: 0,
    bestScore: 0,
    createdAt: DateTime.now(),
  );
}

// Leaderboard Entry
class LeaderboardEntry {
  final String playerName;
  final int score;
  final int rank;

  const LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.rank,
  });
}

// Game Settings
class GameSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final String graphicsQuality;
  final double controlSensitivity;

  const GameSettings({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.vibrationEnabled,
    required this.graphicsQuality,
    required this.controlSensitivity,
  });

  factory GameSettings.defaultSettings() => const GameSettings(
    soundEnabled: true,
    musicEnabled: true,
    vibrationEnabled: true,
    graphicsQuality: 'medium',
    controlSensitivity: 1.0,
  );
}

// Vector3 для 3D позиций
class Vector3 {
  final double x;
  final double y;
  final double z;

  const Vector3(this.x, this.y, this.z);

  Vector3 operator +(Vector3 other) => Vector3(x + other.x, y + other.y, z + other.z);
  Vector3 operator -(Vector3 other) => Vector3(x - other.x, y - other.y, z - other.z);
  Vector3 operator *(double scalar) => Vector3(x * scalar, y * scalar, z * scalar);

  double distanceTo(Vector3 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final dz = z - other.z;
    return sqrt(dx * dx + dy * dy + dz * dz);
  }
}

// Obstacle
class Obstacle {
  final Vector3 position;
  final String type;
  final double damage;

  const Obstacle({
    required this.position,
    required this.type,
    required this.damage,
  });
}

// Coin
class Coin {
  final Vector3 position;
  final int value;

  const Coin({
    required this.position,
    required this.value,
  });
}

// PowerUp
enum PowerUpType { 
  health,      // Восстановление здоровья
  speed,       // Увеличение скорости
  shield,      // Щит от урона
  fireball,    // Огненный шар для атаки босса
  lightning,   // Молния для атаки босса
  ice,         // Лед для замедления босса
  coin         // Монета
}

class PowerUp {
  final Vector3 position;
  final PowerUpType type;
  final double value;
  final int lane; // На какой дорожке находится (0, 1, 2)

  const PowerUp({
    required this.position,
    required this.type,
    required this.value,
    required this.lane,
  });
}

// Skin
class Skin {
  final String id;
  final String name;
  final String description;
  final int price;
  final bool isUnlocked;

  const Skin({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isUnlocked,
  });
}

// Purchase
class Purchase {
  final String id;
  final String itemId;
  final double price;
  final DateTime purchaseDate;

  const Purchase({
    required this.id,
    required this.itemId,
    required this.price,
    required this.purchaseDate,
  });
}

// API Response
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });
}

// Login Request
class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({
    required this.username,
    required this.password,
  });
}

// Login Response
class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final Player? player;

  const LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.player,
  });
}