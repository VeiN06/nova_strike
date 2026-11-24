import 'dart:math';
import 'package:flutter/material.dart';
import '../engine/sound_effects.dart';
import '../models/star.dart';
import '../services/localization_service.dart';
import '../services/storage_service.dart';
import 'google_play_dialog.dart';
import 'settings_menu.dart';

class MainMenu extends StatefulWidget {
  final StorageService storage;
  final VoidCallback onStartGame;
  final VoidCallback onOpenHangar;

  const MainMenu({
    super.key,
    required this.storage,
    required this.onStartGame,
    required this.onOpenHangar,
  });

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with SingleTickerProviderStateMixin {
  late AnimationController _twinkleController;
  final List<Star> _bgStars = [];
  final Random _random = Random();
  double _titlePulse = 0.0;

  @override
  void initState() {
    super.initState();
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Populate background stars once - full screen distribution
    for (int i = 0; i < 100; i++) {
      _bgStars.add(Star.random(600, 1000, _random));
    }
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    super.dispose();
  }

  void _showHowToPlayDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF101026),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.gamepad, color: Color(0xFF00E5FF)),
                  const SizedBox(width: 8),
                  Text(
                    Localization.text('intel'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              const Divider(color: Color(0xFF1E293B)),
              const SizedBox(height: 10),
              _buildIntelRow(Icons.touch_app, 'Drag across screen to pilot your starfighter and dodge hostiles.'),
              const SizedBox(height: 10),
              _buildIntelRow(Icons.auto_awesome, 'Blasters fire automatically. Weapons level up in the Hangar.'),
              const SizedBox(height: 10),
              _buildIntelRow(Icons.bolt, 'Collect Gold Scraps from debris to purchase persistent ship upgrades.'),
              const SizedBox(height: 10),
              _buildIntelRow(Icons.flash_on, 'Fill the Super Meter to unleash the screen-clearing NOVA BLAST!'),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('READY FOR COMBAT', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntelRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF00E5FF), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF070714),
      body: Stack(
        children: [
          // Animated Starfield Background - Full Screen (efficient: only twinkle animation, no per-frame position updates)
          AnimatedBuilder(
            animation: _twinkleController,
            builder: (context, child) {
              return CustomPaint(
                size: screenSize,
                painter: _MenuStarPainter(
                  stars: _bgStars,
                  twinkle: _twinkleController.value,
                ),
              );
            },
          ),

          // Menu Content - Centered vertically for any screen size
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenSize.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Status: High Score & Total Scrap
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // High Score Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16162E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${Localization.text('best_score')}: ${widget.storage.highScore}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Scrap Bank
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16162E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.6)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bolt, color: Color(0xFFFFD700), size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${Localization.text('total_scrap')}: ${widget.storage.totalScrap}',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Center: Game Title & Logo
                      Column(
                        children: [
                          // Stylized Title with Glow & Shadow Layers (no subtitle)
                          AnimatedBuilder(
                            animation: _twinkleController,
                            builder: (context, child) {
                              final pulse = 0.92 + sin(_twinkleController.value * 2 * 3.14159 * 2) * 0.04;
                              return Transform.scale(
                                scale: pulse,
                                child: Column(
                                  children: [
                                    const Text(
                                      'NOVA',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 64,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 10.0,
                                        shadows: [
                                          Shadow(
                                            color: Color(0xFF00E5FF),
                                            blurRadius: 18,
                                            offset: Offset(0, 0),
                                          ),
                                          Shadow(
                                            color: Color(0x6600E5FF),
                                            blurRadius: 40,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // STRIKE in a bordered pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00E5FF).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                                      ),
                                      child: const Text(
                                        'STRIKE',
                                        style: TextStyle(
                                          color: Color(0xFF00E5FF),
                                          fontSize: 34,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 6.0,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black,
                                              blurRadius: 6,
                                              offset: Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Action Buttons
                      Column(
                        children: [
                          // Launch Mission Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E5FF),
                                foregroundColor: Colors.black,
                                elevation: 10,
                                shadowColor: const Color(0xFF00E5FF).withOpacity(0.7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: widget.onStartGame,
                              child: Text(
                                Localization.text('launch_mission'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Hangar Store Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFFFF007F), width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: widget.onOpenHangar,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.build_circle, color: Color(0xFFFF007F)),
                                  const SizedBox(width: 8),
                                  Text(
                                    Localization.text('ship_hangar'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Settings Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SettingsMenu(
                                      storage: widget.storage,
                                      onBack: () => Navigator.of(context).pop(),
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.tune, color: Color(0xFFFFD700)),
                                  const SizedBox(width: 8),
                                  Text(
                                    Localization.text('settings'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Bottom Utilities: Intel & Store Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.info_outline, color: Colors.white60, size: 16),
                            label: Text(Localization.text('intel'), style: const TextStyle(color: Colors.white60)),
                            onPressed: _showHowToPlayDialog,
                          ),
                          const SizedBox(width: 24),
                          TextButton.icon(
                            icon: const Icon(Icons.verified, color: Color(0xFF00E5FF), size: 16),
                            label: Text(Localization.text('store_privacy'), style: const TextStyle(color: Color(0xFF00E5FF))),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const GooglePlayComplianceDialog(),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuStarPainter extends CustomPainter {
  final List<Star> stars;
  final double twinkle;
  _MenuStarPainter({required this.stars, required this.twinkle});

  @override
  void paint(Canvas canvas, Size size) {
    // One shared paint, color swapped in place. Building a new Color per star
    // per frame with withOpacity was a steady allocation cost on the menu.
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in stars) {
      final starAlpha = (0.35 + sin(s.twinkleOffset + twinkle * 6.0) * 0.65).clamp(0.0, 1.0);
      paint.color = s.color.withOpacity(starAlpha);
      canvas.drawCircle(Offset(s.x, s.y), s.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MenuStarPainter oldDelegate) =>
      oldDelegate.twinkle != twinkle;
}
