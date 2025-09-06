import 'package:json_annotation/json_annotation.dart';

part 'game_models.g.dart';

// Game State
@JsonSerializable()
class GameState {
  final int score;
  final double distance;
  final int coins;
  final bool isRunning;
  final bool isPaused;
  final int currentLevel;
  final int playerHealth;
  final int maxHealth;

  const GameState({
    required this.score,
    required this.distance,
    required this.coins,
    required this.isRunning,
    required this.isPaused,
    required this.currentLevel,
    required this.playerHealth,
    required this.maxHealth,
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
    );
  }

  factory GameState.fromJson(Map<String, dynamic> json) => _$GameStateFromJson(json);
  Map<String, dynamic> toJson() => _$GameStateToJson(this);
}

// Player
@JsonSerializable()
class Player {
  final String id;
  final String name;
  final String? email;
  final String? avatar;
  final int totalScore;
  final int level;
  final int coins;
  final List<String> skins;
  final String currentSkin;
  final bool isGuest;
  final DateTime? lastSyncAt;

  const Player({
    required this.id,
    required this.name,
    this.email,
    this.avatar,
    required this.totalScore,
    required this.level,
    required this.coins,
    required this.skins,
    required this.currentSkin,
    required this.isGuest,
    this.lastSyncAt,
  });

  factory Player.guest() => Player(
    id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
    name: 'Guest',
    totalScore: 0,
    level: 1,
    coins: 0,
    skins: const ['default'],
    currentSkin: 'default',
    isGuest: true,
  );

  Player copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    int? totalScore,
    int? level,
    int? coins,
    List<String>? skins,
    String? currentSkin,
    bool? isGuest,
    DateTime? lastSyncAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      totalScore: totalScore ?? this.totalScore,
      level: level ?? this.level,
      coins: coins ?? this.coins,
      skins: skins ?? this.skins,
      currentSkin: currentSkin ?? this.currentSkin,
      isGuest: isGuest ?? this.isGuest,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}

// Leaderboard Entry
@JsonSerializable()
class LeaderboardEntry {
  final String id;
  final String playerName;
  final int score;
  final int rank;
  final String? avatar;
  final bool isGuest;

  const LeaderboardEntry({
    required this.id,
    required this.playerName,
    required this.score,
    required this.rank,
    this.avatar,
    required this.isGuest,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => _$LeaderboardEntryFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardEntryToJson(this);
}

// Game Settings
enum GraphicsQuality { low, medium, high }

@JsonSerializable()
class GameSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final GraphicsQuality graphicsQuality;
  final double controlsSensitivity;

  const GameSettings({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.vibrationEnabled,
    required this.graphicsQuality,
    required this.controlsSensitivity,
  });

  factory GameSettings.defaultSettings() => const GameSettings(
    soundEnabled: true,
    musicEnabled: true,
    vibrationEnabled: true,
    graphicsQuality: GraphicsQuality.high,
    controlsSensitivity: 1.0,
  );

  GameSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    GraphicsQuality? graphicsQuality,
    double? controlsSensitivity,
  }) {
    return GameSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      graphicsQuality: graphicsQuality ?? this.graphicsQuality,
      controlsSensitivity: controlsSensitivity ?? this.controlsSensitivity,
    );
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) => _$GameSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$GameSettingsToJson(this);
}

// Obstacle
@JsonSerializable()
class Obstacle {
  final String id;
  final ObstacleType type;
  final Vector3 position;
  final double speed;
  final bool isActive;

  const Obstacle({
    required this.id,
    required this.type,
    required this.position,
    required this.speed,
    required this.isActive,
  });

  factory Obstacle.fromJson(Map<String, dynamic> json) => _$ObstacleFromJson(json);
  Map<String, dynamic> toJson() => _$ObstacleToJson(this);
}

enum ObstacleType { jump, slide, duck }

// Power Up
@JsonSerializable()
class PowerUp {
  final String id;
  final PowerUpType type;
  final Vector3 position;
  final int value;
  final bool isActive;

  const PowerUp({
    required this.id,
    required this.type,
    required this.position,
    required this.value,
    required this.isActive,
  });

  factory PowerUp.fromJson(Map<String, dynamic> json) => _$PowerUpFromJson(json);
  Map<String, dynamic> toJson() => _$PowerUpToJson(this);
}

enum PowerUpType { coin, health, speed, shield }

// Vector3
@JsonSerializable()
class Vector3 {
  final double x;
  final double y;
  final double z;

  const Vector3(this.x, this.y, this.z);

  factory Vector3.zero() => const Vector3(0, 0, 0);

  factory Vector3.fromJson(Map<String, dynamic> json) => _$Vector3FromJson(json);
  Map<String, dynamic> toJson() => _$Vector3ToJson(this);
}

// Skin
@JsonSerializable()
class Skin {
  final String id;
  final String name;
  final String description;
  final int price;
  final bool isUnlocked;
  final String modelPath;
  final String texturePath;
  final SkinRarity rarity;

  const Skin({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isUnlocked,
    required this.modelPath,
    required this.texturePath,
    required this.rarity,
  });

  factory Skin.fromJson(Map<String, dynamic> json) => _$SkinFromJson(json);
  Map<String, dynamic> toJson() => _$SkinToJson(this);
}

enum SkinRarity { common, rare, epic, legendary }

// Purchase
@JsonSerializable()
class Purchase {
  final String id;
  final String playerId;
  final PurchaseType itemType;
  final String itemId;
  final int amount;
  final int price;
  final Currency currency;
  final PurchaseStatus status;
  final DateTime createdAt;

  const Purchase({
    required this.id,
    required this.playerId,
    required this.itemType,
    required this.itemId,
    required this.amount,
    required this.price,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) => _$PurchaseFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseToJson(this);
}

enum PurchaseType { skin, coinPack, booster }
enum Currency { rub, coins }
enum PurchaseStatus { pending, completed, failed }

// API Response
@JsonSerializable()
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) => _$ApiResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);
}

// Login Request
@JsonSerializable()
class LoginRequest {
  final String? email;
  final String? password;
  final String? name;
  final String? yandexId;
  final bool? isGuest;

  const LoginRequest({
    this.email,
    this.password,
    this.name,
    this.yandexId,
    this.isGuest,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

// Login Response
@JsonSerializable()
class LoginResponse {
  final Player player;
  final String token;
  final String refreshToken;

  const LoginResponse({
    required this.player,
    required this.token,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
