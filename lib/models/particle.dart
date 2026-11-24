import 'dart:math';
import 'package:flutter/material.dart';

enum ParticleShape {
  circle,
  spark,
  shockwaveRing,
  warpLine,
  glowSquare,
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  final double initialRadius;
  final Color color;
  double life; // from 1.0 down to 0.0
  final double decayRate;
  final ParticleShape shape;
  final double rotation;
  final double rotationSpeed;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.initialRadius,
    required this.color,
    required this.life,
    required this.decayRate,
    this.shape = ParticleShape.circle,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
  });

  bool update(double dt) {
    x += vx * dt;
    y += vy * dt;
    // Slight drag / deceleration
    vx *= (1.0 - 0.5 * dt);
    vy *= (1.0 - 0.5 * dt);

    life -= decayRate * dt;
    if (shape == ParticleShape.shockwaveRing) {
      radius += (initialRadius * 4.0) * dt;
    } else {
      radius = initialRadius * max(0.0, life);
    }

    return life > 0;
  }
}

class DamageNumber {
  double x;
  double y;
  final String text;
  final Color color;
  final bool isCritical;
  double life; // 1.0 to 0.0
  final double maxLife;

  DamageNumber({
    required this.x,
    required this.y,
    required this.text,
    required this.color,
    this.isCritical = false,
    this.life = 1.0,
    this.maxLife = 0.8,
  });

  bool update(double dt) {
    y -= 35.0 * dt;
    life -= dt / maxLife;
    return life > 0;
  }
}
