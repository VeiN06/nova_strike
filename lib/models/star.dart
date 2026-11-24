import 'dart:math';
import 'package:flutter/material.dart';

class Star {
  double x;
  double y;
  final double size;
  final double speed;
  final Color color;
  final int layer;
  double twinkleOffset;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.layer,
    required this.twinkleOffset,
  });

  factory Star.random(double width, double height, Random random) {
    final layer = random.nextInt(3); // 0 = distant dust, 1 = mid star, 2 = ambient star
    double speed;
    double size;
    Color color;

    final safeWidth = width > 50 ? width : 450.0;
    final safeHeight = height > 50 ? height : 900.0;

    switch (layer) {
      case 0:
        speed = 10.0 + random.nextDouble() * 18.0;
        size = 1.0;
        // Deep dim background cosmic dust
        color = const Color(0xFF5C6BC0).withOpacity(0.18 + random.nextDouble() * 0.15);
        break;
      case 1:
        speed = 28.0 + random.nextDouble() * 30.0;
        size = 1.5;
        // Subtle soft violet / deep cyan
        color = (random.nextBool()
                ? const Color(0xFF7E57C2)
                : const Color(0xFF26C6DA))
            .withOpacity(0.25 + random.nextDouble() * 0.2);
        break;
      case 2:
      default:
        speed = 50.0 + random.nextDouble() * 45.0;
        size = 2.0;
        // Soft white ambient star
        color = Colors.white.withOpacity(0.35 + random.nextDouble() * 0.2);
        break;
    }

    return Star(
      x: random.nextDouble() * safeWidth,
      y: random.nextDouble() * safeHeight,
      size: size,
      speed: speed,
      color: color,
      layer: layer,
      twinkleOffset: random.nextDouble() * 2 * pi,
    );
  }

  void update(double dt, double width, double height, double speedMultiplier) {
    y += speed * speedMultiplier * dt;
    twinkleOffset += dt * 2.0;
    if (y > height) {
      y = 0;
      x = Random().nextDouble() * width;
    }
  }
}
