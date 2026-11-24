import 'dart:math';
import 'package:flutter/material.dart';

enum PowerUpType {
  scrap,
  shield,
  energy,
  triShot,
  overdrive,
}

class PowerUp {
  double x;
  double y;
  double vx;
  double vy;
  final PowerUpType type;
  final double radius;
  final Color color;
  final int value;
  double pulseTimer;

  PowerUp({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.type,
    required this.radius,
    required this.color,
    this.value = 1,
    this.pulseTimer = 0.0,
  });

  factory PowerUp.createRandom(double x, double y, Random random) {
    final roll = random.nextDouble();
    if (roll < 0.50) {
      // Golden Scrap / Coin (Highly visible gold)
      return PowerUp(
        x: x,
        y: y,
        vx: (random.nextDouble() - 0.5) * 50,
        vy: 45.0 + random.nextDouble() * 35,
        type: PowerUpType.scrap,
        radius: 16.0,
        color: const Color(0xFFFFD700), // Pure Gold
        value: 10 + random.nextInt(20),
      );
    } else if (roll < 0.70) {
      // Quantum Shield Cell
      return PowerUp(
        x: x,
        y: y,
        vx: (random.nextDouble() - 0.5) * 40,
        vy: 35.0 + random.nextDouble() * 25,
        type: PowerUpType.shield,
        radius: 18.0,
        color: const Color(0xFF00E5FF), // Electric Cyan
        value: 40,
      );
    } else if (roll < 0.85) {
      // Green Energy Battery
      return PowerUp(
        x: x,
        y: y,
        vx: (random.nextDouble() - 0.5) * 40,
        vy: 35.0 + random.nextDouble() * 25,
        type: PowerUpType.energy,
        radius: 17.0,
        color: const Color(0xFF76FF03), // Neon Lime Green
        value: 35,
      );
    } else if (roll < 0.94) {
      // Magenta Tri-Shot Booster
      return PowerUp(
        x: x,
        y: y,
        vx: (random.nextDouble() - 0.5) * 30,
        vy: 30.0 + random.nextDouble() * 20,
        type: PowerUpType.triShot,
        radius: 18.0,
        color: const Color(0xFFFF007F), // Neon Magenta
        value: 12, // 12 seconds duration
      );
    } else {
      // Violet Overdrive Nova Orb
      return PowerUp(
        x: x,
        y: y,
        vx: (random.nextDouble() - 0.5) * 30,
        vy: 28.0 + random.nextDouble() * 20,
        type: PowerUpType.overdrive,
        radius: 20.0,
        color: const Color(0xFFD500F9), // Cyber Violet
        value: 1,
      );
    }
  }

  bool update(double dt, double height, double targetX, double targetY, double magnetRadius) {
    pulseTimer += dt * 5.0;

    final dx = targetX - x;
    final dy = targetY - y;
    final dist = sqrt(dx * dx + dy * dy);

    if (dist < magnetRadius && dist > 0.001) {
      final pullStrength = (1.0 - dist / magnetRadius) * 550.0 + 150.0;
      vx += (dx / dist) * pullStrength * dt;
      vy += (dy / dist) * pullStrength * dt;
    } else {
      vy += 10.0 * dt;
      vx *= (1.0 - 0.3 * dt);
    }

    x += vx * dt;
    y += vy * dt;

    return y < height + 60;
  }
}
