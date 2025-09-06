import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:vector_math/vector_math_64.dart' as math;
import '../../../../core/providers/game_provider.dart';
import '../../../../core/models/game_models.dart';
import 'dart:async';
import 'dart:math';

class GameScreen3DModels extends StatefulWidget {
  const GameScreen3DModels({super.key});

  @override
  State<GameScreen3DModels> createState() => _GameScreen3DModelsState();
}

class _GameScreen3DModelsState extends State<GameScreen3DModels> with TickerProviderStateMixin {
  late AnimationController _playerController;
  late AnimationController _roadController;
  late Timer _gameTimer;
  
  final List<Food3D> _foodItems = [];
  final Random _random = Random();
  
  // 3D Scene objects
  Object? _player;
  Object? _road;
  Scene? _scene;
  
  // Camera and movement
  double _cameraZ = 0.0;
  double _playerX = 0.0;
  double _roadZ = 0.0;

  @override
  void initState() {
    super.initState();
    _playerController = AnimationController(
      duration: const Duration(milliseconds: 200),
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

    // Обновляем позицию камеры (следует за персонажем)
    _cameraZ = newDistance;
    _roadZ = newDistance;

    // Генерируем еду
    _generateFood(newDistance);

    // Проверяем сбор еды
    _checkFoodCollection();

    // Обновляем позиции 3D объектов
    _update3DObjects();
  }

  void _generateFood(double distance) {
    if (_random.nextDouble() < 0.03) {
      final lane = _random.nextInt(3);
      final foodTypes = ['apple', 'banana', 'coin'];
      final foodType = foodTypes[_random.nextInt(foodTypes.length)];
      
      _foodItems.add(Food3D(
        position: Vector3(lane * 2.0 - 2.0, 0, distance + 50),
        type: foodType,
        value: foodType == 'coin' ? 10 : 5,
        lane: lane,
        object: _createFoodObject(foodType),
      ));
    }
  }

  Object _createFoodObject(String type) {
    // Создаем 3D объект еды
    final mesh = Mesh.cube();
    Color color;
    double scale = 0.3;
    
    switch (type) {
      case 'apple':
        color = Colors.red;
        break;
      case 'banana':
        color = Colors.yellow;
        break;
      case 'coin':
        color = Colors.amber;
        scale = 0.2;
        break;
      default:
        color = Colors.green;
    }
    
    mesh.material = MeshMaterial(
      color: color,
      shininess: 100,
    );
    
    return Object(
      mesh: mesh,
      scale: math.Vector3(scale, scale, scale),
    );
  }

  void _checkFoodCollection() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final playerLane = gameProvider.gameState.currentLane;
    final playerZ = gameProvider.gameState.distance;

    // Проверяем сбор еды
    for (int i = _foodItems.length - 1; i >= 0; i--) {
      final food = _foodItems[i];
      if (food.position.z < playerZ + 2 && 
          food.position.z > playerZ - 2 &&
          food.lane == playerLane) {
        _collectFood(food);
        _foodItems.removeAt(i);
      }
    }

    // Удаляем еду, которая прошла за экран
    _foodItems.removeWhere((food) => food.position.z < playerZ - 10);
  }

  void _collectFood(Food3D food) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.addCoins(food.value);
    gameProvider.addScore(food.value * 10);
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
              Color(0xFF87CEEB), // Небо
              Color(0xFF98FB98), // Трава
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
                  child: _build3DScene(),
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
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Дистанция: ${gameProvider.gameState.distance.toInt()}м',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        '${gameProvider.gameState.coins}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Скорость: ${gameProvider.gameState.gameSpeed.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                      ],
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

  void _update3DObjects() {
    if (_scene == null) return;
    
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final playerZ = gameProvider.gameState.distance;
    
    // Обновляем позицию игрока
    if (_player != null) {
      _playerX = gameProvider.gameState.currentLane * 2.0 - 2.0;
      _player!.position = math.Vector3(_playerX, 0, 0);
    }
    
    // Обновляем позиции еды
    for (final food in _foodItems) {
      final relativeZ = food.position.z - playerZ;
      food.object.position = math.Vector3(
        food.position.x,
        food.position.y,
        relativeZ,
      );
      
      // Анимация вращения для еды
      food.object.rotation.y += 0.1;
    }
    
    // Обновляем позицию дороги
    if (_road != null) {
      _road!.position = math.Vector3(0, -1, -_roadZ);
    }
    
    // Обновляем камеру (следует за персонажем)
    _scene!.camera.position = math.Vector3(_playerX, 5, 10);
    _scene!.camera.target = math.Vector3(_playerX, 0, 0);
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.arrow_back,
            onPressed: _moveLeft,
            color: Colors.blue,
          ),
          _buildControlButton(
            icon: Icons.pause,
            onPressed: () {
              final gameProvider = Provider.of<GameProvider>(context, listen: false);
              if (gameProvider.gameState.isPaused) {
                gameProvider.resumeGame();
              } else {
                gameProvider.pauseGame();
              }
            },
            color: Colors.orange,
          ),
          _buildControlButton(
            icon: Icons.arrow_forward,
            onPressed: _moveRight,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

// 3D модель еды
class Food3D {
  final Vector3 position;
  final String type;
  final int value;
  final int lane;
  final Object object;

  Food3D({
    required this.position,
    required this.type,
    required this.value,
    required this.lane,
    required this.object,
  });
}
