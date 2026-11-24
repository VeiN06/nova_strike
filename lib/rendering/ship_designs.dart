import 'dart:math';
import 'package:flutter/material.dart';
import '../models/enemy.dart';

class ShipDesigns {
  // Draw player spaceship with distinct design per ship index
  static void drawPlayerShip(
    Canvas canvas,
    double x,
    double y,
    double radius,
    double shield,
    double maxShield,
    double shieldFlash,
    double thrusterPhase, {
    int shipIndex = 0,
  }) {
    canvas.save();
    canvas.translate(x, y);

    // Ship-specific color themes
    Color hullColor;
    Color trimColor;
    Color flameCore;
    Color flameTip;
    Color canopyOuter;

    switch (shipIndex) {
      case 1: // Phantom - green neon, sleek dagger
        hullColor = const Color(0xFF0A2E1A);
        trimColor = const Color(0xFF76FF03);
        flameCore = const Color(0xFF76FF03);
        flameTip = const Color(0xFFFF007F).withOpacity(0.1);
        canopyOuter = const Color(0xFF0052CC);
        break;
      case 2: // Aegis - magenta/pink, heavy blocky
        hullColor = const Color(0xFF2E0A1A);
        trimColor = const Color(0xFFFF007F);
        flameCore = const Color(0xFFFF007F);
        flameTip = const Color(0xFFFF007F).withOpacity(0.1);
        canopyOuter = const Color(0xFF0052CC);
        break;
      case 3: // Phoenix - gold/yellow, flagship wings
        hullColor = const Color(0xFF2E2A0A);
        trimColor = const Color(0xFFFFD700);
        flameCore = const Color(0xFFFFD700);
        flameTip = const Color(0xFFFF007F).withOpacity(0.1);
        canopyOuter = const Color(0xFF0052CC);
        break;
      case 0:
      default: // Viper - cyan, balanced interceptor
        hullColor = const Color(0xFF1A1A2E);
        trimColor = const Color(0xFF00E5FF);
        flameCore = const Color(0xFF00E5FF);
        flameTip = const Color(0xFFFF007F).withOpacity(0.1);
        canopyOuter = const Color(0xFF0052CC);
        break;
    }

    // 1. Thruster Flame Exhaust
    final flameHeight = 14.0 + sin(thrusterPhase) * 4.0;
    final flamePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          flameCore,
          flameTip,
        ],
      ).createShader(Rect.fromLTWH(-10, radius - 4, 20, flameHeight))
      ..style = PaintingStyle.fill;

    // Left & Right engine nozzles
    final leftNozzle = Path()
      ..moveTo(-9, radius - 4)
      ..lineTo(-6, radius - 4 + flameHeight)
      ..lineTo(-3, radius - 4)
      ..close();
    final rightNozzle = Path()
      ..moveTo(3, radius - 4)
      ..lineTo(6, radius - 4 + flameHeight)
      ..lineTo(9, radius - 4)
      ..close();
    canvas.drawPath(leftNozzle, flamePaint);
    canvas.drawPath(rightNozzle, flamePaint);

    // 2. Main Hull Body - distinct shape per ship
    final hullPath = _buildHullPath(shipIndex, radius);

    // Dark sleek hull armor with ship theme
    final hullPaint = Paint()
      ..color = hullColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(hullPath, hullPaint);

    // Neon Cyber Accents & Wing Trim
    final trimPaint = Paint()
      ..color = trimColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(hullPath, trimPaint);

    // Cockpit Glowing Canopy
    final cockpitPath = Path()
      ..moveTo(0, -radius * 0.75)
      ..lineTo(radius * 0.22, -radius * 0.05)
      ..lineTo(0, radius * 0.25)
      ..lineTo(-radius * 0.22, -radius * 0.05)
      ..close();

    final canopyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          trimColor,
          canopyOuter,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius * 0.4))
      ..style = PaintingStyle.fill;
    canvas.drawPath(cockpitPath, canopyPaint);

    // 3. Ship-specific accent details
    _drawShipAccents(canvas, shipIndex, radius, trimColor);

    // 4. Shield Bubble Aura
    if (shield > 0 || shieldFlash > 0) {
      final shieldAlpha = (shield / maxShield * 0.25 + (shieldFlash > 0 ? 0.35 : 0.0)).clamp(0.0, 0.7);
      final shieldPaint = Paint()
        ..color = trimColor.withOpacity(shieldAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8 + (shieldFlash > 0 ? 2.0 : 0.0);
      canvas.drawCircle(Offset.zero, radius * 1.25, shieldPaint);
    }

    canvas.restore();
  }

  // Build different hull shapes per ship index
  static Path _buildHullPath(int shipIndex, double radius) {
    switch (shipIndex) {
      case 1: // Phantom - sleek dagger, narrow and pointed
        return Path()
          ..moveTo(0, -radius) // Sharp nose
          ..lineTo(radius * 0.35, -radius * 0.2)
          ..lineTo(radius * 0.85, radius * 0.45) // Thin wing
          ..lineTo(radius * 0.6, radius * 0.65)
          ..lineTo(radius * 0.4, radius * 0.85)
          ..lineTo(-radius * 0.4, radius * 0.85)
          ..lineTo(-radius * 0.6, radius * 0.65)
          ..lineTo(-radius * 0.85, radius * 0.45)
          ..lineTo(-radius * 0.35, -radius * 0.2)
          ..close();

      case 2: // Aegis - heavy blocky cruiser, wider
        return Path()
          ..moveTo(0, -radius * 0.85) // Blunter nose
          ..lineTo(radius * 0.6, -radius * 0.3)
          ..lineTo(radius * 1.05, radius * 0.25) // Heavy wing
          ..lineTo(radius * 0.8, radius * 0.85)
          ..lineTo(radius * 0.5, radius * 0.95)
          ..lineTo(-radius * 0.5, radius * 0.95)
          ..lineTo(-radius * 0.8, radius * 0.85)
          ..lineTo(-radius * 1.05, radius * 0.25)
          ..lineTo(-radius * 0.6, -radius * 0.3)
          ..close();

      case 3: // Phoenix - flagship with swept wings
        return Path()
          ..moveTo(0, -radius * 0.9)
          ..lineTo(radius * 0.5, -radius * 0.1)
          ..lineTo(radius * 1.15, radius * 0.35) // Long swept wing
          ..lineTo(radius * 0.85, radius * 0.75)
          ..lineTo(radius * 0.55, radius * 1.0)
          ..lineTo(-radius * 0.55, radius * 1.0)
          ..lineTo(-radius * 0.85, radius * 0.75)
          ..lineTo(-radius * 1.15, radius * 0.35)
          ..lineTo(-radius * 0.5, -radius * 0.1)
          ..close();

      case 0:
      default: // Viper - balanced interceptor
        return Path()
          ..moveTo(0, -radius)
          ..lineTo(radius * 0.45, -radius * 0.15)
          ..lineTo(radius * 0.95, radius * 0.55)
          ..lineTo(radius * 0.65, radius * 0.65)
          ..lineTo(radius * 0.45, radius * 0.45)
          ..lineTo(radius * 0.35, radius * 0.85)
          ..lineTo(-radius * 0.35, radius * 0.85)
          ..lineTo(-radius * 0.45, radius * 0.45)
          ..lineTo(-radius * 0.65, radius * 0.65)
          ..lineTo(-radius * 0.95, radius * 0.55)
          ..lineTo(-radius * 0.45, -radius * 0.15)
          ..close();
    }
  }

  // Draw ship-specific accent details
  static void _drawShipAccents(Canvas canvas, int shipIndex, double radius, Color trimColor) {
    final accentPaint = Paint()
      ..color = trimColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    switch (shipIndex) {
      case 1: // Phantom - edge streaks
        canvas.drawLine(Offset(-radius * 0.3, -radius * 0.4), Offset(-radius * 0.6, -radius * 0.7), accentPaint);
        canvas.drawLine(Offset(radius * 0.3, -radius * 0.4), Offset(radius * 0.6, -radius * 0.7), accentPaint);
        break;
      case 2: // Aegis - reinforced plates
        canvas.drawRect(Rect.fromLTWH(-radius * 0.3, -radius * 0.3, radius * 0.6, radius * 0.2), accentPaint);
        break;
      case 3: // Phoenix - wing energy lines
        canvas.drawLine(Offset(-radius * 0.6, radius * 0.2), Offset(-radius * 1.0, radius * 0.4), accentPaint);
        canvas.drawLine(Offset(radius * 0.6, radius * 0.2), Offset(radius * 1.0, radius * 0.4), accentPaint);
        break;
      case 0:
      default: // Viper - simple trim lines
        canvas.drawLine(Offset(-radius * 0.25, -radius * 0.3), Offset(-radius * 0.45, -radius * 0.5), accentPaint);
        canvas.drawLine(Offset(radius * 0.25, -radius * 0.3), Offset(radius * 0.45, -radius * 0.5), accentPaint);
        break;
    }
  }

  // Draw Drone Enemy
  static void drawDrone(Canvas canvas, Enemy enemy) {
    canvas.save();
    canvas.translate(enemy.x, enemy.y);
    final r = enemy.radius;

    final path = Path()
      ..moveTo(0, r)
      ..lineTo(r * 0.85, -r * 0.7)
      ..lineTo(0, -r * 0.3)
      ..lineTo(-r * 0.85, -r * 0.7)
      ..close();

    final paint = Paint()
      ..color = const Color(0xFF2A0815)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    final border = Paint()
      ..color = enemy.primaryColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, border);

    final eyePaint = Paint()
      ..color = const Color(0xFFFF5252)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, r * 0.1), 3.0, eyePaint);

    canvas.restore();
  }

  // Draw Interceptor Enemy
  static void drawInterceptor(Canvas canvas, Enemy enemy) {
    canvas.save();
    canvas.translate(enemy.x, enemy.y);
    final r = enemy.radius;

    final path = Path()
      ..moveTo(0, r * 0.9)
      ..lineTo(r * 0.5, r * 0.3)
      ..lineTo(r, -r * 0.5)
      ..lineTo(r * 0.4, -r * 0.8)
      ..lineTo(0, -r * 0.4)
      ..lineTo(-r * 0.4, -r * 0.8)
      ..lineTo(-r, -r * 0.5)
      ..lineTo(-r * 0.5, r * 0.3)
      ..close();

    final paint = Paint()
      ..color = const Color(0xFF261505)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    final border = Paint()
      ..color = enemy.primaryColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, border);

    final emitter = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-r * 0.6, -r * 0.1), 3.0, emitter);
    canvas.drawCircle(Offset(r * 0.6, -r * 0.1), 3.0, emitter);

    canvas.restore();
  }

  // Draw Heavy Cruiser Enemy
  static void drawCruiser(Canvas canvas, Enemy enemy) {
    canvas.save();
    canvas.translate(enemy.x, enemy.y);
    final r = enemy.radius;

    final path = Path()
      ..moveTo(0, r)
      ..lineTo(r * 0.7, r * 0.6)
      ..lineTo(r, 0)
      ..lineTo(r * 0.8, -r * 0.8)
      ..lineTo(0, -r * 0.6)
      ..lineTo(-r * 0.8, -r * 0.8)
      ..lineTo(-r, 0)
      ..lineTo(-r * 0.7, r * 0.6)
      ..close();

    final paint = Paint()
      ..color = const Color(0xFF1E072B)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    final border = Paint()
      ..color = enemy.primaryColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, border);

    final core = Paint()
      ..color = const Color(0xFFE040FB)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 7.0, core);

    canvas.restore();
  }

  // Draw Void Titan Boss
  static void drawBoss(Canvas canvas, Enemy enemy) {
    canvas.save();
    canvas.translate(enemy.x, enemy.y);
    final r = enemy.radius;

    if (enemy.isEnraged) {
      final ragePaint = Paint()
        ..color = const Color(0xFFFF1744).withOpacity(0.25 + sin(enemy.phaseTimer * 8.0) * 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0;
      canvas.drawCircle(Offset.zero, r * 1.15, ragePaint);
    }

    final path = Path()
      ..moveTo(0, r)
      ..lineTo(r * 0.45, r * 0.75)
      ..lineTo(r * 0.95, r * 0.35)
      ..lineTo(r, -r * 0.4)
      ..lineTo(r * 0.6, -r * 0.85)
      ..lineTo(0, -r * 0.5)
      ..lineTo(-r * 0.6, -r * 0.85)
      ..lineTo(-r, -r * 0.4)
      ..lineTo(-r * 0.95, r * 0.35)
      ..lineTo(-r * 0.45, r * 0.75)
      ..close();

    final hull = Paint()
      ..color = const Color(0xFF150308)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, hull);

    final border = Paint()
      ..color = enemy.isEnraged ? const Color(0xFFFF1744) : const Color(0xFFFF5252)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, border);

    final wingBorder = Paint()
      ..color = const Color(0xFFFF9100)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-r * 0.8, -r * 0.2), Offset(-r * 0.3, r * 0.4), wingBorder);
    canvas.drawLine(Offset(r * 0.8, -r * 0.2), Offset(r * 0.3, r * 0.4), wingBorder);

    final coreRadius = 14.0 + sin(enemy.phaseTimer * 6.0) * 3.0;
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          enemy.isEnraged ? const Color(0xFFFF1744) : const Color(0xFFFF5252),
          Colors.black,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: coreRadius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, coreRadius, corePaint);

    canvas.restore();
  }
}
