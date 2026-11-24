import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nova_strike/engine/game_engine.dart';
import 'package:nova_strike/models/bullet.dart';
import 'package:nova_strike/models/enemy.dart';
import 'package:nova_strike/models/game_state.dart';
import 'package:nova_strike/models/player_ship.dart';
import 'package:nova_strike/models/powerup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Nova Strike Core Engine Tests', () {
    late GameEngine engine;

    setUp(() {
      engine = GameEngine();
      engine.init(400.0, 800.0);
    });

    test('Engine initializes with correct defaults', () {
      expect(engine.phase, equals(GamePhase.playing));
      expect(engine.player.health, equals(100.0));
      expect(engine.player.shield, equals(100.0));
      expect(engine.stats.score, equals(0));
      expect(engine.stars.length, equals(90));
      expect(engine.waveManager.currentWave, equals(1));
    });

    test('Player ship takes shield damage before health damage', () {
      final player = engine.player;
      expect(player.shield, equals(100.0));
      expect(player.health, equals(100.0));

      // 40 damage should only hit shields
      player.takeDamage(40.0);
      expect(player.shield, equals(60.0));
      expect(player.health, equals(100.0));

      // 80 damage depletes remaining 60 shield and takes 20 health
      player.takeDamage(80.0);
      expect(player.shield, equals(0.0));
      expect(player.health, equals(80.0));
      expect(player.isAlive(), isTrue);
    });

    test('Player ship clamps within screen boundaries', () {
      final player = engine.player;

      // Attempt to move offscreen to negative coords
      player.targetX = -200.0;
      player.targetY = -500.0;
      player.update(1.0, 400.0, 800.0);

      expect(player.x, greaterThanOrEqualTo(player.radius));
      expect(player.y, greaterThanOrEqualTo(player.radius));

      // Attempt to move past right/bottom boundaries
      player.targetX = 1000.0;
      player.targetY = 2000.0;
      player.update(1.0, 400.0, 800.0);

      expect(player.x, lessThanOrEqualTo(400.0 - player.radius));
      expect(player.y, lessThanOrEqualTo(800.0 - player.radius));
    });

    test('Upgrades apply properly to player ship stats', () {
      engine.applyUpgrades(
        blasterLevel: 4,
        shieldLevel: 3,
        hasMissiles: true,
        magnetLevel: 2,
      );

      expect(engine.player.blasterLevel, equals(4));
      expect(engine.player.maxShield, equals(80.0 + 3 * 25.0)); // 155.0
      expect(engine.player.hasMissiles, isTrue);
      expect(engine.player.magnetRadius, equals(110.0 + 2 * 35.0)); // 180.0
    });

    test('Combo system increases multiplier and scores correctly', () {
      final stats = engine.stats;
      expect(stats.multiplier, equals(1.0));

      stats.addScore(100);
      expect(stats.combo, equals(1));
      expect(stats.multiplier, closeTo(1.1, 0.01));
      expect(stats.score, equals(110));

      stats.addScore(100);
      expect(stats.combo, equals(2));
      expect(stats.multiplier, closeTo(1.2, 0.01));
      expect(stats.score, equals(110 + 120));
    });

    test('Boss enrages and speeds up attack cooldown below 40% health', () {
      final boss = Enemy.createBoss(200.0, 100.0, 5);
      expect(boss.isEnraged, isFalse);
      final initialCooldown = boss.shootCooldown;

      // Bring boss health to 30%
      boss.health = boss.maxHealth * 0.3;
      boss.update(0.1, 400.0, 800.0);

      expect(boss.isEnraged, isTrue);
      expect(boss.shootCooldown, lessThan(initialCooldown));
    });

    test('Super Nova Blast consumes energy and destroys enemy projectiles', () {
      // Add enemy bullets
      engine.bullets.add(
        Bullet(
          x: 200,
          y: 300,
          vx: 0,
          vy: 200,
          damage: 15,
          type: BulletType.enemyBlaster,
          isPlayer: false,
          color: Colors.red,
          radius: 4.0,
        ),
      );

      // Add enemies
      final enemy = Enemy.createDrone(200, 200, 1.0);
      engine.enemies.add(enemy);

      // Nova blast cannot be triggered without 100% energy
      engine.player.energy = 50.0;
      final firedFail = engine.triggerNovaBlast();
      expect(firedFail, isFalse);

      // Charge to 100% and fire
      engine.player.energy = 100.0;
      final firedSuccess = engine.triggerNovaBlast();
      expect(firedSuccess, isTrue);
      expect(engine.player.energy, equals(0.0));

      // All enemy bullets must be eradicated by Nova Blast
      final enemyBullets = engine.bullets.where((b) => !b.isPlayer).toList();
      expect(enemyBullets, isEmpty);

      // Screen shake and slow-mo triggered
      expect(engine.stats.screenShakeIntensity, greaterThan(0));
      expect(engine.stats.slowMotionTimer, greaterThan(0));
    });

    test('Power-up collection boosts player and awards scrap', () {
      final initialScrap = engine.stats.scrapCollected;
      engine.powerups.add(
        PowerUp(
          x: engine.player.x,
          y: engine.player.y,
          vx: 0,
          vy: 0,
          type: PowerUpType.scrap,
          radius: 8.0,
          color: Colors.amber,
          value: 25,
        ),
      );

      engine.update(0.016);
      expect(engine.stats.scrapCollected, equals(initialScrap + 25));
    });
  });
}
