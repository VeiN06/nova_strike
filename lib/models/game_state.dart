enum GamePhase {
  menu,
  playing,
  paused,
  waveClear,
  gameOver,
  victory,
}

class GameStats {
  int score;
  int highScore;
  int scrapCollected;
  int currentWave;
  int combo;
  double comboTimer;
  double multiplier;
  int enemiesDestroyed;
  int bossesDefeated;

  // Screen shake and VFX juice
  double screenShakeIntensity;
  double slowMotionTimer;
  double slowMotionFactor;

  GameStats({
    this.score = 0,
    this.highScore = 0,
    this.scrapCollected = 0,
    this.currentWave = 1,
    this.combo = 0,
    this.comboTimer = 0.0,
    this.multiplier = 1.0,
    this.enemiesDestroyed = 0,
    this.bossesDefeated = 0,
    this.screenShakeIntensity = 0.0,
    this.slowMotionTimer = 0.0,
    this.slowMotionFactor = 1.0,
  });

  void addScore(int basePoints) {
    combo++;
    comboTimer = 2.8; // 2.8 seconds to chain next hit
    multiplier = (1.0 + (combo * 0.1)).clamp(1.0, 5.0);
    score += (basePoints * multiplier).round();
    enemiesDestroyed++;

    if (score > highScore) {
      highScore = score;
    }
  }

  void triggerShake(double amount) {
    screenShakeIntensity = (screenShakeIntensity + amount).clamp(0.0, 25.0);
  }

  void triggerSlowMotion(double duration, double factor) {
    slowMotionTimer = duration;
    slowMotionFactor = factor;
  }

  void update(double dt) {
    // Decay screen shake
    if (screenShakeIntensity > 0) {
      screenShakeIntensity -= dt * 35.0;
      if (screenShakeIntensity < 0) screenShakeIntensity = 0;
    }

    // Combo timer decay
    if (comboTimer > 0) {
      comboTimer -= dt;
      if (comboTimer <= 0) {
        combo = 0;
        multiplier = 1.0;
      }
    }

    // Slow motion recovery
    if (slowMotionTimer > 0) {
      slowMotionTimer -= dt;
      if (slowMotionTimer <= 0) {
        slowMotionFactor = 1.0;
      }
    }
  }

  void reset() {
    score = 0;
    scrapCollected = 0;
    currentWave = 1;
    combo = 0;
    comboTimer = 0.0;
    multiplier = 1.0;
    enemiesDestroyed = 0;
    bossesDefeated = 0;
    screenShakeIntensity = 0.0;
    slowMotionTimer = 0.0;
    slowMotionFactor = 1.0;
  }
}
