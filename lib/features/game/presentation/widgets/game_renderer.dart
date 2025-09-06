import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart' as math;
import '../../../core/models/game_models.dart';
import '../../../core/config/app_config.dart';

class GameRenderer extends StatefulWidget {
  final GameState gameState;
  final Function(Vector3) onPlayerMove;
  final Function() onJump;

  const GameRenderer({
    super.key,
    required this.gameState,
    required this.onPlayerMove,
    required this.onJump,
  });

  @override
  State<GameRenderer> createState() => _GameRendererState();
}

class _GameRendererState extends State<GameRenderer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 16), // 60 FPS
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final delta = details.delta.dx / 100;
        final newPosition = Vector3(
          (widget.gameState.playerPosition.x + delta).clamp(-2.0, 2.0),
          widget.gameState.playerPosition.y,
          widget.gameState.playerPosition.z,
        );
        widget.onPlayerMove(newPosition);
      },
      onTap: () {
        widget.onJump();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: Game3DPainter(
              gameState: widget.gameState,
              animationValue: _animation.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class Game3DPainter extends CustomPainter {
  final GameState gameState;
  final double animationValue;

  Game3DPainter({
    required this.gameState,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Простая 3D проекция
    _drawGround(canvas, size, paint);
    _drawPlayer(canvas, centerX, centerY, paint);
    _drawObstacles(canvas, centerX, centerY, paint);
    _drawCoins(canvas, centerX, centerY, paint);
    _drawPowerUps(canvas, centerX, centerY, paint);
  }

  void _drawGround(Canvas canvas, Size size, Paint paint) {
    // Рисуем дорожку
    paint.color = Colors.grey[300]!;
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width, size.height * 0.7);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Рисуем линии дороги
    paint.color = Colors.white;
    paint.strokeWidth = 2;
    for (int i = 0; i < 5; i++) {
      final y = size.height * 0.7 + (i * size.height * 0.3 / 5);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawPlayer(Canvas canvas, double centerX, double centerY, Paint paint) {
    // Проекция игрока
    final playerX = centerX + (gameState.playerPosition.x * 50);
    final playerY = centerY - (gameState.playerPosition.y * 30);
    final playerZ = gameState.playerPosition.z;

    // Простая 3D проекция
    final scale = 1.0 / (1.0 + playerZ * 0.1);
    final projectedX = playerX * scale;
    final projectedY = playerY * scale;

    // Рисуем игрока как круг
    paint.color = Colors.blue;
    canvas.drawCircle(
      Offset(projectedX, projectedY),
      20 * scale,
      paint,
    );

    // Рисуем тень
    paint.color = Colors.black.withOpacity(0.3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(projectedX, projectedY + 15 * scale),
        width: 30 * scale,
        height: 10 * scale,
      ),
      paint,
    );
  }

  void _drawObstacles(Canvas canvas, double centerX, double centerY, Paint paint) {
    paint.color = Colors.red;
    
    for (final obstacle in gameState.obstacles) {
      final obstacleX = centerX + (obstacle.position.x * 50);
      final obstacleY = centerY - (obstacle.position.y * 30);
      final obstacleZ = obstacle.position.z;

      final scale = 1.0 / (1.0 + obstacleZ * 0.1);
      final projectedX = obstacleX * scale;
      final projectedY = obstacleY * scale;

      // Рисуем препятствие как прямоугольник
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(projectedX, projectedY),
          width: 30 * scale,
          height: 40 * scale,
        ),
        paint,
      );
    }
  }

  void _drawCoins(Canvas canvas, double centerX, double centerY, Paint paint) {
    paint.color = Colors.yellow;
    
    for (final coin in gameState.coins) {
      final coinX = centerX + (coin.position.x * 50);
      final coinY = centerY - (coin.position.y * 30);
      final coinZ = coin.position.z;

      final scale = 1.0 / (1.0 + coinZ * 0.1);
      final projectedX = coinX * scale;
      final projectedY = coinY * scale;

      // Анимация вращения монеты
      final rotation = animationValue * 2 * math.pi;
      final rotatedX = projectedX + math.cos(rotation) * 5;
      final rotatedY = projectedY + math.sin(rotation) * 5;

      // Рисуем монету как круг
      canvas.drawCircle(
        Offset(rotatedX, rotatedY),
        15 * scale,
        paint,
      );

      // Рисуем блеск
      paint.color = Colors.white;
      canvas.drawCircle(
        Offset(rotatedX - 5 * scale, rotatedY - 5 * scale),
        5 * scale,
        paint,
      );
      paint.color = Colors.yellow;
    }
  }

  void _drawPowerUps(Canvas canvas, double centerX, double centerY, Paint paint) {
    for (final powerUp in gameState.powerUps) {
      final powerUpX = centerX + (powerUp.position.x * 50);
      final powerUpY = centerY - (powerUp.position.y * 30);
      final powerUpZ = powerUp.position.z;

      final scale = 1.0 / (1.0 + powerUpZ * 0.1);
      final projectedX = powerUpX * scale;
      final projectedY = powerUpY * scale;

      // Разные цвета для разных типов бонусов
      switch (powerUp.type) {
        case 'health':
          paint.color = Colors.green;
          break;
        case 'speed':
          paint.color = Colors.orange;
          break;
        case 'shield':
          paint.color = Colors.purple;
          break;
        default:
          paint.color = Colors.cyan;
      }

      // Рисуем бонус как звезду
      _drawStar(canvas, Offset(projectedX, projectedY), 20 * scale, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final angle = math.pi / 5; // 36 degrees
    
    for (int i = 0; i < 10; i++) {
      final r = (i % 2 == 0) ? radius : radius * 0.5;
      final x = center.dx + r * math.cos(i * angle - math.pi / 2);
      final y = center.dy + r * math.sin(i * angle - math.pi / 2);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
