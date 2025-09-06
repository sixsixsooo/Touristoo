import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _gameStateBox = 'game_state';
  static const String _playerBox = 'player';
  static const String _settingsBox = 'settings';
  static const String _leaderboardBox = 'leaderboard';

  static late Box _gameStateBoxInstance;
  static late Box _playerBoxInstance;
  static late Box _settingsBoxInstance;
  static late Box _leaderboardBoxInstance;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    _gameStateBoxInstance = await Hive.openBox(_gameStateBox);
    _playerBoxInstance = await Hive.openBox(_playerBox);
    _settingsBoxInstance = await Hive.openBox(_settingsBox);
    _leaderboardBoxInstance = await Hive.openBox(_leaderboardBox);
  }

  // Game State Storage
  static Future<void> saveGameState(Map<String, dynamic> gameState) async {
    await _gameStateBoxInstance.putAll(gameState);
  }

  static Map<String, dynamic>? getGameState() {
    return _gameStateBoxInstance.toMap();
  }

  static Future<void> clearGameState() async {
    await _gameStateBoxInstance.clear();
  }

  // Player Storage
  static Future<void> savePlayer(Map<String, dynamic> player) async {
    await _playerBoxInstance.putAll(player);
  }

  static Map<String, dynamic>? getPlayer() {
    return _playerBoxInstance.toMap();
  }

  static Future<void> clearPlayer() async {
    await _playerBoxInstance.clear();
  }

  // Settings Storage
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _settingsBoxInstance.putAll(settings);
  }

  static Map<String, dynamic>? getSettings() {
    return _settingsBoxInstance.toMap();
  }

  // Leaderboard Storage
  static Future<void> saveLeaderboard(List<Map<String, dynamic>> leaderboard) async {
    await _leaderboardBoxInstance.put('leaderboard', leaderboard);
  }

  static List<Map<String, dynamic>>? getLeaderboard() {
    final data = _leaderboardBoxInstance.get('leaderboard');
    return data != null ? List<Map<String, dynamic>>.from(data) : null;
  }

  // SharedPreferences for simple values
  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<void> setDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  static Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _gameStateBoxInstance.clear();
    await _playerBoxInstance.clear();
    await _settingsBoxInstance.clear();
    await _leaderboardBoxInstance.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
