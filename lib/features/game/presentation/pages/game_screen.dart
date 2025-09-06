import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/game_provider.dart';
import '../../../../core/models/game_models.dart';
import 'dart:async';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _playerController;
  late AnimationController _roadController;
  late Timer _gameTimer;
  
  final List<Obstacle> _obstacles = [];
  final List<PowerUp> _powerUps = [];
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
    if (_random.nextDouble() < 0.02) { // 2% шанс появления препятствия
      final lane = _random.nextInt(3);
      _obstacles.add(Obstacle(
        position: Vector3(lane * 2.0 - 2.0, 0, distance + 50),
        type: 'rock',
        damage: 20,
      ));
    }
  }

  void _generatePowerUps(double distance) {
    if (_random.nextDouble() < 0.03) { // 3% шанс появления усиления
      final lane = _random.nextInt(3);
      final powerUpTypes = PowerUpType.values.where((type) => type != PowerUpType.coin).toList();
      final type = powerUpTypes[_random.nextInt(powerUpTypes.length)];
      
      _powerUps.add(PowerUp(
        position: Vector3(lane * 2.0 - 2.0, 0, distance + 50),
        type: type,
        value: 1.0,
        lane: lane,
      ));
    }

    if (_random.nextDouble() < 0.05) { // 5% шанс появления монеты
      final lane = _random.nextInt(3);
      _powerUps.add(PowerUp(
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

  void _collectPowerUp(PowerUp powerUp) {
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
        // Атакующие способности для босса
        gameProvider.addPowerUp(powerUp);
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
                      _buildRoad(),
                      _buildPlayer(),
                      _buildObstacles(),
                      _buildPowerUps(),
                      if (Provider.of<GameProvider>(context).gameState.isBossFight)
                        _buildBoss(),
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

  Widget _buildRoad() {
    return AnimatedBuilder(
      animation: _roadController,
      builder: (context, child) {
        return CustomPaint(
          painter: RoadPainter(_roadController.value),
          size: Size.infinite,
        );
      },
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
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
                    (obstacle.position.x / 2 + 1) * 
                    (screenWidth * 0.6 / 3) - 15,
              top: screenY,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.brown,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.terrain,
                  color: Colors.white,
                  size: 20,
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
            Color color;
            
            switch (powerUp.type) {
              case PowerUpType.health:
                icon = Icons.favorite;
                color = Colors.red;
                break;
              case PowerUpType.speed:
                icon = Icons.speed;
                color = Colors.orange;
                break;
              case PowerUpType.shield:
                icon = Icons.shield;
                color = Colors.blue;
                break;
              case PowerUpType.fireball:
                icon = Icons.local_fire_department;
                color = Colors.red;
                break;
              case PowerUpType.lightning:
                icon = Icons.flash_on;
                color = Colors.yellow;
                break;
              case PowerUpType.ice:
                icon = Icons.ac_unit;
                color = Colors.cyan;
                break;
              case PowerUpType.coin:
                icon = Icons.monetization_on;
                color = Colors.amber;
                break;
            }
            
            return Positioned(
              left: screenWidth * 0.2 + 
                    powerUp.lane * 
                    (screenWidth * 0.6 / 3) - 15,
              top: screenY,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBoss() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * 0.2,
          top: MediaQuery.of(context).size.height * 0.1,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.dangerous,
                  color: Colors.white,
                  size: 40,
                ),
                Text(
                  'БОСС',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Здоровье: ${gameProvider.gameState.bossHealth}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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

class RoadPainter extends CustomPainter {
  final double animationValue;

  RoadPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;

    // Рисуем дорогу
    final roadWidth = size.width * 0.6;
    final roadLeft = size.width * 0.2;
    
    canvas.drawRect(
      Rect.fromLTWH(roadLeft, 0, roadWidth, size.height),
      paint,
    );

    // Рисуем разделительные линии
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

    // Рисуем движущиеся полосы
    final stripePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final stripeSpacing = 50.0;
    final stripeOffset = (animationValue * stripeSpacing) % stripeSpacing;

    for (double y = -stripeOffset; y < size.height + stripeSpacing; y += stripeSpacing) {
      canvas.drawLine(
        Offset(roadLeft + roadWidth / 3, y),
        Offset(roadLeft + roadWidth / 3, y + 20),
        stripePaint,
      );
      canvas.drawLine(
        Offset(roadLeft + roadWidth * 2 / 3, y),
        Offset(roadLeft + roadWidth * 2 / 3, y + 20),
        stripePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}