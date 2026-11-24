import 'dart:math';
import 'package:flutter/material.dart';
import '../models/particle.dart';

class ParticleSystem {
  final List<Particle> particles = [];
  final List<DamageNumber> damageNumbers = [];
  final Random _random = Random();

  // Hard caps. Without them a dense wave's explosions stack up faster than they
  // decay and the frame time climbs until the game visibly stutters.
  static const int _maxParticles = 260;
  static const int _maxDamageNumbers = 24;

  void update(double dt) {
    particles.removeWhere((p) => !p.update(dt));
    damageNumbers.removeWhere((d) => !d.update(dt));
  }

  // Drops the oldest particles so the list never grows past the cap.
  void _trim() {
    final overflow = particles.length - _maxParticles;
    if (overflow > 0) {
      particles.removeRange(0, overflow);
    }
  }

  // Neon explosion on enemy destruction
  void spawnExplosion(double x, double y, Color color, {int count = 28, double radius = 3.5}) {
    // When the screen is already full of effects, spawn a smaller burst.
    if (particles.length > _maxParticles * 0.8) {
      count = (count / 2).round();
    }

    // 1. Shockwave ring
    particles.add(
      Particle(
        x: x,
        y: y,
        vx: 0,
        vy: 0,
        radius: 6.0,
        initialRadius: 28.0,
        color: color.withOpacity(0.9),
        life: 0.45,
        decayRate: 2.2,
        shape: ParticleShape.shockwaveRing,
      ),
    );

    // 2. High-speed sparks
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 60.0 + _random.nextDouble() * 220.0;
      final sparkColor = _random.nextBool()
          ? color
          : (_random.nextBool() ? const Color(0xFF00E5FF) : Colors.white);

      particles.add(
        Particle(
          x: x,
          y: y,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          radius: radius * (0.6 + _random.nextDouble() * 0.8),
          initialRadius: radius * (0.6 + _random.nextDouble() * 0.8),
          color: sparkColor,
          life: 0.4 + _random.nextDouble() * 0.4,
          decayRate: 1.2 + _random.nextDouble() * 1.0,
          shape: _random.nextBool() ? ParticleShape.spark : ParticleShape.circle,
        ),
      );
    }
    _trim();
  }

  // Thruster particle exhaust
  void spawnThrusterTrail(double x, double y, bool isBoost) {
    final count = isBoost ? 3 : 1;
    for (int i = 0; i < count; i++) {
      final vx = (_random.nextDouble() - 0.5) * 35.0;
      final vy = 80.0 + _random.nextDouble() * 70.0;
      final color = _random.nextBool()
          ? const Color(0xFF00E5FF) // Cyan plasma
          : const Color(0xFFFF007F); // Neon magenta

      particles.add(
        Particle(
          x: x + (_random.nextDouble() - 0.5) * 6.0,
          y: y,
          vx: vx,
          vy: vy,
          radius: 3.5,
          initialRadius: 3.5,
          color: color.withOpacity(0.8),
          life: 0.25,
          decayRate: 4.0,
          shape: ParticleShape.circle,
        ),
      );
    }
    _trim();
  }

  // Shield hit impact ripple
  void spawnShieldImpact(double x, double y) {
    particles.add(
      Particle(
        x: x,
        y: y,
        vx: 0,
        vy: 0,
        radius: 8.0,
        initialRadius: 20.0,
        color: const Color(0xFF00E5FF).withOpacity(0.85),
        life: 0.3,
        decayRate: 3.3,
        shape: ParticleShape.shockwaveRing,
      ),
    );
  }

  // Super Nova screen blast
  void spawnNovaBlast(double x, double y, double screenWidth, double screenHeight) {
    // Massive concentric shockwaves
    for (int ring = 1; ring <= 3; ring++) {
      particles.add(
        Particle(
          x: x,
          y: y,
          vx: 0,
          vy: 0,
          radius: 12.0 * ring,
          initialRadius: 180.0 * ring,
          color: const Color(0xFFD500F9).withOpacity(0.9),
          life: 0.65,
          decayRate: 1.5,
          shape: ParticleShape.shockwaveRing,
        ),
      );
    }

    // Dense radial spark blast
    for (int i = 0; i < 90; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 120.0 + _random.nextDouble() * 450.0;
      final color = i % 2 == 0
          ? const Color(0xFF00E5FF)
          : (i % 3 == 0 ? const Color(0xFFFFD700) : const Color(0xFFFF007F));

      particles.add(
        Particle(
          x: x,
          y: y,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          radius: 4.0 + _random.nextDouble() * 4.0,
          initialRadius: 5.0,
          color: color,
          life: 0.6 + _random.nextDouble() * 0.4,
          decayRate: 1.2,
          shape: ParticleShape.spark,
        ),
      );
    }
    _trim();
  }

  // Floating damage number
  void addDamageText(double x, double y, String text, Color color, {bool isCritical = false}) {
    if (damageNumbers.length >= _maxDamageNumbers) {
      damageNumbers.removeAt(0);
    }
    damageNumbers.add(
      DamageNumber(
        x: x + (_random.nextDouble() - 0.5) * 20.0,
        y: y - 10.0,
        text: text,
        color: color,
        isCritical: isCritical,
      ),
    );
  }

  void clear() {
    particles.clear();
    damageNumbers.clear();
  }
}
