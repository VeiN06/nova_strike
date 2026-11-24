import 'dart:math';

class PlayerShip {
  double x;
  double y;
  double targetX;
  double targetY;
  final double radius;

  int shipIndex; // 0: Viper, 1: Phantom, 2: Aegis, 3: Phoenix

  // Stats
  double health;
  double maxHealth;
  double shield;
  double maxShield;
  double energy;
  double maxEnergy;

  // Upgrades
  int blasterLevel;
  bool hasMissiles;
  double magnetRadius;
  double shieldRegenRate;

  // Timers & Buffs
  double fireTimer;
  double fireInterval;
  double missileTimer;
  double triShotTimer;
  double invulnerableTimer;
  double shieldFlashTimer;
  double thrusterPhase;
  double shieldRegenDelayTimer; // Pauses shield regen on hit

  PlayerShip({
    required this.x,
    required this.y,
    this.shipIndex = 0,
    this.radius = 24.0,
    this.health = 100.0,
    this.maxHealth = 100.0,
    this.shield = 100.0,
    this.maxShield = 100.0,
    this.energy = 0.0,
    this.maxEnergy = 100.0,
    this.blasterLevel = 1,
    this.hasMissiles = false,
    this.magnetRadius = 140.0,
    this.shieldRegenRate = 4.0,
    this.fireTimer = 0.0,
    this.fireInterval = 0.16,
    this.missileTimer = 0.0,
    this.triShotTimer = 0.0,
    this.invulnerableTimer = 0.0,
    this.shieldFlashTimer = 0.0,
    this.thrusterPhase = 0.0,
    this.shieldRegenDelayTimer = 0.0,
  })  : targetX = x,
        targetY = y;

  void update(double dt, double width, double height) {
    thrusterPhase += dt * 15.0;

    // Responsive lerp speed based on ship model
    double baseLerp = 22.0;
    if (shipIndex == 1) baseLerp = 27.0; // Phantom is agile
    if (shipIndex == 2) baseLerp = 18.0; // Aegis is heavy

    final lerpSpeed = baseLerp * dt;
    x += (targetX - x) * min(1.0, lerpSpeed);
    y += (targetY - y) * min(1.0, lerpSpeed);

    x = x.clamp(radius + 8.0, width - radius - 8.0);
    y = y.clamp(radius + 20.0, height - radius - 30.0);

    // Shield regen delay: must not take damage for 2.5s before shield regens
    if (shieldRegenDelayTimer > 0) {
      shieldRegenDelayTimer -= dt;
    } else if (shield < maxShield) {
      shield = min(maxShield, shield + shieldRegenRate * dt);
    }

    // Energy charge
    final energyRate = shipIndex == 3 ? 3.5 : 1.8;
    if (energy < maxEnergy) {
      energy = min(maxEnergy, energy + energyRate * dt);
    }

    if (fireTimer > 0) fireTimer -= dt;
    if (missileTimer > 0) missileTimer -= dt;
    if (triShotTimer > 0) triShotTimer -= dt;
    if (invulnerableTimer > 0) invulnerableTimer -= dt;
    if (shieldFlashTimer > 0) shieldFlashTimer -= dt;
  }

  void takeDamage(double amount, {bool isBossHit = false}) {
    if (invulnerableTimer > 0) return;

    shieldFlashTimer = 0.25;
    shieldRegenDelayTimer = 2.5; // Delay regen on every hit!

    // Boss or heavy hits partially bleed through shields (20% armor penetration)
    if (isBossHit && shield > 0) {
      final bleedThrough = amount * 0.20;
      health = max(0.0, health - bleedThrough);
      amount *= 0.80;
    }

    if (shield > 0) {
      if (shield >= amount) {
        shield -= amount;
        amount = 0;
      } else {
        amount -= shield;
        shield = 0;
      }
    }

    if (amount > 0) {
      health = max(0.0, health - amount);
    }
  }

  bool isAlive() => health > 0;
}
