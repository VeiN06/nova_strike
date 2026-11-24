import 'dart:math';
import 'package:flutter/material.dart';

enum EnemyType {
  drone,
  interceptor,
  cruiser,
  boss,
}

class Enemy {
  double x;
  double y;
  double vx;
  double vy;
  double health;
  final double maxHealth;
  final EnemyType type;
  final double radius;
  final Color primaryColor;
  final int scoreValue;
  final int scrapReward;

  // Behavior & AI timers
  double shootCooldown;
  double shootTimer;
  double phaseTimer;
  double angle;
  final double initialX;
  bool isEnraged;

  Enemy({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.health,
    required this.maxHealth,
    required this.type,
    required this.radius,
    required this.primaryColor,
    required this.scoreValue,
    required this.scrapReward,
    required this.shootCooldown,
    this.shootTimer = 0.0,
    this.phaseTimer = 0.0,
    this.angle = 0.0,
    required this.initialX,
    this.isEnraged = false,
  });

  factory Enemy.createDrone(double x, double y, double speedFactor) {
    return Enemy(
      x: x,
      y: y,
      vx: 0,
      vy: 110.0 * speedFactor,
      health: 20.0,
      maxHealth: 20.0,
      type: EnemyType.drone,
      radius: 16.0,
      primaryColor: const Color(0xFFFF5252), // Neon red
      scoreValue: 100,
      scrapReward: 5,
      shootCooldown: 2.2 / speedFactor,
      initialX: x,
    );
  }

  factory Enemy.createInterceptor(double x, double y, double speedFactor) {
    return Enemy(
      x: x,
      y: y,
      vx: 80.0 * speedFactor,
      vy: 60.0 * speedFactor,
      health: 55.0,
      maxHealth: 55.0,
      type: EnemyType.interceptor,
      radius: 22.0,
      primaryColor: const Color(0xFFFF9100), // Neon amber
      scoreValue: 250,
      scrapReward: 12,
      shootCooldown: 1.5 / speedFactor,
      initialX: x,
    );
  }

  factory Enemy.createCruiser(double x, double y, double speedFactor) {
    return Enemy(
      x: x,
      y: y,
      vx: 30.0,
      vy: 35.0 * speedFactor,
      health: 180.0,
      maxHealth: 180.0,
      type: EnemyType.cruiser,
      radius: 34.0,
      primaryColor: const Color(0xFFD500F9), // Neon violet
      scoreValue: 600,
      scrapReward: 30,
      shootCooldown: 1.8 / speedFactor,
      initialX: x,
    );
  }

  factory Enemy.createBoss(double x, double y, int waveNumber) {
    // Exponential health scaling so bosses stay challenging late game
    final hp = 1200.0 * pow(1.35, waveNumber - 1) + (waveNumber * 450.0);
    return Enemy(
      x: x,
      y: y,
      vx: 70.0 + (waveNumber * 12.0),
      vy: 0.0,
      health: hp,
      maxHealth: hp,
      type: EnemyType.boss,
      radius: 65.0 + (waveNumber * 2.0),
      primaryColor: const Color(0xFFFF1744), // Crimson boss glow
      scoreValue: 5000 + waveNumber * 1000,
      scrapReward: 200 + waveNumber * 50,
      shootCooldown: max(0.45, 0.9 - (waveNumber * 0.06)),
      initialX: x,
    );
  }

  // Update AI movement and timers
  bool update(double dt, double width, double height) {
    phaseTimer += dt;
    shootTimer += dt;

    switch (type) {
      case EnemyType.drone:
        // Sinusoidal weave while descending
        x = initialX + sin(phaseTimer * 3.5) * 45.0;
        y += vy * dt;
        break;

      case EnemyType.interceptor:
        // Bounce horizontally across screen
        x += vx * dt;
        y += vy * dt;
        if (x < radius + 15 || x > width - radius - 15) {
          vx = -vx;
        }
        break;

      case EnemyType.cruiser:
        // Slow advance, swaying
        x = initialX + sin(phaseTimer * 1.5) * 60.0;
        if (y < height * 0.35) {
          y += vy * dt;
        } else {
          // Hover around 35% screen height
          y = (height * 0.35) + sin(phaseTimer * 2.0) * 15.0;
        }
        break;

      case EnemyType.boss:
        // Move to top-center hover position
        if (y < 120.0) {
          y += 50.0 * dt;
        } else {
          x += vx * dt;
          if (x < radius + 30 || x > width - radius - 30) {
            vx = -vx;
          }
          y = 120.0 + sin(phaseTimer * 2.2) * 20.0;
        }

        // Enrage below 40% health
        if (!isEnraged && health < maxHealth * 0.4) {
          isEnraged = true;
          shootCooldown *= 0.65; // Much faster firing!
          vx *= 1.4;
        }
        break;
    }

    return y < height + 80;
  }
}
