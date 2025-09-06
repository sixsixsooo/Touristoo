import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

import '../../../../core/models/game_models.dart';
import '../../../../core/services/game_service.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/config/app_config.dart';

class Game3DWidget extends StatefulWidget {
  final Function() onGameOver;
  final Function(int) onScoreUpdate;
  final Function(double) onDistanceUpdate;
  final Function(int) onHealthUpdate;
  final Function(int) onCoinCollected;
  final Function(String) onObstacleHit;
  final Function(String) onPowerUpCollected;
  final Function(int) onLevelUp;
  final bool isPaused;

  const Game3DWidget({
    super.key,
    required this.onGameOver,
    required this.onScoreUpdate,
    required this.onDistanceUpdate,
    required this.onHealthUpdate,
    required this.onCoinCollected,
    required this.onObstacleHit,
    required this.onPowerUpCollected,
    required this.onLevelUp,
    required this.isPaused,
  });

  @override
  State<Game3DWidget> createState() => _Game3DWidgetState();
}

class _Game3DWidgetState extends State<Game3DWidget>
    with TickerProviderStateMixin {
  late FlutterGlPlugin flutterGlPlugin;
  late int fboId;
  late int programId;
  late int positionLoc;
  late int colorLoc;
  late int mvpMatrixLoc;
  
  late vm.Vector3 cameraPosition;
  late vm.Vector3 cameraTarget;
  late vm.Matrix4 viewMatrix;
  late vm.Matrix4 projectionMatrix;
  late vm.Matrix4 mvpMatrix;
  
  late Timer gameTimer;
  late GameService gameService;
  late AudioService audioService;
  
  GameState gameState = GameState.initial();
  List<Obstacle> obstacles = [];
  List<PowerUp> powerUps = [];
  vm.Vector3 playerPosition = vm.Vector3(0, 0, 0);
  double gameSpeed = AppConfig.initialGameSpeed;
  int currentLevel = 1;
  
  bool isInitialized = false;
  DateTime lastFrameTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    gameService = GameService();
    audioService = AudioService();
    _initializeGame();
  }

  @override
  void dispose() {
    gameTimer.cancel();
    super.dispose();
  }

  void _initializeGame() {
    gameState = gameState.copyWith(isRunning: true);
    _generateInitialObjects();
    _startGameLoop();
  }

  void _generateInitialObjects() {
    obstacles = gameService.generateObstacles(20, gameState.distance);
    powerUps = gameService.generatePowerUps(30, gameState.distance);
  }

  void _startGameLoop() {
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!widget.isPaused && gameState.isRunning) {
        _updateGame();
      }
    });
  }

  void _updateGame() {
    final now = DateTime.now();
    final deltaTime = now.difference(lastFrameTime).inMilliseconds / 1000.0;
    lastFrameTime = now;

    // Update game speed
    gameSpeed = gameService.calculateGameSpeed(gameState.distance, currentLevel);
    
    // Update game state
    gameState = gameService.updateGameState(
      gameState,
      deltaTime,
      obstacles,
      powerUps,
      playerPosition,
    );

    // Update UI
    widget.onScoreUpdate(gameState.score);
    widget.onDistanceUpdate(gameState.distance);
    widget.onHealthUpdate(gameState.playerHealth);

    // Check for level up
    final newLevel = gameService.calculateLevel(gameState.distance);
    if (newLevel > currentLevel) {
      currentLevel = newLevel;
      widget.onLevelUp(newLevel);
      audioService.playLevelUpSound();
    }

    // Update obstacles
    for (final obstacle in obstacles) {
      if (obstacle.isActive) {
        obstacle.position.z += gameSpeed * deltaTime;
        
        // Check collision
        if (gameService.checkCollision(playerPosition, obstacle.position, 1.0)) {
          widget.onObstacleHit(obstacle.type.name);
          audioService.playCollisionSound();
        }
        
        // Reset obstacle position
        if (obstacle.position.z > 20) {
          obstacle.position.z = -1000;
          obstacle.position.x = (Random().nextInt(3) - 1) * 2.0;
        }
      }
    }

    // Update power-ups
    for (final powerUp in powerUps) {
      if (powerUp.isActive) {
        powerUp.position.z += gameSpeed * deltaTime;
        
        // Check collision
        if (gameService.checkCollision(playerPosition, powerUp.position, 0.8)) {
          widget.onPowerUpCollected(powerUp.type.name);
          audioService.playPowerUpSound();
          
          switch (powerUp.type) {
            case PowerUpType.coin:
              widget.onCoinCollected(powerUp.value);
              break;
            case PowerUpType.health:
              // Health boost handled in game state update
              break;
            case PowerUpType.speed:
              // Speed boost handled in game speed calculation
              break;
            case PowerUpType.shield:
              // Shield logic would be implemented here
              break;
          }
          
          powerUp.isActive = false;
        }
        
        // Reset power-up position
        if (powerUp.position.z > 20) {
          powerUp.position.z = -1000;
          powerUp.position.x = (Random().nextInt(3) - 1) * 2.0;
        }
      }
    }

    // Check game over
    if (gameState.playerHealth <= 0) {
      gameState = gameState.copyWith(isRunning: false);
      audioService.playGameOverSound();
      widget.onGameOver();
    }

    setState(() {});
  }

  void _handleTouch(double x, double y, double screenWidth) {
    if (widget.isPaused || !gameState.isRunning) return;

    // Simple lane switching based on touch position
    if (x < screenWidth / 3) {
      // Left lane
      playerPosition.x = (playerPosition.x - 2).clamp(-2.0, 2.0);
    } else if (x > (screenWidth * 2) / 3) {
      // Right lane
      playerPosition.x = (playerPosition.x + 2).clamp(-2.0, 2.0);
    }
    // Center lane is default (0)
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        _handleTouch(details.localPosition.dx, details.localPosition.dy, screenWidth);
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: _build3DScene(),
      ),
    );
  }

  Widget _build3DScene() {
    return CustomPaint(
      painter: Game3DPainter(
        gameState: gameState,
        obstacles: obstacles,
        powerUps: powerUps,
        playerPosition: playerPosition,
        gameSpeed: gameSpeed,
      ),
      size: Size.infinite,
    );
  }
}

class Game3DPainter extends CustomPainter {
  final GameState gameState;
  final List<Obstacle> obstacles;
  final List<PowerUp> powerUps;
  final vm.Vector3 playerPosition;
  final double gameSpeed;

  Game3DPainter({
    required this.gameState,
    required this.obstacles,
    required this.powerUps,
    required this.playerPosition,
    required this.gameSpeed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Clear canvas
    canvas.drawColor(Colors.black, BlendMode.clear);
    
    // Draw background gradient
    _drawBackground(canvas, size);
    
    // Draw road
    _drawRoad(canvas, size);
    
    // Draw obstacles
    _drawObstacles(canvas, size);
    
    // Draw power-ups
    _drawPowerUps(canvas, size);
    
    // Draw player
    _drawPlayer(canvas, size);
    
    // Draw UI elements
    _drawUI(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1A1A2E),
          Color(0xFF16213E),
          Color(0xFF0F0F23),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawRoad(Canvas canvas, Size size) {
    final roadWidth = size.width * 0.6;
    final roadHeight = size.height;
    final roadX = (size.width - roadWidth) / 2;
    
    // Main road
    final roadPaint = Paint()..color = const Color(0xFF2C2C2C);
    canvas.drawRect(Rect.fromLTWH(roadX, 0, roadWidth, roadHeight), roadPaint);
    
    // Lane dividers
    final laneWidth = roadWidth / 3;
    final dividerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    
    for (int i = 1; i < 3; i++) {
      final x = roadX + (i * laneWidth);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, roadHeight),
        dividerPaint,
      );
    }
    
    // Road markings
    final markingPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 1;
    
    for (double y = 0; y < roadHeight; y += 20) {
      canvas.drawLine(
        Offset(roadX + laneWidth, y),
        Offset(roadX + laneWidth, y + 10),
        markingPaint,
      );
    }
  }

  void _drawObstacles(Canvas canvas, Size size) {
    final roadWidth = size.width * 0.6;
    final roadX = (size.width - roadWidth) / 2;
    final laneWidth = roadWidth / 3;
    
    for (final obstacle in obstacles) {
      if (!obstacle.isActive) continue;
      
      // Convert 3D position to 2D screen position
      final screenX = roadX + (obstacle.position.x + 2) * laneWidth / 2;
      final screenY = size.height * 0.7; // Fixed Y position for obstacles
      
      final paint = Paint()..color = _getObstacleColor(obstacle.type);
      
      // Draw obstacle based on type
      switch (obstacle.type) {
        case ObstacleType.jump:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(screenX, screenY),
              width: 30,
              height: 40,
            ),
            paint,
          );
          break;
        case ObstacleType.slide:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(screenX, screenY + 20),
              width: 40,
              height: 20,
            ),
            paint,
          );
          break;
        case ObstacleType.duck:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(screenX, screenY + 10),
              width: 25,
              height: 30,
            ),
            paint,
          );
          break;
      }
    }
  }

  void _drawPowerUps(Canvas canvas, Size size) {
    final roadWidth = size.width * 0.6;
    final roadX = (size.width - roadWidth) / 2;
    final laneWidth = roadWidth / 3;
    
    for (final powerUp in powerUps) {
      if (!powerUp.isActive) continue;
      
      // Convert 3D position to 2D screen position
      final screenX = roadX + (powerUp.position.x + 2) * laneWidth / 2;
      final screenY = size.height * 0.6; // Fixed Y position for power-ups
      
      final paint = Paint()..color = _getPowerUpColor(powerUp.type);
      
      // Draw power-up based on type
      switch (powerUp.type) {
        case PowerUpType.coin:
          canvas.drawCircle(Offset(screenX, screenY), 15, paint);
          break;
        case PowerUpType.health:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(screenX, screenY),
              width: 20,
              height: 20,
            ),
            paint,
          );
          break;
        case PowerUpType.speed:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(screenX, screenY),
              width: 25,
              height: 15,
            ),
            paint,
          );
          break;
        case PowerUpType.shield:
          canvas.drawCircle(Offset(screenX, screenY), 12, paint);
          break;
      }
    }
  }

  void _drawPlayer(Canvas canvas, Size size) {
    final roadWidth = size.width * 0.6;
    final roadX = (size.width - roadWidth) / 2;
    final laneWidth = roadWidth / 3;
    
    final screenX = roadX + (playerPosition.x + 2) * laneWidth / 2;
    final screenY = size.height * 0.8;
    
    final paint = Paint()..color = const Color(0xFF4A90E2);
    
    // Draw player as a simple rectangle
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(screenX, screenY),
        width: 25,
        height: 35,
      ),
      paint,
    );
  }

  void _drawUI(Canvas canvas, Size size) {
    // Draw score
    final scoreText = TextPainter(
      text: TextSpan(
        text: 'Score: ${gameState.score}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    scoreText.layout();
    scoreText.paint(canvas, const Offset(20, 50));
    
    // Draw distance
    final distanceText = TextPainter(
      text: TextSpan(
        text: 'Distance: ${gameState.distance.toStringAsFixed(0)}m',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    distanceText.layout();
    distanceText.paint(canvas, const Offset(20, 80));
    
    // Draw health bar
    final healthBarWidth = 200.0;
    final healthBarHeight = 20.0;
    final healthBarX = size.width - healthBarWidth - 20;
    final healthBarY = 50.0;
    
    // Health bar background
    final healthBgPaint = Paint()..color = Colors.red.withOpacity(0.3);
    canvas.drawRect(
      Rect.fromLTWH(healthBarX, healthBarY, healthBarWidth, healthBarHeight),
      healthBgPaint,
    );
    
    // Health bar fill
    final healthFillPaint = Paint()..color = Colors.green;
    final healthFillWidth = healthBarWidth * (gameState.playerHealth / 100);
    canvas.drawRect(
      Rect.fromLTWH(healthBarX, healthBarY, healthFillWidth, healthBarHeight),
      healthFillPaint,
    );
    
    // Health text
    final healthText = TextPainter(
      text: TextSpan(
        text: 'Health: ${gameState.playerHealth}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    healthText.layout();
    healthText.paint(canvas, Offset(healthBarX, healthBarY + 25));
  }

  Color _getObstacleColor(ObstacleType type) {
    switch (type) {
      case ObstacleType.jump:
        return Colors.red;
      case ObstacleType.slide:
        return Colors.orange;
      case ObstacleType.duck:
        return Colors.purple;
    }
  }

  Color _getPowerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.coin:
        return Colors.yellow;
      case PowerUpType.health:
        return Colors.green;
      case PowerUpType.speed:
        return Colors.blue;
      case PowerUpType.shield:
        return Colors.cyan;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
