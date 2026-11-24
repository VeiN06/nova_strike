import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../engine/game_engine.dart';
import '../engine/sound_effects.dart';
import '../models/game_state.dart';
import '../rendering/game_painter.dart';
import '../services/localization_service.dart';
import '../services/storage_service.dart';
import 'game_over_dialog.dart';

class GameView extends StatefulWidget {
  final StorageService storage;
  final VoidCallback onQuitToMenu;
  final VoidCallback onOpenHangar;

  const GameView({
    super.key,
    required this.storage,
    required this.onQuitToMenu,
    required this.onOpenHangar,
  });

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late GameEngine _engine;
  Duration _lastElapsed = Duration.zero;
  bool _initialized = false;
  bool _isGameOverShown = false;
  double _hudAccum = 0.0;
  final GlobalKey<_GameCanvasState> _canvasKey = GlobalKey<_GameCanvasState>();

  @override
  void initState() {
    super.initState();
    _engine = GameEngine();

    _engine.applyShipUpgrades(
      shipIndex: widget.storage.selectedShip,
      blasterLevel: widget.storage.getBlasterLevel(widget.storage.selectedShip),
      shieldLevel: widget.storage.getShieldLevel(widget.storage.selectedShip),
      hasMissiles: widget.storage.getMissileUnlocked(widget.storage.selectedShip),
      magnetLevel: widget.storage.getMagnetLevel(widget.storage.selectedShip),
    );
    _engine.stats.highScore = widget.storage.highScore;

    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    final double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    // Cap delta time to prevent physics jumping on hiccups
    final clampedDt = min(dt, 0.05);

    if (_engine.phase == GamePhase.playing) {
      _engine.update(clampedDt);

      if (_engine.phase == GamePhase.gameOver && !_isGameOverShown) {
        _isGameOverShown = true;
        _handleGameOver();
      }
    }

    // Repaint only the canvas. Calling setState() here rebuilt the whole HUD
    // widget tree on every single frame, and that cost compounds the longer a
    // session runs. The bars only need to refresh a few times a second.
    _canvasKey.currentState?.markNeedsPaint();

    _hudAccum += clampedDt;
    if (_hudAccum >= 0.1) {
      _hudAccum = 0.0;
      if (mounted) setState(() {});
    }
  }

  void _handleGameOver() async {
    final isNewHigh = _engine.stats.score > widget.storage.highScore;
    await widget.storage.saveHighScore(_engine.stats.score);
    await widget.storage.addScrap(_engine.stats.scrapCollected);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        stats: _engine.stats,
        isNewHighScore: isNewHigh,
        onRestart: () {
          Navigator.of(context).pop();
          _restartGame();
        },
        onHangar: () {
          Navigator.of(context).pop();
          widget.onOpenHangar();
        },
        onMenu: () {
          Navigator.of(context).pop();
          widget.onQuitToMenu();
        },
      ),
    );
  }

  void _restartGame() {
    _isGameOverShown = false;
    _engine.init(_engine.screenWidth, _engine.screenHeight);
    _engine.applyShipUpgrades(
      shipIndex: widget.storage.selectedShip,
      blasterLevel: widget.storage.getBlasterLevel(widget.storage.selectedShip),
      shieldLevel: widget.storage.getShieldLevel(widget.storage.selectedShip),
      hasMissiles: widget.storage.getMissileUnlocked(widget.storage.selectedShip),
      magnetLevel: widget.storage.getMagnetLevel(widget.storage.selectedShip),
    );
    _engine.stats.highScore = widget.storage.highScore;
  }

  void _showPauseDialog() {
    _engine.phase = GamePhase.paused;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFF101028),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Localization.text('paused'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Sound Toggle
                    ListTile(
                      leading: Icon(
                        widget.storage.soundEnabled ? Icons.volume_up : Icons.volume_off,
                        color: const Color(0xFF00E5FF),
                      ),
                      title: Text(Localization.text('audio_effects'), style: const TextStyle(color: Colors.white)),
                      trailing: Switch(
                        value: widget.storage.soundEnabled,
                        activeColor: const Color(0xFF00E5FF),
                        onChanged: (val) async {
                          await widget.storage.setSoundEnabled(val);
                          SoundEffects.soundEnabled = val;
                          setDialogState(() {});
                        },
                      ),
                    ),
                    // Haptics Toggle
                    ListTile(
                      leading: Icon(
                        widget.storage.hapticsEnabled ? Icons.vibration : Icons.smartphone,
                        color: const Color(0xFFFF007F),
                      ),
                      title: Text(Localization.text('tactile_haptics'), style: const TextStyle(color: Colors.white)),
                      trailing: Switch(
                        value: widget.storage.hapticsEnabled,
                        activeColor: const Color(0xFFFF007F),
                        onChanged: (val) async {
                          await widget.storage.setHapticsEnabled(val);
                          SoundEffects.hapticsEnabled = val;
                          setDialogState(() {});
                        },
                      ),
                    ),
                    // Language Toggle
                    ListTile(
                      leading: const Icon(Icons.language, color: Color(0xFFFFD700)),
                      title: Text(Localization.text('language'), style: const TextStyle(color: Colors.white)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            Localization.getLanguageName(Localization.currentLanguage),
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.swap_horiz, color: Color(0xFF00E5FF), size: 20),
                            onPressed: () async {
                              final newLang = Localization.currentLanguage == AppLanguage.tr
                                  ? AppLanguage.en
                                  : AppLanguage.tr;
                              await widget.storage.setLanguage(newLang);
                              Localization.currentLanguage = newLang;
                              setDialogState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _engine.phase = GamePhase.playing;
                      },
                      child: Text(Localization.text('resume'), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onQuitToMenu();
                      },
                      child: Text(Localization.text('quit_to_menu'), style: const TextStyle(color: Colors.white54, letterSpacing: 1.5)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (!_initialized) {
            _initialized = true;
            _engine.init(constraints.maxWidth, constraints.maxHeight);
            _engine.applyShipUpgrades(
              shipIndex: widget.storage.selectedShip,
              blasterLevel: widget.storage.getBlasterLevel(widget.storage.selectedShip),
              shieldLevel: widget.storage.getShieldLevel(widget.storage.selectedShip),
              hasMissiles: widget.storage.getMissileUnlocked(widget.storage.selectedShip),
              magnetLevel: widget.storage.getMagnetLevel(widget.storage.selectedShip),
            );
          }

          return Stack(
            children: [
              // Interactive Canvas with Touch/Drag Controls
              GestureDetector(
                onPanDown: (details) {
                  _engine.setPlayerTarget(details.localPosition.dx, details.localPosition.dy);
                },
                onPanUpdate: (details) {
                  _engine.setPlayerTarget(details.localPosition.dx, details.localPosition.dy);
                },
                child: _GameCanvas(
                key: _canvasKey,
                engine: _engine,
                themeIndex: widget.storage.themeIndex,
              ),
              ),

              // Cyber HUD Overlay
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      // Top Row: Shield/HP Bar, Wave/Combo, Score/Scrap, Pause
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Shield & HP Dual Vitals
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildVitalBar(
                                  label: Localization.text('shield'),
                                  value: _engine.player.shield,
                                  maxValue: _engine.player.maxShield,
                                  color: const Color(0xFF00E5FF),
                                ),
                                const SizedBox(height: 4),
                                _buildVitalBar(
                                  label: Localization.text('hull'),
                                  value: _engine.player.health,
                                  maxValue: _engine.player.maxHealth,
                                  color: const Color(0xFFFF1744),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Center Sector & Combo Banner
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Text(
                                    '${Localization.text('sector')} ${_engine.stats.currentWave}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                if (_engine.stats.combo > 1) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '${Localization.text('combo')} x${_engine.stats.multiplier.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Right Score & Scrap + Pause Button
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${_engine.stats.score}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.bolt, color: Color(0xFFFFD700), size: 14),
                                        Text(
                                          '${_engine.stats.scrapCollected}',
                                          style: const TextStyle(
                                            color: Color(0xFFFFD700),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.pause_circle_outline, color: Colors.white70, size: 26),
                                  onPressed: _showPauseDialog,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Super Nova Blast Ability Button
              Positioned(
                right: 20,
                bottom: 30,
                child: _buildNovaButton(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVitalBar({
    required String label,
    required double value,
    required double maxValue,
    required Color color,
  }) {
    final pct = (value / maxValue).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
            ),
            Text(
              '${value.round()}',
              style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color.withOpacity(0.5), width: 0.8),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: pct,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNovaButton() {
    final isReady = _engine.player.energy >= _engine.player.maxEnergy;
    final energyPct = (_engine.player.energy / _engine.player.maxEnergy).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        if (isReady) {
          _engine.triggerNovaBlast();
          setState(() {});
        }
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF140728),
          border: Border.all(
            color: isReady ? const Color(0xFFD500F9) : Colors.white24,
            width: isReady ? 2.5 : 1.2,
          ),
          boxShadow: isReady
              ? [
                  BoxShadow(
                    color: const Color(0xFFD500F9).withOpacity(0.6),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: energyPct,
              strokeWidth: 3.5,
              color: const Color(0xFFD500F9),
              backgroundColor: Colors.white12,
            ),
            Icon(
              Icons.flash_on,
              color: isReady ? Colors.white : Colors.white38,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

/// The canvas is split out so that only it repaints every tick. The HUD
/// overlay around it is rebuilt at most 10 times per second, which stops the
/// per-frame widget-tree cost from compounding during long play sessions.
class _GameCanvas extends StatefulWidget {
  final GameEngine engine;
  final int themeIndex;
  const _GameCanvas({super.key, required this.engine, required this.themeIndex});

  @override
  State<_GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends State<_GameCanvas> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: GamePainter(
        engine: widget.engine,
        themeIndex: widget.themeIndex,
      ),
    );
  }

  void markNeedsPaint() => setState(() {});
}
