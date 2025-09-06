import 'package:flutter/foundation.dart';
import '../models/game_models.dart';

class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState.initial();

  GameState get gameState => _gameState;

  void startGame() {
    _gameState = GameState.initial().copyWith(
      isRunning: true,
      isPaused: false,
    );
    notifyListeners();
  }

  void pauseGame() {
    _gameState = _gameState.copyWith(isPaused: true);
    notifyListeners();
  }

  void resumeGame() {
    _gameState = _gameState.copyWith(isPaused: false);
    notifyListeners();
  }

  void endGame() {
    _gameState = _gameState.copyWith(
      isRunning: false,
      isPaused: false,
    );
    notifyListeners();
  }

  void addScore(int points) {
    _gameState = _gameState.copyWith(
      score: _gameState.score + points,
    );
    notifyListeners();
  }

  void addCoins(int coins) {
    _gameState = _gameState.copyWith(
      coins: _gameState.coins + coins,
    );
    notifyListeners();
  }

  void takeDamage(int damage) {
    _gameState = _gameState.copyWith(
      playerHealth: (_gameState.playerHealth - damage).clamp(0, _gameState.maxHealth),
    );
    notifyListeners();
  }

  void heal(int amount) {
    _gameState = _gameState.copyWith(
      playerHealth: (_gameState.playerHealth + amount).clamp(0, _gameState.maxHealth),
    );
    notifyListeners();
  }

  void updateDistance(double distance) {
    _gameState = _gameState.copyWith(distance: distance);
    notifyListeners();
  }

  void levelUp() {
    _gameState = _gameState.copyWith(
      currentLevel: _gameState.currentLevel + 1,
    );
    notifyListeners();
  }

  void moveToLane(int lane) {
    if (lane >= 0 && lane <= 2) {
      _gameState = _gameState.copyWith(currentLane: lane);
      notifyListeners();
    }
  }

  void increaseSpeed() {
    _gameState = _gameState.copyWith(
      gameSpeed: (_gameState.gameSpeed + 1.0).clamp(5.0, 15.0),
    );
    notifyListeners();
  }

  void addShield() {
    // Заглушка для щита - можно добавить логику защиты
    addScore(50);
  }

  void addPowerUp(PowerUp powerUp) {
    final newPowerUps = List<PowerUp>.from(_gameState.collectedPowerUps);
    newPowerUps.add(powerUp);
    _gameState = _gameState.copyWith(collectedPowerUps: newPowerUps);
    notifyListeners();
  }

  void startBossFight() {
    _gameState = _gameState.copyWith(
      isBossFight: true,
      bossHealth: 200,
      maxBossHealth: 200,
    );
    notifyListeners();
  }

  void attackBoss(int damage) {
    if (_gameState.isBossFight) {
      final newBossHealth = (_gameState.bossHealth - damage).clamp(0, _gameState.maxBossHealth);
      _gameState = _gameState.copyWith(bossHealth: newBossHealth);
      
      if (newBossHealth <= 0) {
        _winBossFight();
      }
      notifyListeners();
    }
  }

  void _winBossFight() {
    _gameState = _gameState.copyWith(
      isBossFight: false,
      score: _gameState.score + 1000,
      currentLevel: _gameState.currentLevel + 1,
    );
    notifyListeners();
  }
}