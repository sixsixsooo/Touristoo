import 'package:flutter/foundation.dart';
import '../models/game_models.dart';
import '../services/data_service.dart';
import '../services/vk_cloud_service.dart';

class AuthProvider extends ChangeNotifier {
  Player? _currentPlayer;
  bool _isLoading = false;
  String? _error;

  Player? get currentPlayer => _currentPlayer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentPlayer != null && !_currentPlayer!.isGuest;

  Future<void> initialize() async {
    try {
      await DataService.instance.initialize();
      await _loadCurrentPlayer();
    } catch (e) {
      debugPrint('Failed to initialize AuthProvider: $e');
      rethrow;
    }
  }

  // Загрузка текущего игрока
  Future<void> _loadCurrentPlayer() async {
    try {
      // Пытаемся загрузить сохраненного игрока
      final savedPlayer = await DataService.instance.getPlayer('current_player');
      if (savedPlayer != null) {
        _currentPlayer = savedPlayer;
        notifyListeners();
        return;
      }

      // Если нет сохраненного игрока, создаем гостя
      await loginAsGuest();
    } catch (e) {
      debugPrint('Failed to load current player: $e');
      await loginAsGuest();
    }
  }

  // Вход как гость
  Future<void> loginAsGuest() async {
    try {
      _setLoading(true);
      _setError(null);

      final guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      final guestPlayer = Player(
        id: guestId,
        name: 'Гость',
        isGuest: true,
        coins: 0,
        level: 1,
        experience: 0,
        currentSkin: 'default',
        unlockedSkins: const ['default'],
        createdAt: DateTime.now(),
        lastPlayed: DateTime.now(),
      );

      await DataService.instance.savePlayer(guestPlayer);
      _currentPlayer = guestPlayer;
      
      // Синхронизируем с VK Cloud
      await syncWithServer();
      
      notifyListeners();
    } catch (e) {
      _setError('Ошибка входа как гость: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Регистрация
  Future<bool> register(String email, String password, String name) async {
    try {
      _setLoading(true);
      _setError(null);

      // Здесь будет код регистрации через VK Cloud
      // Пока что создаем локального пользователя
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final newPlayer = Player(
        id: userId,
        name: name,
        isGuest: false,
        coins: 100, // Бонус за регистрацию
        level: 1,
        experience: 0,
        currentSkin: 'default',
        unlockedSkins: const ['default'],
        createdAt: DateTime.now(),
        lastPlayed: DateTime.now(),
      );

      await DataService.instance.savePlayer(newPlayer);
      _currentPlayer = newPlayer;
      
      // Синхронизируем с VK Cloud
      await syncWithServer();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка регистрации: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Вход
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      // Здесь будет код входа через VK Cloud
      // Пока что создаем тестового пользователя
      final userId = 'user_${email.hashCode}';
      final existingPlayer = await DataService.instance.getPlayer(userId);
      
      if (existingPlayer != null) {
        _currentPlayer = existingPlayer;
      } else {
        // Создаем нового пользователя
        final newPlayer = Player(
          id: userId,
          name: email.split('@')[0],
          isGuest: false,
          coins: 0,
          level: 1,
          experience: 0,
          currentSkin: 'default',
          unlockedSkins: const ['default'],
          createdAt: DateTime.now(),
          lastPlayed: DateTime.now(),
        );

        await DataService.instance.savePlayer(newPlayer);
        _currentPlayer = newPlayer;
      }
      
      // Синхронизируем с VK Cloud
      await syncWithServer();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка входа: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Выход
  Future<void> logout() async {
    try {
      _setLoading(true);
      
      // Создаем нового гостя
      await loginAsGuest();
    } catch (e) {
      _setError('Ошибка выхода: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Обновление профиля
  Future<bool> updateProfile({String? name, String? avatar}) async {
    if (_currentPlayer == null) return false;

    try {
      _setLoading(true);
      _setError(null);

      final updatedPlayer = _currentPlayer!.copyWith(
        name: name ?? _currentPlayer!.name,
        avatar: avatar ?? _currentPlayer!.avatar,
        lastPlayed: DateTime.now(),
      );

      await DataService.instance.savePlayer(updatedPlayer);
      _currentPlayer = updatedPlayer;
      
      // Синхронизируем с VK Cloud
      await syncWithServer();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка обновления профиля: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Добавление монет
  Future<void> addCoins(int amount) async {
    if (_currentPlayer == null) return;

    try {
      final updatedPlayer = _currentPlayer!.copyWith(
        coins: _currentPlayer!.coins + amount,
        lastPlayed: DateTime.now(),
      );

      await DataService.instance.savePlayer(updatedPlayer);
      _currentPlayer = updatedPlayer;
      
      // Синхронизируем с VK Cloud
      await syncWithServer();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to add coins: $e');
    }
  }

  // Трата монет
  Future<bool> spendCoins(int amount) async {
    if (_currentPlayer == null || _currentPlayer!.coins < amount) return false;

    try {
      final updatedPlayer = _currentPlayer!.copyWith(
        coins: _currentPlayer!.coins - amount,
        lastPlayed: DateTime.now(),
      );

      await DataService.instance.savePlayer(updatedPlayer);
      _currentPlayer = updatedPlayer;
      
      // Синхронизируем с VK Cloud
      await syncWithServer();
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to spend coins: $e');
      return false;
    }
  }

  // Разблокировка скина
  Future<bool> unlockSkin(String skinId) async {
    if (_currentPlayer == null) return false;

    try {
      if (_currentPlayer!.unlockedSkins.contains(skinId)) return true;

      final updatedSkins = List<String>.from(_currentPlayer!.unlockedSkins)..add(skinId);
      final updatedPlayer = _currentPlayer!.copyWith(
        unlockedSkins: updatedSkins,
        lastPlayed: DateTime.now(),
      );

      await DataService.instance.savePlayer(updatedPlayer);
      _currentPlayer = updatedPlayer;
      
      // Синхронизируем с VK Cloud
      await syncWithServer();
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to unlock skin: $e');
      return false;
    }
  }

  // Смена скина
  Future<bool> changeSkin(String skinId) async {
    if (_currentPlayer == null) return false;

    try {
      if (!_currentPlayer!.unlockedSkins.contains(skinId)) return false;

      final updatedPlayer = _currentPlayer!.copyWith(
        currentSkin: skinId,
        lastPlayed: DateTime.now(),
      );

      await DataService.instance.savePlayer(updatedPlayer);
      _currentPlayer = updatedPlayer;
      
      // Синхронизируем с VK Cloud
      await syncWithServer();
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to change skin: $e');
      return false;
    }
  }

  // Синхронизация с VK Cloud
  Future<void> syncWithServer() async {
    if (_currentPlayer == null) return;

    try {
      // Синхронизируем данные игрока с VK Cloud
      await VKCloudService.instance.savePlayerData(
        _currentPlayer!.id,
        _currentPlayer!.toJson(),
      );
      
      // Синхронизируем все данные
      await DataService.instance.syncWithServer();
    } catch (e) {
      debugPrint('Failed to sync with VK Cloud: $e');
    }
  }

  // Вспомогательные методы
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
}
