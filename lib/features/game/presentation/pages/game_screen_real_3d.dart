import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../../../core/providers/game_provider.dart';
import '../../../../core/models/game_models.dart';
import 'dart:async';
import 'dart:math';

class GameScreenReal3D extends StatefulWidget {
  const GameScreenReal3D({super.key});

  @override
  State<GameScreenReal3D> createState() => _GameScreenReal3DState();
}

class _GameScreenReal3DState extends State<GameScreenReal3D> with TickerProviderStateMixin {
  late AnimationController _playerController;
  late AnimationController _roadController;
  late Timer _gameTimer;
  
  final List<Food3D> _foodItems = [];
  final Random _random = Random();
  
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
      ));
    }
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
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Stack(
          children: [
            // 3D Road with perspective
            _build3DRoad(),
            
            // 3D Stool Model
            _build3DStoolModel(gameProvider),
            
            // 3D Food Items
            ..._build3DFood(),
          ],
        );
      },
    );
  }

  Widget _build3DRoad() {
    return AnimatedBuilder(
      animation: _roadController,
      builder: (context, child) {
        return CustomPaint(
          painter: Road3DPainter(_roadController.value, _roadZ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _build3DStoolModel(GameProvider gameProvider) {
    return Positioned(
      left: MediaQuery.of(context).size.width * 0.2 + 
            gameProvider.gameState.currentLane * 
            (MediaQuery.of(context).size.width * 0.6 / 3) - 40,
      top: MediaQuery.of(context).size.height * 0.5,
      child: AnimatedBuilder(
        animation: _playerController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + _playerController.value * 0.1,
            child: Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ModelViewer(
                src: 'assets/models/character/cnek.obj',
                alt: '3D Stool Model',
                ar: false,
                autoRotate: false,
                cameraControls: false,
                backgroundColor: Colors.transparent,
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _build3DFood() {
    return _foodItems.map((food) {
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;
      final relativeZ = food.position.z - _cameraZ;
      final screenY = screenHeight * 0.7 - relativeZ * 2;
      
      if (screenY < -50 || screenY > screenHeight) return const SizedBox.shrink();
      
      IconData icon;
      List<Color> gradientColors;
      double size = 50;
      
      switch (food.type) {
        case 'apple':
          icon = Icons.apple;
          gradientColors = [Colors.red, Colors.pink];
          break;
        case 'banana':
          icon = Icons.emoji_food_beverage;
          gradientColors = [Colors.yellow, Colors.amber];
          break;
        case 'coin':
          icon = Icons.monetization_on;
          gradientColors = [Colors.amber, Colors.yellow];
          size = 40;
          break;
        default:
          icon = Icons.fastfood;
          gradientColors = [Colors.green, Colors.lightGreen];
      }
      
      return Positioned(
        left: screenWidth * 0.2 + 
              food.lane * 
              (screenWidth * 0.6 / 3) - size/2,
        top: screenY,
        child: AnimatedBuilder(
          animation: _roadController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _roadController.value * 2 * pi,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.7),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: size * 0.6,
                ),
              ),
            );
          },
        ),
      );
    }).toList();
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

class Road3DPainter extends CustomPainter {
  final double animationValue;
  final double roadZ;

  Road3DPainter(this.animationValue, this.roadZ);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;

    // Рисуем 3D дорогу с перспективой
    final roadWidth = size.width * 0.6;
    final roadLeft = size.width * 0.2;
    
    // Основная дорога
    canvas.drawRect(
      Rect.fromLTWH(roadLeft, 0, roadWidth, size.height),
      paint,
    );

    // Разделительные линии
    final linePaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Центральная линия
    canvas.drawLine(
      Offset(roadLeft + roadWidth / 2, 0),
      Offset(roadLeft + roadWidth / 2, size.height),
      linePaint,
    );

    // Боковые линии
    canvas.drawLine(
      Offset(roadLeft, 0),
      Offset(roadLeft, size.height),
      linePaint,
    );
    canvas.drawLine(
      Offset(roadLeft + roadWidth, 0),
      Offset(roadLeft + roadWidth, size.height),
      linePaint,
    );

    // Движущиеся полосы с 3D эффектом
    final stripePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final stripeSpacing = 50.0;
    final stripeOffset = (animationValue * stripeSpacing) % stripeSpacing;

    for (double y = -stripeOffset; y < size.height + stripeSpacing; y += stripeSpacing) {
      // Левая полоса
      canvas.drawLine(
        Offset(roadLeft + roadWidth / 3, y),
        Offset(roadLeft + roadWidth / 3, y + 20),
        stripePaint,
      );
      // Правая полоса
      canvas.drawLine(
        Offset(roadLeft + roadWidth * 2 / 3, y),
        Offset(roadLeft + roadWidth * 2 / 3, y + 20),
        stripePaint,
      );
    }

    // Добавляем тени для 3D эффекта
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Тень дороги
    canvas.drawRect(
      Rect.fromLTWH(roadLeft - 2, 0, 4, size.height),
      shadowPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(roadLeft + roadWidth - 2, 0, 4, size.height),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 3D модель еды
class Food3D {
  final Vector3 position;
  final String type;
  final int value;
  final int lane;

  Food3D({
    required this.position,
    required this.type,
    required this.value,
    required this.lane,
  });
}
