import 'package:flutter/services.dart';

/// Audio is intentionally disabled while we isolate the stutter.
/// Every method is a no-op so the rest of the game keeps compiling and the
/// frame loop never touches the audioplayers plugin.
class SoundEffects {
  static bool soundEnabled = false;
  static bool hapticsEnabled = true;

  static Future<void> init({required bool sound, required bool haptics}) async {
    soundEnabled = false;
    hapticsEnabled = haptics;
  }

  static void _safeHaptic(Future<void> Function() action) {
    if (!hapticsEnabled) return;
    try {
      action().catchError((_) {});
    } catch (_) {}
  }

  static void playPlayerShoot() {
    _safeHaptic(() => HapticFeedback.selectionClick());
  }

  static void playEnemyHit() {
    _safeHaptic(() => HapticFeedback.lightImpact());
  }

  static void playExplosion() {
    _safeHaptic(() => HapticFeedback.mediumImpact());
  }

  static void playBossHit() {
    _safeHaptic(() => HapticFeedback.heavyImpact());
  }

  static void playPlayerDamage() {
    _safeHaptic(() => HapticFeedback.vibrate());
  }

  static void playPowerUp() {
    _safeHaptic(() => HapticFeedback.mediumImpact());
  }

  static void playNovaBlast() {
    _safeHaptic(() => HapticFeedback.heavyImpact());
  }

  static void dispose() {}
}
