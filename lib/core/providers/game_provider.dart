import 'package:flutter/foundation.dart';
import '../models/game_models.dart';
import '../services/data_service.dart';

class GameProvider extends ChangeNotifier {
  GameState _gameState = const GameState();
  List<LeaderboardEntry> _leaderboard = [];
  bool _isInitialized = false;

  GameState get gameState => _gameState;
  List<LeaderboardEntry> get leaderboard => _leaderboard;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await DataService.instance.initialize();
      await _loadLeaderboard();
      _isInitialized = true;
      print('GameProvider initialized successfully');
    } catch (e) {
      print('Failed to initialize GameProvider: $e');
      rethrow;
    }
  }

  // Управление игрой
  void startGame() {
    _gameState = _gameState.copyWith(
      isPlaying: true,
      isPaused: false,
      score: 0,
      health: AppConfig.maxHealth,
      distance: 0.0,
      gameSpeed: AppConfig.initialGameSpeed,
      playerPosition: const Vector3(0, 0, 0),
      obstacles: [],
      powerUps: [],
      coins: [],
      gameStartTime: DateTime.now(),
      gameEndTime: null,
    );
    notifyListeners();
  }

  void pauseGame() {
    if (_gameState.isPlaying && !_gameState.isPaused) {
      _gameState = _gameState.copyWith(isPaused: true);
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_gameState.isPlaying && _gameState.isPaused) {
      _gameState = _gameState.copyWith(isPaused: false);
      notifyListeners();
    }
  }

  void endGame() {
    if (_gameState.isPlaying) {
      _gameState = _gameState.copyWith(
        isPlaying: false,
        isPaused: false,
        gameEndTime: DateTime.now(),
      );
      
      // Сохраняем рекорд
      saveScore();
      notifyListeners();
    }
  }

  // Обновление позиции игрока
  void updatePlayerPosition(Vector3 position) {
    if (_gameState.isPlaying && !_gameState.isPaused) {
      _gameState = _gameState.copyWith(playerPosition: position);
      notifyListeners();
    }
  }

  // Прыжок игрока
  void jump() {
    if (_gameState.isPlaying && !_gameState.isPaused) {
      // Простая логика прыжка
      final newPosition = Vector3(
        _gameState.playerPosition.x,
        _gameState.playerPosition.y + 1.0,
        _gameState.playerPosition.z,
      );
      _gameState = _gameState.copyWith(playerPosition: newPosition);
      notifyListeners();
    }
  }

  // Обновление игры (вызывается из игрового цикла)
  void updateGame() {
    if (!_gameState.isPlaying || _gameState.isPaused) return;

    // Увеличиваем дистанцию
    final newDistance = _gameState.distance + _gameState.gameSpeed * 0.1;
    
    // Увеличиваем скорость
    final newSpeed = (_gameState.gameSpeed + AppConfig.speedIncreaseRate * 0.1)
        .clamp(AppConfig.initialGameSpeed, AppConfig.maxGameSpeed);

    // Генерируем препятствия
    final newObstacles = _generateObstacles(_gameState.obstacles, newDistance);

    // Генерируем монеты
    final newCoins = _generateCoins(_gameState.coins, newDistance);

    // Генерируем бонусы
    final newPowerUps = _generatePowerUps(_gameState.powerUps, newDistance);

    // Проверяем столкновения
    final newHealth = _checkCollisions(_gameState.health, newObstacles, newCoins, newPowerUps);

    // Обновляем счет
    final newScore = _gameState.score + (newDistance - _gameState.distance).round();

    _gameState = _gameState.copyWith(
      distance: newDistance,
      gameSpeed: newSpeed,
      obstacles: newObstacles,
      coins: newCoins,
      powerUps: newPowerUps,
      health: newHealth,
      score: newScore,
    );

    // Завершаем игру если здоровье закончилось
    if (newHealth <= 0) {
      endGame();
    }

    notifyListeners();
  }

  // Генерация препятствий
  List<Obstacle> _generateObstacles(List<Obstacle> currentObstacles, double distance) {
    final obstacles = currentObstacles.where((obs) => obs.position.z > -50).toList();
    
    // Добавляем новые препятствия
    if (distance % 10 < 0.1) {
      obstacles.add(Obstacle(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        position: Vector3(
          (DateTime.now().millisecondsSinceEpoch % 3 - 1) * 2.0, // -2, 0, 2
          0,
          -20,
        ),
        type: 'barrier',
        size: 1.0,
        damage: AppConfig.obstacleDamage,
      ));
    }

    return obstacles;
  }

  // Генерация монет
  List<Coin> _generateCoins(List<Coin> currentCoins, double distance) {
    final coins = currentCoins.where((coin) => coin.position.z > -50).toList();
    
    // Добавляем новые монеты
    if (distance % 5 < 0.1) {
      coins.add(Coin(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        position: Vector3(
          (DateTime.now().millisecondsSinceEpoch % 5 - 2) * 1.0, // -2, -1, 0, 1, 2
          0,
          -15,
        ),
        size: 0.5,
        value: AppConfig.coinValue,
      ));
    }

    return coins;
  }

  // Генерация бонусов
  List<PowerUp> _generatePowerUps(List<PowerUp> currentPowerUps, double distance) {
    final powerUps = currentPowerUps.where((pu) => pu.position.z > -50).toList();
    
    // Добавляем новые бонусы
    if (distance % 20 < 0.1) {
      final types = ['health', 'speed', 'shield'];
      powerUps.add(PowerUp(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        position: Vector3(
          (DateTime.now().millisecondsSinceEpoch % 3 - 1) * 2.0,
          0,
          -25,
        ),
        type: types[DateTime.now().millisecondsSinceEpoch % types.length],
        size: 0.8,
        value: 1,
      ));
    }

    return powerUps;
  }

  // Проверка столкновений
  int _checkCollisions(int currentHealth, List<Obstacle> obstacles, List<Coin> coins, List<PowerUp> powerUps) {
    int health = currentHealth;
    final playerPos = _gameState.playerPosition;

    // Проверяем столкновения с препятствиями
    for (final obstacle in obstacles) {
      if (_isColliding(playerPos, obstacle.position, 1.0, obstacle.size)) {
        health -= obstacle.damage;
        // Удаляем препятствие после столкновения
        obstacles.remove(obstacle);
      }
    }

    // Проверяем столкновения с монетами
    for (final coin in coins) {
      if (_isColliding(playerPos, coin.position, 1.0, coin.size)) {
        _gameState = _gameState.copyWith(score: _gameState.score + coin.value);
        // Удаляем монету после сбора
        coins.remove(coin);
      }
    }

    // Проверяем столкновения с бонусами
    for (final powerUp in powerUps) {
      if (_isColliding(playerPos, powerUp.position, 1.0, powerUp.size)) {
        _applyPowerUp(powerUp);
        // Удаляем бонус после сбора
        powerUps.remove(powerUp);
      }
    }

    return health.clamp(0, AppConfig.maxHealth);
  }

  // Применение бонуса
  void _applyPowerUp(PowerUp powerUp) {
    switch (powerUp.type) {
      case 'health':
        _gameState = _gameState.copyWith(
          health: (_gameState.health + 20).clamp(0, AppConfig.maxHealth),
        );
        break;
      case 'speed':
        _gameState = _gameState.copyWith(
          gameSpeed: (_gameState.gameSpeed + 2).clamp(AppConfig.initialGameSpeed, AppConfig.maxGameSpeed),
        );
        break;
      case 'shield':
        // Временная защита (можно реализовать позже)
        break;
    }
  }

  // Проверка столкновения
  bool _isColliding(Vector3 pos1, Vector3 pos2, double radius1, double radius2) {
    final distance = pos1.distanceTo(pos2);
    return distance < (radius1 + radius2);
  }

  // Сохранение рекорда
  Future<void> saveScore() async {
    try {
      await DataService.instance.saveScore(
        'current_player', // Временно используем фиксированный ID
        _gameState.score,
        _gameState.distance,
      );
      
      // Синхронизируем с VK Cloud
      await DataService.instance.syncWithServer();
      
      // Перезагружаем рейтинг
      await _loadLeaderboard();
    } catch (e) {
      debugPrint('Failed to save score: $e');
    }
  }

  // Загрузка рейтинга
  Future<void> _loadLeaderboard() async {
    try {
      _leaderboard = await DataService.instance.getLeaderboard();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load leaderboard: $e');
    }
  }
}
