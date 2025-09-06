import 'package:flutter/foundation.dart';
import '../models/game_models.dart';

class AuthProvider extends ChangeNotifier {
  Player? _currentPlayer;
  bool _isLoggedIn = false;

  Player? get currentPlayer => _currentPlayer;
  bool get isLoggedIn => _isLoggedIn;

  void loginAsGuest() {
    _currentPlayer = Player.guest();
    _isLoggedIn = true;
    notifyListeners();
  }

  void login(String username, String password) {
    // Заглушка для входа
    _currentPlayer = Player(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: username,
      level: 1,
      coins: 0,
      bestScore: 0,
      createdAt: DateTime.now(),
    );
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _currentPlayer = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  void updatePlayer(Player player) {
    _currentPlayer = player;
    notifyListeners();
  }
}