import 'package:flutter/foundation.dart';
import '../models/game_models.dart';

class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState.initial();

  GameState get gameState => _gameState;

  void startGame() {
    _gameState = _gameState.copyWith(
      isRunning: true,
      isPaused: false,
      score: 0,
      distance: 0.0,
      coins: 0,
      playerHealth: 100,
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
}