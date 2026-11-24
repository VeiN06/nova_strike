import 'dart:math';
import '../models/enemy.dart';

class WaveManager {
  int currentWave = 1;
  double waveTimer = 0.0;
  double spawnCooldown = 1.2;
  double spawnTimer = 0.0;
  int enemiesSpawnedInWave = 0;
  int totalEnemiesForWave = 6;
  bool bossSpawned = false;
  bool waveTransitioning = false;
  double transitionTimer = 0.0;
  String bannerMessage = '';
  double bannerTimer = 0.0;

  final Random _random = Random();

  void startWave(int wave) {
    currentWave = wave;
    enemiesSpawnedInWave = 0;
    bossSpawned = false;
    waveTransitioning = false;
    transitionTimer = 0.0;

    if (isBossWave(wave)) {
      totalEnemiesForWave = 1;
      bannerMessage = 'WARNING: VOID TITAN DETECTED';
      bannerTimer = 4.0;
      spawnCooldown = 0.5;
    } else {
      // More enemies per wave, scales infinitely
      totalEnemiesForWave = 6 + (wave * 3) + ((wave ~/ 5) * 4);
      bannerMessage = 'SECTOR $wave: HOSTILES INCOMING';
      bannerTimer = 2.5;
      // Spawn cooldown decreases with wave, minimum 0.25s for bullet hell late game
      spawnCooldown = max(0.25, 1.4 - (wave * 0.07));
    }
  }

  bool isBossWave(int wave) {
    return wave % 5 == 0;
  }

  void update(double dt) {
    if (bannerTimer > 0) bannerTimer -= dt;
    spawnTimer += dt;
    if (waveTransitioning) {
      transitionTimer += dt;
    }
  }

  bool canSpawnNextEnemy() {
    if (waveTransitioning) return false;
    if (enemiesSpawnedInWave >= totalEnemiesForWave) return false;
    return spawnTimer >= spawnCooldown;
  }

  List<Enemy> spawnEnemies(double screenWidth, double screenHeight) {
    spawnTimer = 0.0;
    final List<Enemy> spawned = [];

    // Infinite scaling factors:
    // Speed: +8% per wave compound
    final speedMultiplier = 1.0 + (currentWave * 0.08);
    // Health: +12% per wave compound after wave 5
    final healthMultiplier = currentWave <= 5
        ? (1.0 + currentWave * 0.05)
        : (1.25 * pow(1.08, currentWave - 5));

    if (isBossWave(currentWave)) {
      if (!bossSpawned) {
        bossSpawned = true;
        enemiesSpawnedInWave = totalEnemiesForWave;
        final boss = Enemy.createBoss(screenWidth / 2, -70.0, currentWave);
        // maxHealth is final, so rebuild the boss with the scaled value baked in
        // rather than mutating it. Keeping health and maxHealth equal is what
        // makes the health bar start full and actually drain.
        final scaled = boss.health * healthMultiplier;
        spawned.add(Enemy(
          x: boss.x,
          y: boss.y,
          vx: boss.vx,
          vy: boss.vy,
          health: scaled,
          maxHealth: scaled,
          type: boss.type,
          radius: boss.radius,
          primaryColor: boss.primaryColor,
          scoreValue: boss.scoreValue,
          scrapReward: boss.scrapReward,
          shootCooldown: boss.shootCooldown,
          initialX: boss.initialX,
        ));
      }
      return spawned;
    }

    // Standard wave composition
    enemiesSpawnedInWave++;
    final roll = _random.nextDouble();

    if (currentWave == 1) {
      // Drones only in wave 1
      final x = 40.0 + _random.nextDouble() * (screenWidth - 80.0);
      final e = Enemy.createDrone(x, -30.0, speedMultiplier);
      e.health *= healthMultiplier;
      spawned.add(e);
    } else if (currentWave == 2) {
      if (roll < 0.6) {
        final x = 40.0 + _random.nextDouble() * (screenWidth - 80.0);
        final e = Enemy.createDrone(x, -30.0, speedMultiplier);
        e.health *= healthMultiplier;
        spawned.add(e);
      } else {
        final x = 40.0 + _random.nextDouble() * (screenWidth - 80.0);
        final e = Enemy.createInterceptor(x, -35.0, speedMultiplier);
        e.health *= healthMultiplier;
        spawned.add(e);
      }
    } else {
      // Wave 3+ mixed fleets with higher cruiser chance at higher waves
      final cruiserChance = min(0.40, 0.15 + (currentWave * 0.02));
      final interceptorChance = min(0.50, 0.35 + (currentWave * 0.01));

      if (roll < (1.0 - cruiserChance - interceptorChance)) {
        // Drones
        final x = 40.0 + _random.nextDouble() * (screenWidth - 80.0);
        final e = Enemy.createDrone(x, -30.0, speedMultiplier);
        e.health *= healthMultiplier;
        // Faster shoot cooldown at high waves
        e.shootCooldown = max(0.8, e.shootCooldown - (currentWave * 0.04));
        spawned.add(e);
      } else if (roll < (1.0 - cruiserChance)) {
        // Interceptors
        final x = 40.0 + _random.nextDouble() * (screenWidth - 80.0);
        final e = Enemy.createInterceptor(x, -35.0, speedMultiplier);
        e.health *= healthMultiplier;
        e.shootCooldown = max(0.6, e.shootCooldown - (currentWave * 0.03));
        spawned.add(e);
      } else {
        // Cruiser
        final x = 60.0 + _random.nextDouble() * (screenWidth - 120.0);
        final e = Enemy.createCruiser(x, -50.0, speedMultiplier);
        e.health *= healthMultiplier;
        e.shootCooldown = max(0.9, e.shootCooldown - (currentWave * 0.03));
        spawned.add(e);
      }
    }

    return spawned;
  }

  void triggerWaveClear() {
    waveTransitioning = true;
    transitionTimer = 0.0;
    bannerMessage = 'SECTOR $currentWave CLEARED!';
    bannerTimer = 2.5;
  }

  void nextWave() {
    startWave(currentWave + 1);
  }

  void reset() {
    startWave(1);
  }
}
