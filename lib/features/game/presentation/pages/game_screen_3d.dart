import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:vector_math/vector_math_64.dart' as math;
import '../../../../core/providers/game_provider.dart';
import '../../../../core/models/game_models.dart';
import 'dart:async';
import 'dart:math';

class GameScreen3D extends StatefulWidget {
  const GameScreen3D({super.key});

  @override
  State<GameScreen3D> createState() => _GameScreen3DState();
}

class _GameScreen3DState extends State<GameScreen3D> with TickerProviderStateMixin {
  late AnimationController _playerController;
  late AnimationController _roadController;
  late Timer _gameTimer;
  
  final List<Obstacle3D> _obstacles = [];
  final List<PowerUp3D> _powerUps = [];
  final Random _random = Random();
  
  // 3D Scene objects
  Object? _player;
  Object? _road;
  Object? _boss;
  Scene? _scene;

  @override
  void initState() {
    super.initState();
    _playerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _roadController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _startGame();
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    _playerController.dispose();
    _roadController.dispose();
    super.dispose();
  }

  void _startGame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      gameProvider.startGame();
      
      _gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        _updateGame();
      });
      
      _roadController.repeat();
    });
  }

  void _updateGame() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    if (!gameProvider.gameState.isRunning || gameProvider.gameState.isPaused) return;

    // Обновляем дистанцию
    final newDistance = gameProvider.gameState.distance + gameProvider.gameState.gameSpeed * 0.1;
    gameProvider.updateDistance(newDistance);

    // Генерируем препятствия и усиления
    _generateObstacles(newDistance);
    _generatePowerUps(newDistance);

    // Проверяем столкновения
    _checkCollisions();

    // Проверяем, достигли ли босса (1000 метров)
    if (newDistance >= 1000 && !gameProvider.gameState.isBossFight) {
      _startBossFight();
    }

    // Обновляем позиции 3D объектов
    _update3DObjects();
  }

  void _generateObstacles(double distance) {
    if (_random.nextDouble() < 0.02) {
      final lane = _random.nextInt(3);
      _obstacles.add(Obstacle3D(
        position: math.Vector3(lane * 2.0 - 2.0, 0, distance + 50),
        type: 'rock',
        damage: 20,
        object: _createObstacleObject(),
      ));
    }
  }

  void _generatePowerUps(double distance) {
    if (_random.nextDouble() < 0.03) {
      final lane = _random.nextInt(3);
      final powerUpTypes = PowerUpType.values.where((type) => type != PowerUpType.coin).toList();
      final type = powerUpTypes[_random.nextInt(powerUpTypes.length)];
      
      _powerUps.add(PowerUp3D(
        position: math.Vector3(lane * 2.0 - 2.0, 0, distance + 50),
        type: type,
        value: 1.0,
        lane: lane,
        object: _createPowerUpObject(type),
      ));
    }

    if (_random.nextDouble() < 0.05) {
      final lane = _random.nextInt(3);
      _powerUps.add(PowerUp3D(
        position: math.Vector3(lane * 2.0 - 2.0, 0, distance + 50),
        type: PowerUpType.coin,
        value: 10.0,
        lane: lane,
        object: _createPowerUpObject(PowerUpType.coin),
      ));
    }
  }

  Object _createObstacleObject() {
    // Создаем 3D препятствие (камень)
    final mesh = Mesh.cube();
    mesh.material = MeshMaterial(
      color: const Color(0xFF8B4513), // Коричневый цвет
    );
    return Object(
      mesh: mesh,
      scale: math.Vector3(0.5, 0.5, 0.5),
    );
  }

  Object _createPowerUpObject(PowerUpType type) {
    // Создаем 3D усиление
    final mesh = Mesh.sphere();
    Color color;
    
    switch (type) {
      case PowerUpType.health:
        color = Colors.red;
        break;
      case PowerUpType.speed:
        color = Colors.orange;
        break;
      case PowerUpType.shield:
        color = Colors.blue;
        break;
      case PowerUpType.fireball:
        color = Colors.red;
        break;
      case PowerUpType.lightning:
        color = Colors.yellow;
        break;
      case PowerUpType.ice:
        color = Colors.cyan;
        break;
      case PowerUpType.coin:
        color = Colors.amber;
        break;
    }
    
    mesh.material = MeshMaterial(
      color: color,
      shininess: 100,
    );
    
    return Object(
      mesh: mesh,
      scale: math.Vector3(0.3, 0.3, 0.3),
    );
  }

  void _checkCollisions() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final playerLane = gameProvider.gameState.currentLane;
    final playerZ = gameProvider.gameState.distance;

    // Проверяем столкновения с препятствиями
    for (int i = _obstacles.length - 1; i >= 0; i--) {
      final obstacle = _obstacles[i];
      if (obstacle.position.z < playerZ + 2 && 
          obstacle.position.z > playerZ - 2 &&
          (obstacle.position.x / 2 + 1).round() == playerLane) {
        gameProvider.takeDamage(20);
        _obstacles.removeAt(i);
      }
    }

    // Проверяем сбор усилений
    for (int i = _powerUps.length - 1; i >= 0; i--) {
      final powerUp = _powerUps[i];
      if (powerUp.position.z < playerZ + 2 && 
          powerUp.position.z > playerZ - 2 &&
          powerUp.lane == playerLane) {
        _collectPowerUp(powerUp);
        _powerUps.removeAt(i);
      }
    }

    // Удаляем объекты, которые прошли за экран
    _obstacles.removeWhere((obstacle) => obstacle.position.z < playerZ - 10);
    _powerUps.removeWhere((powerUp) => powerUp.position.z < playerZ - 10);
  }

  void _collectPowerUp(PowerUp3D powerUp) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    switch (powerUp.type) {
      case PowerUpType.health:
        gameProvider.heal(20);
        break;
      case PowerUpType.speed:
        gameProvider.increaseSpeed();
        break;
      case PowerUpType.shield:
        gameProvider.addShield();
        break;
      case PowerUpType.coin:
        gameProvider.addCoins(powerUp.value.toInt());
        break;
      default:
        gameProvider.addPowerUp(PowerUp(
          position: Vector3(powerUp.position.x, powerUp.position.y, powerUp.position.z),
          type: powerUp.type,
          value: powerUp.value,
          lane: powerUp.lane,
        ));
        break;
    }
  }

  void _startBossFight() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.startBossFight();
    
    // Создаем 3D босса
    _createBossObject();
  }

  void _createBossObject() {
    final mesh = Mesh.cube();
    mesh.material = MeshMaterial(
      color: Colors.red,
      shininess: 50,
    );
    
    _boss = Object(
      mesh: mesh,
      scale: math.Vector3(2.0, 2.0, 2.0),
      position: math.Vector3(0, 0, 0),
    );
    
    if (_scene != null) {
      _scene!.world.add(_boss!);
    }
  }

  void _update3DObjects() {
    if (_scene == null) return;
    
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final playerZ = gameProvider.gameState.distance;
    
    // Обновляем позиции препятствий
    for (final obstacle in _obstacles) {
      final relativeZ = obstacle.position.z - playerZ;
      obstacle.object.position = math.Vector3(
        obstacle.position.x,
        obstacle.position.y,
        relativeZ,
      );
    }
    
    // Обновляем позиции усилений
    for (final powerUp in _powerUps) {
      final relativeZ = powerUp.position.z - playerZ;
      powerUp.object.position = math.Vector3(
        powerUp.position.x,
        powerUp.position.y,
        relativeZ,
      );
      
      // Анимация вращения для усилений
      powerUp.object.rotation.y += 0.1;
    }
    
    // Обновляем позицию игрока
    if (_player != null) {
      _player!.position = math.Vector3(
        gameProvider.gameState.currentLane * 2.0 - 2.0,
        0,
        0,
      );
    }
  }

  void _moveLeft() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    if (gameProvider.gameState.currentLane > 0) {
      gameProvider.moveToLane(gameProvider.gameState.currentLane - 1);
      _playerController.forward().then((_) => _playerController.reverse());
    }
  }

  void _moveRight() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    if (gameProvider.gameState.currentLane < 2) {
      gameProvider.moveToLane(gameProvider.gameState.currentLane + 1);
      _playerController.forward().then((_) => _playerController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Небесно-голубой
              Color(0xFF98FB98), // Бледно-зеленый
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHUD(),
              Expanded(
                child: GestureDetector(
                  onPanEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dx > 300) {
                      _moveRight();
                    } else if (details.velocity.pixelsPerSecond.dx < -300) {
                      _moveLeft();
                    }
                  },
                  child: Stack(
                    children: [
                      _build3DScene(),
                      _buildBossUI(),
                    ],
                  ),
                ),
              ),
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHUD() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Очки: ${gameProvider.gameState.score}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Дистанция: ${gameProvider.gameState.distance.toInt()}м',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Здоровье: ${gameProvider.gameState.playerHealth}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Монеты: ${gameProvider.gameState.coins}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _build3DScene() {
    return Cube(
      onSceneCreated: (Scene scene) {
        _scene = scene;
        
        // Создаем 3D дорогу
        _createRoad(scene);
        
        // Создаем 3D персонажа
        _createPlayer(scene);
        
        // Настраиваем камеру
        scene.camera.position = math.Vector3(0, 5, 10);
        scene.camera.target = math.Vector3(0, 0, 0);
      },
    );
  }

  void _createRoad(Scene scene) {
    final roadMesh = Mesh.cube();
    roadMesh.material = MeshMaterial(
      color: const Color(0xFF404040), // Темно-серый
    );
    
    _road = Object(
      mesh: roadMesh,
      scale: math.Vector3(6.0, 0.1, 1000.0),
      position: math.Vector3(0, -1, 0),
    );
    
    scene.world.add(_road!);
  }

  void _createPlayer(Scene scene) {
    final playerMesh = Mesh.cube();
    playerMesh.material = MeshMaterial(
      color: Colors.blue,
    );
    
    _player = Object(
      mesh: playerMesh,
      scale: math.Vector3(0.5, 1.0, 0.5),
      position: math.Vector3(0, 0, 0),
    );
    
    scene.world.add(_player!);
  }

  Widget _buildBossUI() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (!gameProvider.gameState.isBossFight) {
          return const SizedBox.shrink();
        }
        
        return Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  '🔥 БОСС АКТИВЕН! 🔥',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Здоровье босса: ${gameProvider.gameState.bossHealth}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: gameProvider.gameState.bossHealth / gameProvider.gameState.maxBossHealth,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _moveLeft,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 30,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final gameProvider = Provider.of<GameProvider>(context, listen: false);
              if (gameProvider.gameState.isPaused) {
                gameProvider.resumeGame();
              } else {
                gameProvider.pauseGame();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
            ),
            child: Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                return Icon(
                  gameProvider.gameState.isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                  size: 30,
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _moveRight,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

// 3D версии моделей
class Obstacle3D {
  final math.Vector3 position;
  final String type;
  final double damage;
  final Object object;

  Obstacle3D({
    required this.position,
    required this.type,
    required this.damage,
    required this.object,
  });
}

class PowerUp3D {
  final math.Vector3 position;
  final PowerUpType type;
  final double value;
  final int lane;
  final Object object;

  PowerUp3D({
    required this.position,
    required this.type,
    required this.value,
    required this.lane,
    required this.object,
  });
}
