import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';

import '../config/app_config.dart';
import '../models/game_models.dart';

class YandexCloudService {
  static final YandexCloudService _instance = YandexCloudService._internal();
  factory YandexCloudService() => _instance;
  YandexCloudService._internal();

  late Dio _dio;
  String? _accessToken;
  DateTime? _tokenExpiry;

  Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.yandexCloudFunctionUrl,
      connectTimeout: AppConfig.apiTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConfig.yandexCloudApiKey}',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: AppConfig.enableLogging,
      responseBody: AppConfig.enableLogging,
    ));

    await _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      final response = await _dio.post('/auth', data: {
        'apiKey': AppConfig.yandexCloudApiKey,
      });

      if (response.statusCode == 200) {
        _accessToken = response.data['accessToken'];
        _tokenExpiry = DateTime.now().add(
          Duration(seconds: response.data['expiresIn'] ?? 3600),
        );
      }
    } catch (e) {
      print('Yandex Cloud authentication failed: $e');
    }
  }

  Future<bool> _ensureAuthenticated() async {
    if (_accessToken == null || 
        _tokenExpiry == null || 
        DateTime.now().isAfter(_tokenExpiry!)) {
      await _authenticate();
    }
    return _accessToken != null;
  }

  // Player Management
  Future<ApiResponse<Player>> createPlayer(Player player) async {
    if (!await _ensureAuthenticated()) {
      return const ApiResponse(success: false, error: 'Authentication failed');
    }

    try {
      final response = await _dio.post('/players', data: player.toJson());
      return ApiResponse<Player>.fromJson(response.data);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<Player>> getPlayer(String playerId) async {
    if (!await _ensureAuthenticated()) {
      return const ApiResponse(success: false, error: 'Authentication failed');
    }

    try {
      final response = await _dio.get('/players/$playerId');
      return ApiResponse<Player>.fromJson(response.data);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<Player>> updatePlayer(String playerId, Player player) async {
    if (!await _ensureAuthenticated()) {
      return const ApiResponse(success: false, error: 'Authentication failed');
    }

    try {
      final response = await _dio.put('/players/$playerId', data: player.toJson());
      return ApiResponse<Player>.fromJson(response.data);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // Game Data
  Future<ApiResponse<GameState>> saveGameState(String playerId, GameState gameState) async {
    if (!await _ensureAuthenticated()) {
      return const ApiResponse(success: false, error: 'Authentication failed');
    }

    try {
      final response = await _dio.post('/game/save', data: {
        'playerId': playerId,
        'gameState': gameState.toJson(),
      });
      return ApiResponse<GameState>.fromJson(response.data);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<GameState>> getGameState(String playerId) async {
    if (!await _ensureAuthenticated()) {
      return const ApiResponse(success: false, error: 'Authentication failed');
    }

    try {
      final response = await _dio.get('/game/state/$playerId');
      return ApiResponse<GameState>.fromJson(response.data);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // Leaderboard
  Future<ApiResponse<List<LeaderboardEntry>>> getLeaderboard({
    int limit = 50,
    int offset = 0,
    String timeRange = 'all',
  }) async {
    if (!await _ensureAuthenticated()) {
      return const ApiResponse(success: false, error: 'Authentication failed');
    }

    try {
      final response = await _dio.get('/leaderboard', queryParameters: {
        'limit': limit,
        'offset': offset,
        'timeRange': timeRange,
      });
      return ApiResponse<List<LeaderboardEntry>>.fromJson(response.data);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<int>> getPlayerRank(String playerId, String timeRange) async {
    if (!await _ensureAuthenticated()) {
      return const ApiResponse(success: false, error: 'Authentication failed');
    }

    try {
      final response = await _dio.get('/leaderboard/rank/$playerId', queryParameters: {
        'timeRange': timeRange,
      });
      return ApiResponse<int>.fromJson(response.data);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // Shop
  Future<ApiResponse<List<Skin>>> getAvailableSkins() async {
    if (!await _ensureAuthenticated()) {
      return const ApiResponse(success: false, error: 'Authentication failed');
    }

    try {
      final response = await _dio.get('/shop/skins');
      return ApiResponse<List<Skin>>.fromJson(response.data);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<Purchase>> purchaseSkin(String playerId, String skinId) async {
    if (!await _ensureAuthenticated()) {
      return const ApiResponse(success: false, error: 'Authentication failed');
    }

    try {
      final response = await _dio.post('/shop/purchase/skin', data: {
        'playerId': playerId,
        'skinId': skinId,
      });
      return ApiResponse<Purchase>.fromJson(response.data);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // Analytics
  Future<void> trackEvent(String eventName, Map<String, dynamic> parameters) async {
    if (!await _ensureAuthenticated()) {
      return;
    }

    try {
      await _dio.post('/analytics/event', data: {
        'eventName': eventName,
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to track event: $e');
    }
  }

  Future<void> trackGameSession(String playerId, Map<String, dynamic> sessionData) async {
    if (!await _ensureAuthenticated()) {
      return;
    }

    try {
      await _dio.post('/analytics/session', data: {
        'playerId': playerId,
        'sessionData': sessionData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to track game session: $e');
    }
  }

  // File Upload
  Future<ApiResponse<String>> uploadFile(String filePath, String fileName) async {
    if (!await _ensureAuthenticated()) {
      return const ApiResponse(success: false, error: 'Authentication failed');
    }

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post('/files/upload', data: formData);
      return ApiResponse<String>.fromJson(response.data);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // Push Notifications
  Future<void> sendPushNotification(String playerId, String title, String body) async {
    if (!await _ensureAuthenticated()) {
      return;
    }

    try {
      await _dio.post('/notifications/send', data: {
        'playerId': playerId,
        'title': title,
        'body': body,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to send push notification: $e');
    }
  }

  // Health Check
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Generate signature for secure requests
  String _generateSignature(String data, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }
}
