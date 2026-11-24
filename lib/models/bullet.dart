import 'dart:math';
import 'package:flutter/material.dart';

enum BulletType {
  blaster,
  plasma,
  missile,
  empWave,
  enemyBlaster,
  enemyOrb,
  bossLaser,
}

class Bullet {
  double x;
  double y;
  double vx;
  double vy;
  double damage;
  final BulletType type;
  final bool isPlayer;
  final Color color;
  final double radius;
  double life;
  double angle;
  int penetration; // How many targets it can pierce

  Bullet({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.damage,
    required this.type,
    required this.isPlayer,
    required this.color,
    required this.radius,
    this.life = 4.0,
    this.angle = 0.0,
    this.penetration = 1,
  });

  bool update(double dt, double width, double height) {
    x += vx * dt;
    y += vy * dt;
    life -= dt;

    // Bounds check
    if (x < -50 || x > width + 50 || y < -60 || y > height + 60 || life <= 0) {
      return false;
    }
    return true;
  }

  // Steer towards target for homing missiles
  void steerTowards(double targetX, double targetY, double turnRate, double dt) {
    if (type != BulletType.missile) return;
    final dx = targetX - x;
    final dy = targetY - y;
    final targetAngle = atan2(dy, dx);

    // Smooth angle interpolation
    double diff = targetAngle - angle;
    while (diff < -pi) {
      diff += 2 * pi;
    }
    while (diff > pi) {
      diff -= 2 * pi;
    }

    angle += diff * min(1.0, turnRate * dt);
    final speed = sqrt(vx * vx + vy * vy);
    vx = cos(angle) * speed;
    vy = sin(angle) * speed;
  }
}
