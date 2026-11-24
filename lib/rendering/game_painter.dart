import 'dart:math';
import 'package:flutter/material.dart';
import '../engine/game_engine.dart';
import '../models/bullet.dart';
import '../models/enemy.dart';
import '../models/particle.dart';
import '../models/powerup.dart';
import 'ship_designs.dart';

class GamePainter extends CustomPainter {
  final GameEngine engine;
  final int themeIndex;
  final Random _random = Random();

  // ------------------------------------------------------------------
  // All paints, shaders and text layout objects are created ONCE and reused
  // every frame. Creating a new Paint / gradient / TextSpan per bullet,
  // per particle or per star every frame is what makes the frame time creep
  // up as a session runs longer.
  // ------------------------------------------------------------------

  // Bullets
  static final Paint _bulletGlow = Paint()..style = PaintingStyle.fill;
  static final Paint _bulletFill = Paint()..style = PaintingStyle.fill;

  // Power-ups
  static final Paint _powerGlow = Paint()..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;
  static final Paint _powerRing = Paint()..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  static final Paint _powerFill = Paint()..style = PaintingStyle.fill;
  static final Paint _powerCore = Paint()..style = PaintingStyle.fill;
  static final Paint _powerCross = Paint()..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  // Particles
  static final Paint _particlePaint = Paint()..style = PaintingStyle.fill;

  // Enemies (health bar)
  static final Paint _enemyBarBg = Paint();
  static final Paint _enemyBarFill = Paint();
  static final Paint _enemyBarBorder = Paint()..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;

  // Stars
  static final Paint _starPaint = Paint()..style = PaintingStyle.fill;

  // Background dust
  static final Paint _dustPaint = Paint()..style = PaintingStyle.fill;

  // Boss bar
  static final Paint _bossBarBg = Paint();
  static final Paint _bossBarFill = Paint()..style = PaintingStyle.fill;
  static final Paint _bossBarStroke = Paint()..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  static final Paint _bossFrameStroke = Paint()..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  // Banner
  static final Paint _bannerBg = Paint();
  static final Paint _bannerStroke = Paint()..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  // Reused text layout objects.
  static final TextPainter _damagePainter = TextPainter(textDirection: TextDirection.ltr);
  static final TextPainter _labelPainter = TextPainter(textDirection: TextDirection.ltr);

  GamePainter({required this.engine, required this.themeIndex});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep Space Void & Nebula Background
    _drawNebulaBackground(canvas, size);

    // 2. Parallax Stars
    _drawStars(canvas, size);

    // Apply Screen Shake if active
    canvas.save();
    if (engine.stats.screenShakeIntensity > 0) {
      final intensity = engine.stats.screenShakeIntensity;
      final dx = (_random.nextDouble() - 0.5) * intensity * 2.0;
      final dy = (_random.nextDouble() - 0.5) * intensity * 2.0;
      canvas.translate(dx, dy);
    }

    // 3. Power-Ups (draw before bullets so they appear behind)
    _drawPowerUps(canvas);

    // 4. Bullets (Player & Enemy)
    _drawBullets(canvas);

    // 5. Enemies
    _drawEnemies(canvas);

    // 6. Player Ship
    _drawPlayer(canvas);

    // 7. Visual Particles & Shockwaves
    _drawParticles(canvas);

    // 8. Floating Damage Indicators
    _drawDamageNumbers(canvas);

    // Restore screen shake canvas transform
    canvas.restore();

    // 9. In-Game HUD Banners & Boss Bar (not affected by screen shake)
    _drawHUDOverlays(canvas, size);
  }

  void _drawNebulaBackground(Canvas canvas, Size size) {
    // Theme palettes: 0=Deep Space, 1=Void Crimson, 2=Neon Gold, 3=Ice Blue, 4=Solar Flare
    final isCrimson = themeIndex == 1;
    final isGold = themeIndex == 2;
    final isIce = themeIndex == 3;
    final isSolar = themeIndex == 4;

    final bgPaint = Paint()
      ..color = switch (themeIndex) {
        1 => const Color(0xFF080008),
        2 => const Color(0xFF0A0800),
        3 => const Color(0xFF050A10),
        4 => const Color(0xFF080400),
        _ => const Color(0xFF05050A),
      };
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    if (isCrimson) {
      // Void Crimson Nebula Glow 1 (Deep Red)
      final nebula1 = Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.5, -0.4),
          radius: 1.1,
          colors: [
            Color(0xFF4A0000),
            Color(0xFFFF1744),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebula1);

      // Void Crimson Nebula Glow 2 (Dark Crimson)
      final nebula2 = Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.6, 0.5),
          radius: 1.1,
          colors: [
            Color(0xFF2A001A),
            Color(0xFFD500F9),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebula2);
    } else if (isGold) {
      // Neon Gold Nebula Glow 1 (Dark Gold)
      final nebula1 = Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.5, -0.4),
          radius: 1.1,
          colors: [
            Color(0xFF3E2723),
            Color(0xFFFFD700),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebula1);

      // Neon Gold Nebula Glow 2 (Orange)
      final nebula2 = Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.6, 0.5),
          radius: 1.1,
          colors: [
            Color(0xFF5D4037),
            Color(0xFFFF9100),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebula2);
    } else if (isIce) {
      // Ice Blue Nebula Glow 1 (Deep Blue)
      final nebula1 = Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.5, -0.4),
          radius: 1.1,
          colors: [
            Color(0xFF003366),
            Color(0xFF00E5FF),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebula1);

      // Ice Blue Nebula Glow 2 (Cyan)
      final nebula2 = Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.6, 0.5),
          radius: 1.1,
          colors: [
            Color(0xFF006699),
            Color(0xFF00B8FF),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebula2);
    } else if (isSolar) {
      // Solar Flare Nebula Glow 1 (Deep Orange)
      final nebula1 = Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.5, -0.4),
          radius: 1.1,
          colors: [
            Color(0xFF4A1400),
            Color(0xFFFF5722),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebula1);

      // Solar Flare Nebula Glow 2 (Yellow/Orange)
      final nebula2 = Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.6, 0.5),
          radius: 1.1,
          colors: [
            Color(0xFF5D4037),
            Color(0xFFFFCA28),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebula2);
    } else {
      // Deep Space Nebula Glow 1 (Cyan/Blue)
      final nebula1 = Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.5, -0.4),
          radius: 1.1,
          colors: [
            Color(0xFF0D47A1),
            Color(0xFF00E5FF),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebula1);

      // Deep Space Nebula Glow 2 (Magenta/Purple)
      final nebula2 = Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.6, 0.5),
          radius: 1.1,
          colors: [
            Color(0xFF4A148C),
            Color(0xFFFF007F),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebula2);
    }

    // Cosmic dust - small distant stars behind parallax
    _dustPaint.color = Colors.white.withOpacity(0.06);
    for (int i = 0; i < 40; i++) {
      final dx = (i * 37.0) % size.width.toInt().toDouble();
      final dy = (i * 73.0) % size.height.toInt().toDouble();
      canvas.drawCircle(Offset(dx, dy), 0.8, _dustPaint);
    }
  }

  void _drawStars(Canvas canvas, Size size) {
    _starPaint.style = PaintingStyle.fill;
    for (final star in engine.stars) {
      final twinkle = 0.5 + sin(star.twinkleOffset) * 0.5;
      _starPaint.color = star.color.withOpacity((star.color.opacity * twinkle).clamp(0.0, 1.0));

      if (star.layer == 2) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              star.x - star.size / 2,
              star.y,
              star.size,
              star.size * 2.5,
            ),
            Radius.circular(star.size / 2),
          ),
          _starPaint,
        );
      } else {
        canvas.drawCircle(Offset(star.x, star.y), star.size, _starPaint);
      }
    }
  }

  void _drawPowerUps(Canvas canvas) {
    for (final p in engine.powerups) {
      canvas.save();
      canvas.translate(p.x, p.y);

      final pulse = 1.0 + sin(p.pulseTimer) * 0.25;

      // Outer rotating pulsing ring
      _powerGlow.color = p.color.withOpacity(0.5);
      canvas.drawCircle(Offset.zero, p.radius * pulse * 1.4, _powerGlow);

      // Secondary outer ring
      _powerRing.color = p.color.withOpacity(0.2);
      canvas.drawCircle(Offset.zero, p.radius * pulse * 1.8, _powerRing);

      // Inner diamond
      final diamondPath = Path()
        ..moveTo(0, -p.radius)
        ..lineTo(p.radius, 0)
        ..lineTo(0, p.radius)
        ..lineTo(-p.radius, 0)
        ..close();
      _powerFill.color = p.color.withOpacity(0.95);
      canvas.drawPath(diamondPath, _powerFill);

      // Core white sparkle
      _powerCore.color = Colors.white;
      canvas.drawCircle(Offset.zero, p.radius * 0.4, _powerCore);

      // Cross sparkle
      _powerCross.color = Colors.white.withOpacity(0.8);
      canvas.drawLine(Offset(0, -p.radius * 0.7), Offset(0, p.radius * 0.7), _powerCross);
      canvas.drawLine(Offset(-p.radius * 0.7, 0), Offset(p.radius * 0.7, 0), _powerCross);

      canvas.restore();
    }
  }

  void _drawBullets(Canvas canvas) {
    for (final b in engine.bullets) {
      canvas.save();
      canvas.translate(b.x, b.y);

      // Cheap stand-in for a bloom: a larger, faint circle behind the bolt.
      _bulletGlow.color = b.color.withOpacity(0.28);
      canvas.drawCircle(Offset.zero, b.radius * 2.4, _bulletGlow);

      if (b.type == BulletType.blaster || b.type == BulletType.enemyBlaster) {
        // Elongated laser bolt with a bright core
        _bulletFill.color = b.color;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-b.radius * 0.7, -b.radius * 2.4, b.radius * 1.4, b.radius * 4.8),
            Radius.circular(b.radius),
          ),
          _bulletFill,
        );
        _bulletFill.color = Colors.white;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-b.radius * 0.35, -b.radius * 1.6, b.radius * 0.7, b.radius * 3.2),
            Radius.circular(b.radius * 0.5),
          ),
          _bulletFill,
        );
      } else if (b.type == BulletType.missile) {
        canvas.rotate(b.angle + pi / 2);
        final missilePath = Path()
          ..moveTo(0, -b.radius * 2.0)
          ..lineTo(b.radius * 0.7, b.radius * 1.4)
          ..lineTo(-b.radius * 0.7, b.radius * 1.4)
          ..close();
        _bulletFill.color = b.color;
        canvas.drawPath(missilePath, _bulletFill);
        _bulletFill.color = Colors.white;
        canvas.drawCircle(Offset(0, b.radius * 1.4), 3.0, _bulletFill);
      } else {
        // Plasma and boss orbs
        _bulletFill.color = b.color;
        canvas.drawCircle(Offset.zero, b.radius, _bulletFill);
        _bulletFill.color = Colors.white;
        canvas.drawCircle(Offset.zero, b.radius * 0.6, _bulletFill);
      }

      canvas.restore();
    }
  }

  void _drawEnemies(Canvas canvas) {
    for (final e in engine.enemies) {
      switch (e.type) {
        case EnemyType.drone:
          ShipDesigns.drawDrone(canvas, e);
          break;
        case EnemyType.interceptor:
          ShipDesigns.drawInterceptor(canvas, e);
          break;
        case EnemyType.cruiser:
          ShipDesigns.drawCruiser(canvas, e);
          break;
        case EnemyType.boss:
          ShipDesigns.drawBoss(canvas, e);
          break;
      }

      // Draw enemy health bar if damaged (and not boss)
      if (e.health < e.maxHealth && e.type != EnemyType.boss) {
        final barWidth = e.radius * 2.0;
        final barHeight = 5.0;
        final barX = e.x - barWidth / 2;
        final barY = e.y - e.radius - 10.0;
        final hpPercent = (e.health / e.maxHealth).clamp(0.0, 1.0);

        _enemyBarBg.color = Colors.black.withOpacity(0.7);
        canvas.drawRect(
          Rect.fromLTWH(barX, barY, barWidth, barHeight),
          _enemyBarBg,
        );

        _enemyBarFill.color = e.primaryColor;
        canvas.drawRect(
          Rect.fromLTWH(barX, barY, barWidth * hpPercent, barHeight),
          _enemyBarFill,
        );

        _enemyBarBorder.color = Colors.white.withOpacity(0.5);
        canvas.drawRect(
          Rect.fromLTWH(barX, barY, barWidth, barHeight),
          _enemyBarBorder,
        );
      }
    }
  }

  void _drawPlayer(Canvas canvas) {
    final p = engine.player;
    // Invulnerability blink
    if (p.invulnerableTimer > 0 && (p.invulnerableTimer * 10).floor() % 2 == 0) {
      return;
    }

    ShipDesigns.drawPlayerShip(
      canvas,
      p.x,
      p.y,
      p.radius,
      p.shield,
      p.maxShield,
      p.shieldFlashTimer,
      p.thrusterPhase,
      shipIndex: p.shipIndex,
    );
  }

  void _drawParticles(Canvas canvas) {
    for (final part in engine.particleSystem.particles) {
      _particlePaint.color = part.color.withOpacity((part.color.opacity * part.life).clamp(0.0, 1.0));

      if (part.shape == ParticleShape.shockwaveRing) {
        _particlePaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1.5, 5.0 * part.life);
        canvas.drawCircle(Offset(part.x, part.y), part.radius, _particlePaint);
      } else if (part.shape == ParticleShape.spark) {
        _particlePaint.style = PaintingStyle.fill;
        final sparkLength = sqrt(part.vx * part.vx + part.vy * part.vy) * 0.05;
        final angle = atan2(part.vy, part.vx);
        canvas.save();
        canvas.translate(part.x, part.y);
        canvas.rotate(angle);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-sparkLength, -part.radius / 2, sparkLength * 2, part.radius),
            Radius.circular(part.radius / 2),
          ),
          _particlePaint,
        );
        canvas.restore();
      } else {
        _particlePaint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset(part.x, part.y), part.radius, _particlePaint);
      }
    }
  }

  void _drawDamageNumbers(Canvas canvas) {
    for (final d in engine.particleSystem.damageNumbers) {
      _damagePainter.text = TextSpan(
        text: d.text,
        style: TextStyle(
          color: d.color.withOpacity(d.life.clamp(0.0, 1.0)),
          fontSize: d.isCritical ? 18.0 : 14.0,
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
        ),
      );
      _damagePainter.layout();

      _damagePainter.paint(
        canvas,
        Offset(d.x - _damagePainter.width / 2, d.y - _damagePainter.height / 2),
      );
    }
  }

  void _drawHUDOverlays(canvas, Size size) {
    // 1. Boss Health Bar (if boss present)
    Enemy? boss;
    for (final e in engine.enemies) {
      if (e.type == EnemyType.boss) {
        boss = e;
        break;
      }
    }

    if (boss != null) {
      final barWidth = size.width - 40.0;
      final barHeight = 14.0;
      final barX = 20.0;
      final barY = 85.0;
      final hpPercent = (boss.health / boss.maxHealth).clamp(0.0, 1.0);

      // Boss label
      _labelPainter.text = TextSpan(
        text: boss.isEnraged ? 'VOID TITAN [ENRAGED]' : 'VOID TITAN - OMEGA CLASS',
        style: TextStyle(
          color: boss.isEnraged ? const Color(0xFFFF1744) : Colors.white,
          fontSize: 13.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      );
      _labelPainter.layout();
      _labelPainter.paint(canvas, Offset(size.width / 2 - _labelPainter.width / 2, barY - 22.0));

      // Bar Border & Background
      _bossBarBg.color = const Color(0xFF1A0006);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, barWidth, barHeight),
          const Radius.circular(8.0),
        ),
        _bossBarBg,
      );

      // Bar Fill with gradient
      _bossBarFill.shader = LinearGradient(
        colors: [
          boss.isEnraged ? const Color(0xFFFF1744) : const Color(0xFFFF5252),
          const Color(0xFFFF9100),
        ],
      ).createShader(Rect.fromLTWH(barX, barY, barWidth, barHeight));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, barWidth * hpPercent, barHeight),
          const Radius.circular(8.0),
        ),
        _bossBarFill,
      );

      // Neon Frame stroke (no blur fill-rate cost)
      _bossFrameStroke.color = boss.isEnraged ? const Color(0xFFFF1744) : const Color(0xFFFF5252);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX - 2, barY - 2, barWidth + 4, barHeight + 4),
          const Radius.circular(10.0),
        ),
        _bossFrameStroke,
      );

      _bossBarStroke.color = boss.isEnraged ? const Color(0xFFFF1744) : const Color(0xFFFF5252);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, barWidth, barHeight),
          const Radius.circular(8.0),
        ),
        _bossBarStroke,
      );
    }

    // 2. Wave Announcement Banner
    if (engine.waveManager.bannerTimer > 0) {
      final bannerAlpha = min(1.0, engine.waveManager.bannerTimer);
      _labelPainter.text = TextSpan(
        text: engine.waveManager.bannerMessage,
        style: TextStyle(
          color: engine.waveManager.bannerMessage.contains('WARNING')
              ? const Color(0xFFFF1744).withOpacity(bannerAlpha)
              : const Color(0xFF00E5FF).withOpacity(bannerAlpha),
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 3.0,
        ),
      );
      _labelPainter.layout();

      final boxY = size.height * 0.26;
      _bannerBg.color = Colors.black.withOpacity(0.55 * bannerAlpha);
      canvas.drawRect(
        Rect.fromLTWH(0, boxY - 16, size.width, _labelPainter.height + 32),
        _bannerBg,
      );
      _bannerStroke.color = (engine.waveManager.bannerMessage.contains('WARNING')
              ? const Color(0xFFFF1744)
              : const Color(0xFF00E5FF))
          .withOpacity(0.15 * bannerAlpha);
      canvas.drawRect(
        Rect.fromLTWH(0, boxY - 16, size.width, _labelPainter.height + 32),
        _bannerStroke,
      );

      _labelPainter.paint(
        canvas,
        Offset(size.width / 2 - _labelPainter.width / 2, boxY),
      );
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
