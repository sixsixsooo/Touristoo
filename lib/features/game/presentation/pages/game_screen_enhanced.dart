import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../../../core/providers/game_provider.dart';
import '../../../../core/models/game_models.dart';
import 'dart:async';
import 'dart:math';

class GameScreenEnhanced extends StatefulWidget {
  const GameScreenEnhanced({super.key});

  @override
  State<GameScreenEnhanced> createState() => _GameScreenEnhancedState();
}

class _GameScreenEnhancedState extends State<GameScreenEnhanced> with TickerProviderStateMixin {
  late AnimationController _playerController;
  late AnimationController _roadController;
  late Timer _gameTimer;
  
  final List<ObstacleEnhanced> _obstacles = [];
  final List<PowerUpEnhanced> _powerUps = [];
  final Random _random = Random();

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
  }

  void _generateObstacles(double distance) {
    if (_random.nextDouble() < 0.02) {
      final lane = _random.nextInt(3);
      _obstacles.add(ObstacleEnhanced(
        position: Vector3(lane * 2.0 - 2.0, 0, distance + 50),
        type: 'rock',
        damage: 20,
        lane: lane,
      ));
    }
  }

  void _generatePowerUps(double distance) {
    if (_random.nextDouble() < 0.03) {
      final lane = _random.nextInt(3);
      final powerUpTypes = PowerUpType.values.where((type) => type != PowerUpType.coin).toList();
      final type = powerUpTypes[_random.nextInt(powerUpTypes.length)];
      
      _powerUps.add(PowerUpEnhanced(
        position: Vector3(lane * 2.0 - 2.0, 0, distance + 50),
        type: type,
        value: 1.0,
        lane: lane,
      ));
    }

    if (_random.nextDouble() < 0.05) {
      final lane = _random.nextInt(3);
      _powerUps.add(PowerUpEnhanced(
        position: Vector3(lane * 2.0 - 2.0, 0, distance + 50),
        type: PowerUpType.coin,
        value: 10.0,
        lane: lane,
      ));
    }
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
          obstacle.lane == playerLane) {
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

  void _collectPowerUp(PowerUpEnhanced powerUp) {
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
          position: powerUp.position,
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
              Color(0xFF1E3C72), // Темно-синий
              Color(0xFF2A5298), // Синий
              Color(0xFF87CEEB), // Небесно-голубой
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
                      _buildPlayer(),
                      _buildObstacles(),
                      _buildPowerUps(),
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
                      const Icon(Icons.favorite, color: Colors.red, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        '${gameProvider.gameState.playerHealth}',
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
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        '${gameProvider.gameState.coins}',
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
            ],
          ),
        );
      },
    );
  }

  Widget _build3DScene() {
    return Container(
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
      child: CustomPaint(
        painter: Road3DPainter(_roadController.value),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildPlayer() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * 0.2 + 
                gameProvider.gameState.currentLane * 
                (MediaQuery.of(context).size.width * 0.6 / 3),
          top: MediaQuery.of(context).size.height * 0.7,
          child: AnimatedBuilder(
            animation: _playerController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + _playerController.value * 0.1,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
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
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildObstacles() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Stack(
          children: _obstacles.map((obstacle) {
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;
            final relativeZ = obstacle.position.z - gameProvider.gameState.distance;
            final screenY = screenHeight * 0.7 - relativeZ * 2;
            
            if (screenY < -50 || screenY > screenHeight) return const SizedBox.shrink();
            
            return Positioned(
              left: screenWidth * 0.2 + 
                    obstacle.lane * 
                    (screenWidth * 0.6 / 3) - 20,
              top: screenY,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B4513), Color(0xFFA0522D)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.terrain,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPowerUps() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Stack(
          children: _powerUps.map((powerUp) {
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;
            final relativeZ = powerUp.position.z - gameProvider.gameState.distance;
            final screenY = screenHeight * 0.7 - relativeZ * 2;
            
            if (screenY < -50 || screenY > screenHeight) return const SizedBox.shrink();
            
            IconData icon;
            List<Color> gradientColors;
            
            switch (powerUp.type) {
              case PowerUpType.health:
                icon = Icons.favorite;
                gradientColors = [Colors.red, Colors.pink];
                break;
              case PowerUpType.speed:
                icon = Icons.speed;
                gradientColors = [Colors.orange, Colors.deepOrange];
                break;
              case PowerUpType.shield:
                icon = Icons.shield;
                gradientColors = [Colors.blue, Colors.cyan];
                break;
              case PowerUpType.fireball:
                icon = Icons.local_fire_department;
                gradientColors = [Colors.red, Colors.orange];
                break;
              case PowerUpType.lightning:
                icon = Icons.flash_on;
                gradientColors = [Colors.yellow, Colors.amber];
                break;
              case PowerUpType.ice:
                icon = Icons.ac_unit;
                gradientColors = [Colors.cyan, Colors.blue];
                break;
              case PowerUpType.coin:
                icon = Icons.monetization_on;
                gradientColors = [Colors.amber, Colors.yellow];
                break;
            }
            
            return Positioned(
              left: screenWidth * 0.2 + 
                    powerUp.lane * 
                    (screenWidth * 0.6 / 3) - 20,
              top: screenY,
              child: AnimatedBuilder(
                animation: _roadController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _roadController.value * 2 * pi,
                    child: Container(
                      width: 40,
                      height: 40,
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
                        size: 25,
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.7),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  '🔥 БОСС АКТИВЕН! 🔥',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 5,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Здоровье босса: ${gameProvider.gameState.bossHealth}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: gameProvider.gameState.bossHealth / gameProvider.gameState.maxBossHealth,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
                const SizedBox(height: 10),
                Text(
                  'Собранные способности: ${gameProvider.gameState.collectedPowerUps.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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
          ),
        );
      },
    );
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

  Road3DPainter(this.animationValue);

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

// Улучшенные модели
class ObstacleEnhanced {
  final Vector3 position;
  final String type;
  final double damage;
  final int lane;

  ObstacleEnhanced({
    required this.position,
    required this.type,
    required this.damage,
    required this.lane,
  });
}

class PowerUpEnhanced {
  final Vector3 position;
  final PowerUpType type;
  final double value;
  final int lane;

  PowerUpEnhanced({
    required this.position,
    required this.type,
    required this.value,
    required this.lane,
  });
}
