import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../config/app_config.dart';
import '../models/game_models.dart';
import 'vk_cloud_service.dart';

class DataService {
  static DataService? _instance;
  static DataService get instance => _instance ??= DataService._();
  
  DataService._();

  Database? _database;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Инициализация SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      // Инициализация SQLite
      await _initDatabase();

      // Инициализация VK Cloud
      await VKCloudService.instance.initialize();

      _isInitialized = true;
      print('DataService initialized successfully');
    } catch (e) {
      print('Failed to initialize DataService: $e');
      rethrow;
    }
  }

  Future<void> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'touristoo.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Таблица игроков
        await db.execute('''
          CREATE TABLE players (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            avatar TEXT,
            is_guest INTEGER NOT NULL DEFAULT 1,
            coins INTEGER NOT NULL DEFAULT 0,
            level INTEGER NOT NULL DEFAULT 1,
            experience INTEGER NOT NULL DEFAULT 0,
            current_skin TEXT NOT NULL DEFAULT 'default',
            unlocked_skins TEXT NOT NULL DEFAULT '["default"]',
            created_at INTEGER NOT NULL,
            last_played INTEGER NOT NULL
          )
        ''');

        // Таблица рекордов
        await db.execute('''
          CREATE TABLE scores (
            id TEXT PRIMARY KEY,
            player_id TEXT NOT NULL,
            score INTEGER NOT NULL,
            distance REAL NOT NULL,
            timestamp INTEGER NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (player_id) REFERENCES players (id)
          )
        ''');

        // Таблица покупок
        await db.execute('''
          CREATE TABLE purchases (
            id TEXT PRIMARY KEY,
            player_id TEXT NOT NULL,
            item_id TEXT NOT NULL,
            item_type TEXT NOT NULL,
            price REAL NOT NULL,
            currency TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (player_id) REFERENCES players (id)
          )
        ''');

        // Таблица настроек
        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Работа с игроками
  Future<void> savePlayer(Player player) async {
    if (_database == null) await initialize();

    await _database!.insert(
      'players',
      {
        'id': player.id,
        'name': player.name,
        'avatar': player.avatar,
        'is_guest': player.isGuest ? 1 : 0,
        'coins': player.coins,
        'level': player.level,
        'experience': player.experience,
        'current_skin': player.currentSkin,
        'unlocked_skins': jsonEncode(player.unlockedSkins),
        'created_at': player.createdAt.millisecondsSinceEpoch,
        'last_played': player.lastPlayed.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Player?> getPlayer(String playerId) async {
    if (_database == null) await initialize();

    final List<Map<String, dynamic>> maps = await _database!.query(
      'players',
      where: 'id = ?',
      whereArgs: [playerId],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return Player(
      id: map['id'],
      name: map['name'],
      avatar: map['avatar'],
      isGuest: map['is_guest'] == 1,
      coins: map['coins'],
      level: map['level'],
      experience: map['experience'],
      currentSkin: map['current_skin'],
      unlockedSkins: List<String>.from(jsonDecode(map['unlocked_skins'])),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      lastPlayed: DateTime.fromMillisecondsSinceEpoch(map['last_played']),
    );
  }

  // Работа с рекордами
  Future<void> saveScore(String playerId, int score, double distance) async {
    if (_database == null) await initialize();

    await _database!.insert('scores', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'player_id': playerId,
      'score': score,
      'distance': distance,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'synced': 0,
    });
  }

  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 10}) async {
    if (_database == null) await initialize();

    try {
      // Сначала пытаемся получить данные из VK Cloud
      final isConnected = await VKCloudService.instance.isConnected();
      if (isConnected) {
        final cloudData = await VKCloudService.instance.getLeaderboard(limit: limit);
        if (cloudData.isNotEmpty) {
          return cloudData.map((map) => LeaderboardEntry(
            id: map['id'] ?? '',
            playerName: map['player_name'] ?? 'Unknown',
            score: map['score'] ?? 0,
            rank: map['rank'] ?? 0,
            avatar: map['avatar'],
            isGuest: map['is_guest'] ?? true,
          )).toList();
        }
      }

      // Если нет интернета или данные не получены, используем локальную базу
      final List<Map<String, dynamic>> maps = await _database!.rawQuery('''
        SELECT 
          p.id,
          p.name as player_name,
          s.score,
          s.distance,
          p.avatar,
          p.is_guest,
          ROW_NUMBER() OVER (ORDER BY s.score DESC) as rank
        FROM scores s
        JOIN players p ON s.player_id = p.id
        ORDER BY s.score DESC
        LIMIT ?
      ''', [limit]);

      return maps.map((map) => LeaderboardEntry(
        id: map['id'],
        playerName: map['player_name'],
        score: map['score'],
        rank: map['rank'],
        avatar: map['avatar'],
        isGuest: map['is_guest'] == 1,
      )).toList();
    } catch (e) {
      print('Failed to get leaderboard: $e');
      return [];
    }
  }

  // Работа с настройками
  Future<void> saveSettings(GameSettings settings) async {
    if (_database == null) await initialize();

    await _database!.insert(
      'settings',
      {
        'key': 'game_settings',
        'value': jsonEncode(settings.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<GameSettings> getSettings() async {
    if (_database == null) await initialize();

    final List<Map<String, dynamic>> maps = await _database!.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['game_settings'],
    );

    if (maps.isEmpty) {
      return const GameSettings();
    }

    final settingsJson = jsonDecode(maps.first['value']);
    return GameSettings.fromJson(settingsJson);
  }

  // Синхронизация с VK Cloud
  Future<void> syncWithServer() async {
    try {
      if (_database == null) await initialize();

      // Проверяем соединение с VK Cloud
      final isConnected = await VKCloudService.instance.isConnected();
      if (!isConnected) {
        print('No internet connection, skipping sync');
        return;
      }

      // Синхронизируем несинхронизированные рекорды
      final unsyncedScores = await _database!.query(
        'scores',
        where: 'synced = ?',
        whereArgs: [0],
      );

      for (final score in unsyncedScores) {
        await VKCloudService.instance.saveScore(
          score['player_id'],
          score['score'],
          score['distance'],
        );
      }

      // Синхронизируем несинхронизированные покупки
      final unsyncedPurchases = await _database!.query(
        'purchases',
        where: 'synced = ?',
        whereArgs: [0],
      );

      for (final purchase in unsyncedPurchases) {
        await VKCloudService.instance.logPurchase(
          purchase['item_id'],
          purchase['price'].toDouble(),
        );
      }

      // Помечаем данные как синхронизированные
      await _database!.update(
        'scores',
        {'synced': 1},
        where: 'synced = ?',
        whereArgs: [0],
      );

      await _database!.update(
        'purchases',
        {'synced': 1},
        where: 'synced = ?',
        whereArgs: [0],
      );

      print('Data synced with VK Cloud');
    } catch (e) {
      print('Failed to sync with VK Cloud: $e');
    }
  }

  // Очистка старых данных
  Future<void> cleanupOldData() async {
    if (_database == null) await initialize();

    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    
    await _database!.delete(
      'scores',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
    );
  }

  // Закрытие базы данных
  Future<void> close() async {
    await _database?.close();
  }
}
