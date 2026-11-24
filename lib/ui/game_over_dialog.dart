import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../services/localization_service.dart';

class GameOverDialog extends StatelessWidget {
  final GameStats stats;
  final bool isNewHighScore;
  final VoidCallback onRestart;
  final VoidCallback onHangar;
  final VoidCallback onMenu;

  const GameOverDialog({
    super.key,
    required this.stats,
    required this.isNewHighScore,
    required this.onRestart,
    required this.onHangar,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFF1744),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF1744).withOpacity(0.35),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Localization.text('mission_failed'),
              style: TextStyle(
                color: const Color(0xFFFF1744),
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.0,
                shadows: [
                  Shadow(color: Colors.red, blurRadius: 10),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${Localization.text('defense_breached')} SECTOR ${stats.currentWave}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 18),

            if (isNewHighScore) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD700)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      Localization.text('new_high_score'),
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Stats breakdown grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF171738),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatRow(Localization.text('final_score'), '${stats.score}', const Color(0xFF00E5FF)),
                  const Divider(color: Colors.white12, height: 16),
                  _buildStatRow(Localization.text('best_score'), '${stats.highScore}', Colors.white),
                  const Divider(color: Colors.white12, height: 16),
                  _buildStatRow(Localization.text('scrap_collected'), '+${stats.scrapCollected}', const Color(0xFFFFD700)),
                  const Divider(color: Colors.white12, height: 16),
                  _buildStatRow(Localization.text('hostiles_purged'), '${stats.enemiesDestroyed}', const Color(0xFFFF007F)),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E3F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onHangar,
                    child: Text(Localization.text('hangar'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onRestart,
                    child: Text(Localization.text('redeploy'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onMenu,
              child: Text(
                Localization.text('main_menu'),
                style: const TextStyle(color: Colors.white54, letterSpacing: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
