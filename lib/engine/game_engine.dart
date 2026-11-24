import 'dart:math';
import 'package:flutter/material.dart';
import '../models/bullet.dart';
import '../models/enemy.dart';
import '../models/game_state.dart';
import '../models/particle.dart';
import '../models/player_ship.dart';
import '../models/powerup.dart';
import '../models/star.dart';
import 'particle_system.dart';
import 'sound_effects.dart';
import 'wave_manager.dart';

class GameEngine {
  late PlayerShip player;
  final List<Bullet> bullets = [];
  final List<Enemy> enemies = [];
  final List<PowerUp> powerups = [];
  final List<Star> stars = [];
  final ParticleSystem particleSystem = ParticleSystem();
  final WaveManager waveManager = WaveManager();
  final GameStats stats = GameStats();

  GamePhase phase = GamePhase.playing;
  double screenWidth = 400.0;
  double screenHeight = 800.0;
  final Random _random = Random();

  GameEngine() {
    init(screenWidth, screenHeight);
  }

  void init(double width, double height) {
    screenWidth = width;
    screenHeight = height;

    player = PlayerShip(
      x: width / 2,
      y: height - 120,
    );

    // Generate multi-layer parallax starfield
    stars.clear();
    for (int i = 0; i < 90; i++) {
      stars.add(Star.random(width, height, _random));
    }

    bullets.clear();
    enemies.clear();
    powerups.clear();
    particleSystem.clear();
    stats.reset();
    waveManager.startWave(1);
    phase = GamePhase.playing;
  }

  void applyUpgrades({
    required int blasterLevel,
    required int shieldLevel,
    required bool hasMissiles,
    required int magnetLevel,
    int shipIndex = 0,
  }) {
    player.blasterLevel = blasterLevel;
    player.shipIndex = shipIndex;
    player.maxShield = 80.0 + (shieldLevel * 25.0);
    player.shield = player.maxShield;
    player.hasMissiles = hasMissiles;
    player.magnetRadius = 110.0 + (magnetLevel * 35.0);

    // Ship-specific stat modifiers
    switch (shipIndex) {
      case 0: // Viper - balanced
        player.maxHealth = 100.0;
        player.health = player.maxHealth;
        player.maxEnergy = 100.0;
        player.energy = player.maxEnergy;
        player.fireInterval = 0.16;
        break;
      case 1: // Phantom - high crit, light armor, fast fire
        player.maxHealth = 70.0;
        player.health = player.maxHealth;
        player.maxEnergy = 100.0;
        player.energy = player.maxEnergy;
        player.fireInterval = 0.11;
        break;
      case 2: // Aegis - heavy armor, slow fire
        player.maxHealth = 150.0;
        player.health = player.maxHealth;
        player.maxEnergy = 100.0;
        player.energy = player.maxEnergy;
        player.fireInterval = 0.24;
        break;
      case 3: // Phoenix - flagship, rapid energy charge, quad lasers base
        player.maxHealth = 110.0;
        player.health = player.maxHealth;
        player.maxEnergy = 100.0;
        player.energy = player.maxEnergy;
        player.blasterLevel = max(4, blasterLevel);
        player.fireInterval = 0.14;
        break;
    }
  }

  /// Apply per-ship specific upgrades (each ship has its own upgrade tree)
  void applyShipUpgrades({
    required int shipIndex,
    required int blasterLevel,
    required int shieldLevel,
    required bool hasMissiles,
    required int magnetLevel,
  }) {
    player.shipIndex = shipIndex;
    player.blasterLevel = blasterLevel;
    player.maxShield = 80.0 + (shieldLevel * 25.0);
    player.shield = player.maxShield;
    player.hasMissiles = hasMissiles;
    player.magnetRadius = 110.0 + (magnetLevel * 35.0);

    switch (shipIndex) {
      case 0: // Viper - balanced
        player.maxHealth = 100.0 + (shieldLevel * 5.0);
        player.health = player.maxHealth;
        player.maxEnergy = 100.0;
        player.energy = player.maxEnergy;
        player.fireInterval = 0.16 - (blasterLevel * 0.015);
        break;
      case 1: // Phantom - high crit, light armor, fast fire
        player.maxHealth = 70.0 + (shieldLevel * 3.0);
        player.health = player.maxHealth;
        player.maxEnergy = 100.0;
        player.energy = player.maxEnergy;
        player.fireInterval = 0.11 - (blasterLevel * 0.015);
        break;
      case 2: // Aegis - heavy armor, slow fire
        player.maxHealth = 150.0 + (shieldLevel * 8.0);
        player.health = player.maxHealth;
        player.maxEnergy = 100.0;
        player.energy = player.maxEnergy;
        player.fireInterval = 0.24 - (blasterLevel * 0.015);
        break;
      case 3: // Phoenix - flagship, rapid energy charge, quad lasers base
        player.maxHealth = 110.0 + (shieldLevel * 6.0);
        player.health = player.maxHealth;
        player.maxEnergy = 100.0;
        player.energy = player.maxEnergy;
        player.blasterLevel = max(4, blasterLevel);
        player.fireInterval = 0.14 - (blasterLevel * 0.015);
        break;
    }

    // Clamp fire interval to reasonable minimum
    player.fireInterval = player.fireInterval.clamp(0.06, 0.5);
  }

  void setPlayerTarget(double tx, double ty) {
    player.targetX = tx;
    player.targetY = ty;
  }

  void update(double rawDt) {
    if (phase != GamePhase.playing) return;

    // Apply slow motion if active
    final dt = rawDt * stats.slowMotionFactor;

    stats.update(rawDt);

    // Update starfield (faster if boosting)
    final starSpeedMult = waveManager.waveTransitioning ? 2.5 : 1.0;
    for (final star in stars) {
      star.update(dt, screenWidth, screenHeight, starSpeedMult);
    }

    // Update Player
    player.update(dt, screenWidth, screenHeight);

    // Player thruster exhaust VFX
    particleSystem.spawnThrusterTrail(
      player.x - 7.0,
      player.y + player.radius - 2.0,
      waveManager.waveTransitioning,
    );
    particleSystem.spawnThrusterTrail(
      player.x + 7.0,
      player.y + player.radius - 2.0,
      waveManager.waveTransitioning,
    );

    // Auto-fire player weapons
    _updatePlayerShooting();

    // Update Wave Manager & Spawning
    waveManager.update(dt);
    if (waveManager.canSpawnNextEnemy()) {
      final newEnemies = waveManager.spawnEnemies(screenWidth, screenHeight);
      enemies.addAll(newEnemies);
    }

    // Update Enemies & Enemy Shooting
    _updateEnemies(dt);

    // Update Bullets & Homing
    _updateBullets(dt);

    // Update PowerUps
    _updatePowerUps(dt);

    // Update Particles & Floating Text
    particleSystem.update(dt);

    // Collision Detection
    _checkCollisions();

    // Check wave completion
    if (waveManager.enemiesSpawnedInWave >= waveManager.totalEnemiesForWave &&
        enemies.isEmpty &&
        !waveManager.waveTransitioning) {
      waveManager.triggerWaveClear();
      stats.triggerSlowMotion(0.8, 0.4);
    }

    if (waveManager.waveTransitioning && waveManager.transitionTimer > 2.5) {
      waveManager.nextWave();
      stats.currentWave = waveManager.currentWave;
    }

    // Check Game Over
    if (!player.isAlive()) {
      phase = GamePhase.gameOver;
      particleSystem.spawnExplosion(
        player.x,
        player.y,
        const Color(0xFF00E5FF),
        count: 50,
        radius: 6.0,
      );
      stats.triggerShake(18.0);
      SoundEffects.playPlayerDamage();
    }
  }

  void _updatePlayerShooting() {
    if (player.fireTimer <= 0) {
      player.fireTimer = player.fireInterval;
      SoundEffects.playPlayerShoot();

      final isTriBoost = player.triShotTimer > 0;
      final effectiveLevel = isTriBoost ? max(3, player.blasterLevel) : player.blasterLevel;

      switch (effectiveLevel) {
        case 1:
          // Single blaster
          bullets.add(
            Bullet(
              x: player.x,
              y: player.y - player.radius,
              vx: 0,
              vy: -680,
              damage: 22,
              type: BulletType.blaster,
              isPlayer: true,
              color: const Color(0xFF00E5FF), // Cyan
              radius: 4.5,
            ),
          );
          break;

        case 2:
          // Dual blaster
          bullets.add(
            Bullet(
              x: player.x - 11,
              y: player.y - player.radius,
              vx: 0,
              vy: -700,
              damage: 20,
              type: BulletType.blaster,
              isPlayer: true,
              color: const Color(0xFF00E5FF),
              radius: 4.5,
            ),
          );
          bullets.add(
            Bullet(
              x: player.x + 11,
              y: player.y - player.radius,
              vx: 0,
              vy: -700,
              damage: 20,
              type: BulletType.blaster,
              isPlayer: true,
              color: const Color(0xFF00E5FF),
              radius: 4.5,
            ),
          );
          break;

        case 3:
          // Tri-spread
          bullets.add(
            Bullet(
              x: player.x,
              y: player.y - player.radius,
              vx: 0,
              vy: -720,
              damage: 24,
              type: BulletType.blaster,
              isPlayer: true,
              color: const Color(0xFFFF007F), // Neon pink
              radius: 5.0,
            ),
          );
          bullets.add(
            Bullet(
              x: player.x - 12,
              y: player.y - player.radius + 4,
              vx: -120,
              vy: -720,
              damage: 18,
              type: BulletType.blaster,
              isPlayer: true,
              color: const Color(0xFFFF007F),
              radius: 4.5,
            ),
          );
          bullets.add(
            Bullet(
              x: player.x + 12,
              y: player.y - player.radius + 4,
              vx: 120,
              vy: -720,
              damage: 18,
              type: BulletType.blaster,
              isPlayer: true,
              color: const Color(0xFFFF007F),
              radius: 4.5,
            ),
          );
          break;

        case 4:
          // Quad laser
          for (int i = -1; i <= 2; i++) {
            if (i == 0) continue;
            final offset = i > 0 ? (i * 9.0) : ((i + 1) * 9.0 - 9.0);
            bullets.add(
              Bullet(
                x: player.x + offset,
                y: player.y - player.radius,
                vx: offset * 3.5,
                vy: -720,
                damage: 22,
                type: BulletType.blaster,
                isPlayer: true,
                color: const Color(0xFF76FF03), // Electric lime
                radius: 4.5,
              ),
            );
          }
          break;

        case 5:
        default:
          // Hyper Plasma Overdrive with penetrating center bolt
          bullets.add(
            Bullet(
              x: player.x,
              y: player.y - player.radius - 4,
              vx: 0,
              vy: -800,
              damage: 48,
              type: BulletType.plasma,
              isPlayer: true,
              color: const Color(0xFFFFEA00), // Electric yellow
              radius: 7.5,
              penetration: 3,
            ),
          );
          bullets.add(
            Bullet(
              x: player.x - 14,
              y: player.y - player.radius + 4,
              vx: -130,
              vy: -720,
              damage: 22,
              type: BulletType.blaster,
              isPlayer: true,
              color: const Color(0xFF00E5FF),
              radius: 4.5,
            ),
          );
          bullets.add(
            Bullet(
              x: player.x + 14,
              y: player.y - player.radius + 4,
              vx: 130,
              vy: -720,
              damage: 22,
              type: BulletType.blaster,
              isPlayer: true,
              color: const Color(0xFF00E5FF),
              radius: 4.5,
            ),
          );
          break;
      }
    }

    // Player Homing Micro-Missiles
    if (player.hasMissiles && player.missileTimer <= 0 && enemies.isNotEmpty) {
      player.missileTimer = 0.85; // Fires every 0.85s
      bullets.add(
        Bullet(
          x: player.x - 18,
          y: player.y,
          vx: -120,
          vy: -200,
          damage: 55,
          type: BulletType.missile,
          isPlayer: true,
          color: const Color(0xFFFF9100),
          radius: 5.0,
          angle: -pi / 2,
        ),
      );
      bullets.add(
        Bullet(
          x: player.x + 18,
          y: player.y,
          vx: 120,
          vy: -200,
          damage: 55,
          type: BulletType.missile,
          isPlayer: true,
          color: const Color(0xFFFF9100),
          radius: 5.0,
          angle: -pi / 2,
        ),
      );
    }
  }

  void _updateEnemies(double dt) {
    for (int i = enemies.length - 1; i >= 0; i--) {
      final e = enemies[i];
      final alive = e.update(dt, screenWidth, screenHeight);

      if (!alive) {
        enemies.removeAt(i);
        continue;
      }

      // Enemy firing logic
      if (e.shootTimer >= e.shootCooldown) {
        e.shootTimer = 0.0;

        switch (e.type) {
          case EnemyType.drone:
            bullets.add(
              Bullet(
                x: e.x,
                y: e.y + e.radius,
                vx: 0,
                vy: 230,
                damage: 14,
                type: BulletType.enemyBlaster,
                isPlayer: false,
                color: const Color(0xFFFF5252),
                radius: 4.0,
              ),
            );
            break;

          case EnemyType.interceptor:
            // Twin aimed shots
            bullets.add(
              Bullet(
                x: e.x - 10,
                y: e.y + e.radius,
                vx: -30,
                vy: 260,
                damage: 18,
                type: BulletType.enemyBlaster,
                isPlayer: false,
                color: const Color(0xFFFF9100),
                radius: 4.5,
              ),
            );
            bullets.add(
              Bullet(
                x: e.x + 10,
                y: e.y + e.radius,
                vx: 30,
                vy: 260,
                damage: 18,
                type: BulletType.enemyBlaster,
                isPlayer: false,
                color: const Color(0xFFFF9100),
                radius: 4.5,
              ),
            );
            break;

          case EnemyType.cruiser:
            // 3-way spread fire
            for (int angleDeg in [-25, 0, 25]) {
              final rad = (angleDeg + 90) * pi / 180;
              bullets.add(
                Bullet(
                  x: e.x,
                  y: e.y + e.radius,
                  vx: cos(rad) * 230,
                  vy: sin(rad) * 230,
                  damage: 22,
                  type: BulletType.enemyOrb,
                  isPlayer: false,
                  color: const Color(0xFFD500F9),
                  radius: 5.5,
                ),
              );
            }
            break;

          case EnemyType.boss:
            // Multi-pattern boss barrage
            SoundEffects.playBossHit();
            if (e.isEnraged) {
              // 5-way furious volley
              for (int angleDeg in [-40, -20, 0, 20, 40]) {
                final rad = (angleDeg + 90) * pi / 180;
                bullets.add(
                  Bullet(
                    x: e.x,
                    y: e.y + e.radius,
                    vx: cos(rad) * 280,
                    vy: sin(rad) * 280,
                    damage: 28,
                    type: BulletType.enemyOrb,
                    isPlayer: false,
                    color: const Color(0xFFFF1744),
                    radius: 7.0,
                  ),
                );
              }
            } else {
              // Heavy twin orbs + aimed core laser
              bullets.add(
                Bullet(
                  x: e.x - 30,
                  y: e.y + e.radius,
                  vx: -40,
                  vy: 240,
                  damage: 25,
                  type: BulletType.enemyOrb,
                  isPlayer: false,
                  color: const Color(0xFFFF1744),
                  radius: 6.0,
                ),
              );
              bullets.add(
                Bullet(
                  x: e.x + 30,
                  y: e.y + e.radius,
                  vx: 40,
                  vy: 240,
                  damage: 25,
                  type: BulletType.enemyOrb,
                  isPlayer: false,
                  color: const Color(0xFFFF1744),
                  radius: 6.0,
                ),
              );
            }
            break;
        }
      }
    }
  }

  void _updateBullets(double dt) {
    // Find closest enemy for homing missiles
    Enemy? targetEnemy;
    double closestDist = 999999.0;
    if (enemies.isNotEmpty) {
      for (final e in enemies) {
        final d = (e.x - player.x) * (e.x - player.x) + (e.y - player.y) * (e.y - player.y);
        if (d < closestDist) {
          closestDist = d;
          targetEnemy = e;
        }
      }
    }

    for (int i = bullets.length - 1; i >= 0; i--) {
      final b = bullets[i];
      if (b.type == BulletType.missile && targetEnemy != null) {
        b.steerTowards(targetEnemy.x, targetEnemy.y, 4.5, dt);
      }

      final inBounds = b.update(dt, screenWidth, screenHeight);
      if (!inBounds) {
        bullets.removeAt(i);
      }
    }

    // Safety cap. A bullet storm should never be allowed to grow without bound,
    // since every bullet is both simulated and drawn with a glow each frame.
    const maxBullets = 140;
    if (bullets.length > maxBullets) {
      bullets.removeRange(0, bullets.length - maxBullets);
    }
  }

  void _updatePowerUps(double dt) {
    for (int i = powerups.length - 1; i >= 0; i--) {
      final p = powerups[i];
      final inScreen = p.update(dt, screenHeight, player.x, player.y, player.magnetRadius);
      if (!inScreen) {
        powerups.removeAt(i);
      }
    }
  }

  void _checkCollisions() {
    // 1. Player Bullets vs Enemies
    for (int bi = bullets.length - 1; bi >= 0; bi--) {
      final b = bullets[bi];
      if (!b.isPlayer) continue;

      for (int ei = enemies.length - 1; ei >= 0; ei--) {
        final e = enemies[ei];
        final dx = b.x - e.x;
        final dy = b.y - e.y;
        final dist = sqrt(dx * dx + dy * dy);

        if (dist < b.radius + e.radius) {
          // Hit enemy
          final isCrit = _random.nextDouble() < 0.22;
          final totalDmg = isCrit ? b.damage * 1.8 : b.damage;
          e.health -= totalDmg;

          // VFX & Sound. A full explosion plus a floating number on every single
          // bullet impact is what buries the frame rate once the screen fills
          // with fire. Sparks only on a critical hit, and the number only for
          // heavier hits, keeps the feedback without the cost.
          SoundEffects.playEnemyHit();
          if (isCrit || b.damage >= 20) {
            particleSystem.addDamageText(
              e.x,
              e.y,
              totalDmg.round().toString(),
              isCrit ? const Color(0xFFFFEA00) : Colors.white,
              isCritical: isCrit,
            );
          }

          if (isCrit) {
            particleSystem.spawnExplosion(
              b.x,
              b.y,
              b.color,
              count: 5,
              radius: 2.0,
            );
          }

          // Energy gain for player overdrive
          player.energy = min(player.maxEnergy, player.energy + 2.5);

          b.penetration--;
          if (b.penetration <= 0) {
            bullets.removeAt(bi);
          }

          // Check if enemy killed
          if (e.health <= 0) {
            enemies.removeAt(ei);
            stats.addScore(e.scoreValue);
            stats.scrapCollected += e.scrapReward;
            SoundEffects.playExplosion();

            if (e.type == EnemyType.boss) {
              stats.bossesDefeated++;
              stats.triggerShake(20.0);
              stats.triggerSlowMotion(1.2, 0.25);
              particleSystem.spawnExplosion(
                e.x,
                e.y,
                const Color(0xFFFF1744),
                count: 65,
                radius: 6.0,
              );
            } else {
              stats.triggerShake(e.type == EnemyType.cruiser ? 8.0 : 4.0);
              particleSystem.spawnExplosion(
                e.x,
                e.y,
                e.primaryColor,
                count: e.type == EnemyType.cruiser ? 38 : 22,
                radius: 4.0,
              );
            }

            // Power-up / Scrap drop chance
            if (_random.nextDouble() < 0.45 || e.type == EnemyType.boss) {
              final dropCount = e.type == EnemyType.boss ? 4 : 1;
              for (int d = 0; d < dropCount; d++) {
                powerups.add(
                  PowerUp.createRandom(
                    e.x + (d - 1.5) * 20.0,
                    e.y,
                    _random,
                  ),
                );
              }
            }
          }
          break; // Exit enemy loop for this bullet if destroyed
        }
      }
    }

    // 2. Enemy Bullets vs Player
    for (int bi = bullets.length - 1; bi >= 0; bi--) {
      final b = bullets[bi];
      if (b.isPlayer) continue;

      final dx = b.x - player.x;
      final dy = b.y - player.y;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < b.radius + player.radius) {
        bullets.removeAt(bi);
        player.takeDamage(b.damage);
        stats.triggerShake(7.0);

        if (player.shield > 0) {
          particleSystem.spawnShieldImpact(b.x, b.y);
          SoundEffects.playPlayerShoot();
        } else {
          particleSystem.spawnExplosion(b.x, b.y, const Color(0xFFFF5252), count: 12);
          SoundEffects.playPlayerDamage();
        }
      }
    }

    // 3. Enemies ramming into Player
    for (int ei = enemies.length - 1; ei >= 0; ei--) {
      final e = enemies[ei];
      final dx = e.x - player.x;
      final dy = e.y - player.y;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < e.radius + player.radius) {
        player.takeDamage(35.0);
        stats.triggerShake(12.0);
        SoundEffects.playPlayerDamage();

        if (e.type != EnemyType.boss) {
          enemies.removeAt(ei);
          particleSystem.spawnExplosion(e.x, e.y, e.primaryColor, count: 24);
        }
      }
    }

    // 4. Player vs PowerUps
    for (int pi = powerups.length - 1; pi >= 0; pi--) {
      final p = powerups[pi];
      final dx = p.x - player.x;
      final dy = p.y - player.y;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < p.radius + player.radius) {
        powerups.removeAt(pi);
        SoundEffects.playPowerUp();

        switch (p.type) {
          case PowerUpType.scrap:
            stats.scrapCollected += p.value;
            particleSystem.addDamageText(
              player.x,
              player.y - 20,
              '+${p.value} SCRAP',
              const Color(0xFFFFD700),
            );
            break;

          case PowerUpType.shield:
            player.shield = min(player.maxShield, player.shield + p.value);
            particleSystem.addDamageText(
              player.x,
              player.y - 20,
              '+SHIELD',
              const Color(0xFF00E5FF),
            );
            break;

          case PowerUpType.energy:
            player.energy = min(player.maxEnergy, player.energy + p.value);
            particleSystem.addDamageText(
              player.x,
              player.y - 20,
              '+ENERGY',
              const Color(0xFF76FF03),
            );
            break;

          case PowerUpType.triShot:
            player.triShotTimer = 10.0; // 10s duration
            particleSystem.addDamageText(
              player.x,
              player.y - 20,
              'TRI-SHOT ACTIVE!',
              const Color(0xFFFF007F),
              isCritical: true,
            );
            break;

          case PowerUpType.overdrive:
            player.energy = player.maxEnergy;
            particleSystem.addDamageText(
              player.x,
              player.y - 20,
              'NOVA READY!',
              const Color(0xFFD500F9),
              isCritical: true,
            );
            break;
        }
      }
    }
  }

  // Trigger screen-clearing super Nova Blast
  bool triggerNovaBlast() {
    if (player.energy < player.maxEnergy) return false;

    player.energy = 0.0;
    SoundEffects.playNovaBlast();
    stats.triggerShake(22.0);
    stats.triggerSlowMotion(1.0, 0.3);

    // Screen shockwave & radial particles
    particleSystem.spawnNovaBlast(player.x, player.y, screenWidth, screenHeight);

    // Clear all enemy bullets
    bullets.removeWhere((b) => !b.isPlayer);

    // Deal massive damage to all onscreen enemies
    for (int i = enemies.length - 1; i >= 0; i--) {
      final e = enemies[i];
      e.health -= 380.0;
      particleSystem.addDamageText(
        e.x,
        e.y,
        '380 NOVA',
        const Color(0xFFD500F9),
        isCritical: true,
      );

      if (e.health <= 0) {
        enemies.removeAt(i);
        stats.addScore(e.scoreValue);
        stats.scrapCollected += e.scrapReward;
        particleSystem.spawnExplosion(e.x, e.y, e.primaryColor, count: 32);
      }
    }

    return true;
  }
}
