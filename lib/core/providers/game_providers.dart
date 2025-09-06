import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_models.dart';
import '../services/game_service.dart';
import '../services/audio_service.dart';

// Game State Provider
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(GameState.initial()) {
    _loadGameState();
  }

  static const String _gameStateKey = 'game_state';

  Future<void> _loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final score = prefs.getInt('${_gameStateKey}_score') ?? 0;
    final coins = prefs.getInt('${_gameStateKey}_coins') ?? 0;
    final level = prefs.getInt('${_gameStateKey}_level') ?? 1;
    final health = prefs.getInt('${_gameStateKey}_health') ?? 100;
    
    state = state.copyWith(
      score: score,
      coins: coins,
      currentLevel: level,
      playerHealth: health,
    );
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_gameStateKey}_score', state.score);
    await prefs.setInt('${_gameStateKey}_coins', state.coins);
    await prefs.setInt('${_gameStateKey}_level', state.currentLevel);
    await prefs.setInt('${_gameStateKey}_health', state.playerHealth);
  }

  void startGame() {
    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      score: 0,
      distance: 0.0,
      playerHealth: 100,
    );
  }

  void pauseGame() {
    state = state.copyWith(isPaused: true);
  }

  void resumeGame() {
    state = state.copyWith(isPaused: false);
  }

  void endGame() {
    state = state.copyWith(
      isRunning: false,
      isPaused: false,
    );
    _saveGameState();
  }

  void updateScore(int newScore) {
    state = state.copyWith(score: newScore);
  }

  void updateDistance(double newDistance) {
    state = state.copyWith(distance: newDistance);
  }

  void updateHealth(int newHealth) {
    state = state.copyWith(playerHealth: newHealth);
  }

  void addCoins(int amount) {
    state = state.copyWith(coins: state.coins + amount);
    _saveGameState();
  }

  void spendCoins(int amount) {
    if (state.coins >= amount) {
      state = state.copyWith(coins: state.coins - amount);
      _saveGameState();
    }
  }

  void levelUp() {
    state = state.copyWith(currentLevel: state.currentLevel + 1);
    _saveGameState();
  }
}

// Player Provider
final playerProvider = StateNotifierProvider<PlayerNotifier, Player>((ref) {
  return PlayerNotifier();
});

class PlayerNotifier extends StateNotifier<Player> {
  PlayerNotifier() : super(Player.guest()) {
    _loadPlayer();
  }

  static const String _playerKey = 'player';

  Future<void> _loadPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('${_playerKey}_name') ?? 'Guest';
    final totalScore = prefs.getInt('${_playerKey}_totalScore') ?? 0;
    final level = prefs.getInt('${_playerKey}_level') ?? 1;
    final coins = prefs.getInt('${_playerKey}_coins') ?? 0;
    final currentSkin = prefs.getString('${_playerKey}_currentSkin') ?? 'default';
    
    state = state.copyWith(
      name: name,
      totalScore: totalScore,
      level: level,
      coins: coins,
      currentSkin: currentSkin,
    );
  }

  Future<void> _savePlayer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_playerKey}_name', state.name);
    await prefs.setInt('${_playerKey}_totalScore', state.totalScore);
    await prefs.setInt('${_playerKey}_level', state.level);
    await prefs.setInt('${_playerKey}_coins', state.coins);
    await prefs.setString('${_playerKey}_currentSkin', state.currentSkin);
  }

  void updatePlayer(Player player) {
    state = player;
    _savePlayer();
  }

  void updateScore(int score) {
    if (score > state.totalScore) {
      state = state.copyWith(totalScore: score);
      _savePlayer();
    }
  }

  void updateCoins(int coins) {
    state = state.copyWith(coins: coins);
    _savePlayer();
  }

  void changeSkin(String skinId) {
    if (state.skins.contains(skinId)) {
      state = state.copyWith(currentSkin: skinId);
      _savePlayer();
    }
  }

  void unlockSkin(String skinId) {
    if (!state.skins.contains(skinId)) {
      state = state.copyWith(skins: [...state.skins, skinId]);
      _savePlayer();
    }
  }
}

// Settings Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, GameSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<GameSettings> {
  SettingsNotifier() : super(GameSettings.defaultSettings()) {
    _loadSettings();
  }

  static const String _settingsKey = 'settings';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final soundEnabled = prefs.getBool('${_settingsKey}_sound') ?? true;
    final musicEnabled = prefs.getBool('${_settingsKey}_music') ?? true;
    final vibrationEnabled = prefs.getBool('${_settingsKey}_vibration') ?? true;
    final graphicsQuality = GraphicsQuality.values[
      prefs.getInt('${_settingsKey}_graphics') ?? GraphicsQuality.high.index
    ];
    final controlsSensitivity = prefs.getDouble('${_settingsKey}_sensitivity') ?? 1.0;
    
    state = state.copyWith(
      soundEnabled: soundEnabled,
      musicEnabled: musicEnabled,
      vibrationEnabled: vibrationEnabled,
      graphicsQuality: graphicsQuality,
      controlsSensitivity: controlsSensitivity,
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_settingsKey}_sound', state.soundEnabled);
    await prefs.setBool('${_settingsKey}_music', state.musicEnabled);
    await prefs.setBool('${_settingsKey}_vibration', state.vibrationEnabled);
    await prefs.setInt('${_settingsKey}_graphics', state.graphicsQuality.index);
    await prefs.setDouble('${_settingsKey}_sensitivity', state.controlsSensitivity);
  }

  void updateSoundEnabled(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
    _saveSettings();
  }

  void updateMusicEnabled(bool enabled) {
    state = state.copyWith(musicEnabled: enabled);
    _saveSettings();
  }

  void updateVibrationEnabled(bool enabled) {
    state = state.copyWith(vibrationEnabled: enabled);
    _saveSettings();
  }

  void updateGraphicsQuality(GraphicsQuality quality) {
    state = state.copyWith(graphicsQuality: quality);
    _saveSettings();
  }

  void updateControlsSensitivity(double sensitivity) {
    state = state.copyWith(controlsSensitivity: sensitivity);
    _saveSettings();
  }
}
