import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class VKCloudService {
  static VKCloudService? _instance;
  static VKCloudService get instance => _instance ??= VKCloudService._();
  
  VKCloudService._();

  bool _isInitialized = false;
  String? _accessToken;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Инициализация VK Cloud
      await _authenticate();
      _isInitialized = true;
      print('VK Cloud initialized successfully');
    } catch (e) {
      print('Failed to initialize VK Cloud: $e');
      rethrow;
    }
  }

  Future<void> _authenticate() async {
    try {
      // Аутентификация в VK Cloud
      final response = await http.post(
        Uri.parse('${AppConfig.vkCloudFunctionUrl}/auth'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.vkCloudApiKey}',
        },
        body: jsonEncode({
          'project_id': AppConfig.vkCloudProjectId,
          'region': AppConfig.vkCloudRegion,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
      } else {
        throw Exception('Failed to authenticate with VK Cloud');
      }
    } catch (e) {
      print('VK Cloud authentication failed: $e');
      // В режиме разработки используем заглушку
      _accessToken = 'dev_token';
    }
  }

  // Cloud Functions - API вызовы
  Future<Map<String, dynamic>?> callFunction(
    String functionName,
    Map<String, dynamic> data,
  ) async {
    if (!_isInitialized) await initialize();

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.vkCloudFunctionUrl}/$functionName'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('VK Cloud function call failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('VK Cloud function call error: $e');
      return null;
    }
  }

  // Сохранение данных игрока
  Future<bool> savePlayerData(String playerId, Map<String, dynamic> data) async {
    try {
      final result = await callFunction('savePlayer', {
        'player_id': playerId,
        'data': data,
      });
      return result?['success'] ?? false;
    } catch (e) {
      print('Failed to save player data: $e');
      return false;
    }
  }

  // Получение данных игрока
  Future<Map<String, dynamic>?> getPlayerData(String playerId) async {
    try {
      final result = await callFunction('getPlayer', {
        'player_id': playerId,
      });
      return result?['data'];
    } catch (e) {
      print('Failed to get player data: $e');
      return null;
    }
  }

  // Сохранение рекорда
  Future<bool> saveScore(String playerId, int score, double distance) async {
    try {
      final result = await callFunction('saveScore', {
        'player_id': playerId,
        'score': score,
        'distance': distance,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      return result?['success'] ?? false;
    } catch (e) {
      print('Failed to save score: $e');
      return false;
    }
  }

  // Получение рейтинга
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      final result = await callFunction('getLeaderboard', {
        'limit': limit,
      });
      return List<Map<String, dynamic>>.from(result?['data'] ?? []);
    } catch (e) {
      print('Failed to get leaderboard: $e');
      return [];
    }
  }

  // Object Storage - загрузка файлов
  Future<String?> uploadFile(String path, List<int> fileData) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.vkCloudStorageUrl}/${AppConfig.vkCloudStorageBucket}/$path'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/octet-stream',
        },
        body: fileData,
      );

      if (response.statusCode == 200) {
        return '${AppConfig.vkCloudStorageUrl}/${AppConfig.vkCloudStorageBucket}/$path';
      } else {
        print('File upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('File upload error: $e');
      return null;
    }
  }

  // Получение URL файла
  Future<String?> getFileUrl(String path) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.vkCloudStorageUrl}/${AppConfig.vkCloudStorageBucket}/$path'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        return '${AppConfig.vkCloudStorageUrl}/${AppConfig.vkCloudStorageBucket}/$path';
      } else {
        print('File not found: $path');
        return null;
      }
    } catch (e) {
      print('File URL error: $e');
      return null;
    }
  }

  // Аналитика
  Future<void> logEvent(String eventName, Map<String, dynamic> parameters) async {
    try {
      await callFunction('logEvent', {
        'event_name': eventName,
        'parameters': parameters,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  // События игры
  Future<void> logGameStart() async {
    await logEvent('game_start', {});
  }

  Future<void> logGameEnd(int score, double distance) async {
    await logEvent('game_end', {
      'score': score,
      'distance': distance,
    });
  }

  Future<void> logPurchase(String itemId, double value) async {
    await logEvent('purchase', {
      'item_id': itemId,
      'value': value,
      'currency': 'RUB',
    });
  }

  // Проверка соединения
  Future<bool> isConnected() async {
    try {
      final result = await callFunction('health', {});
      return result?['status'] == 'ok';
    } catch (e) {
      return false;
    }
  }

  // Синхронизация данных
  Future<void> syncData() async {
    try {
      await callFunction('syncData', {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Failed to sync data: $e');
    }
  }
}
