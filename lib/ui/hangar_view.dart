import 'dart:math';

import 'package:flutter/material.dart';
import '../engine/sound_effects.dart';
import '../rendering/ship_designs.dart';
import '../services/localization_service.dart';
import '../services/storage_service.dart';

class HangarView extends StatefulWidget {
  final StorageService storage;
  final VoidCallback onBack;

  const HangarView({
    super.key,
    required this.storage,
    required this.onBack,
  });

  @override
  State<HangarView> createState() => _HangarViewState();
}

class _HangarViewState extends State<HangarView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _tabIndex = 0; // 0 = Modules, 1 = Starship Fleet
  int _selectedShipInHangar = 0; // currently viewed ship in fleet tab

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _selectedShipInHangar = widget.storage.selectedShip;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ========== PER-SHIP UPGRADES (Tab 0) ==========

  void _upgradeBlaster() async {
    final cost = widget.storage.getBlasterUpgradeCost(_selectedShipInHangar);
    final level = widget.storage.getBlasterLevel(_selectedShipInHangar);
    if (widget.storage.totalScrap >= cost && level < 5) {
      final success = await widget.storage.spendScrap(cost);
      if (success) {
        await widget.storage.upgradeBlaster(_selectedShipInHangar);
        SoundEffects.playPowerUp();
        setState(() {});
      }
    }
  }

  void _downgradeBlaster() async {
    if (await widget.storage.downgradeBlaster(_selectedShipInHangar)) {
      setState(() {});
    }
  }

  void _upgradeShield() async {
    final cost = widget.storage.getShieldUpgradeCost(_selectedShipInHangar);
    final level = widget.storage.getShieldLevel(_selectedShipInHangar);
    if (widget.storage.totalScrap >= cost && level < 5) {
      final success = await widget.storage.spendScrap(cost);
      if (success) {
        await widget.storage.upgradeShield(_selectedShipInHangar);
        SoundEffects.playPowerUp();
        setState(() {});
      }
    }
  }

  void _downgradeShield() async {
    if (await widget.storage.downgradeShield(_selectedShipInHangar)) {
      setState(() {});
    }
  }

  void _unlockMissile() async {
    final cost = widget.storage.getMissileUnlockCost(_selectedShipInHangar);
    if (widget.storage.totalScrap >= cost && !widget.storage.getMissileUnlocked(_selectedShipInHangar)) {
      final success = await widget.storage.spendScrap(cost);
      if (success) {
        await widget.storage.unlockMissile(_selectedShipInHangar);
        SoundEffects.playPowerUp();
        setState(() {});
      }
    }
  }

  void _upgradeMagnet() async {
    final cost = widget.storage.getMagnetUpgradeCost(_selectedShipInHangar);
    final level = widget.storage.getMagnetLevel(_selectedShipInHangar);
    if (widget.storage.totalScrap >= cost && level < 5) {
      final success = await widget.storage.spendScrap(cost);
      if (success) {
        await widget.storage.upgradeMagnet(_selectedShipInHangar);
        SoundEffects.playPowerUp();
        setState(() {});
      }
    }
  }

  void _downgradeMagnet() async {
    if (await widget.storage.downgradeMagnet(_selectedShipInHangar)) {
      setState(() {});
    }
  }

  // ========== SHIP SELECTION / UNLOCK (Tab 1) ==========

  Future<void> _unlockShip(int shipIndex) async {
    final cost = widget.storage.getShipCost(shipIndex);
    final unlocked = widget.storage.unlockedShips;
    if (cost == 0) {
      await widget.storage.setSelectedShip(shipIndex);
      setState(() => _selectedShipInHangar = shipIndex);
      return;
    }
    if (!unlocked.contains(shipIndex) && widget.storage.totalScrap >= cost) {
      final success = await widget.storage.unlockShip(shipIndex, cost);
      if (success) {
        SoundEffects.playPowerUp();
        setState(() {
          _selectedShipInHangar = shipIndex;
          widget.storage.setSelectedShip(shipIndex);
        });
      }
    }
  }

  Future<void> _selectShip(int shipIndex) async {
    if (!widget.storage.unlockedShips.contains(shipIndex)) return;
    await widget.storage.setSelectedShip(shipIndex);
    setState(() => _selectedShipInHangar = shipIndex);
  }

  @override
  Widget build(BuildContext context) {
    final unlockedShips = widget.storage.unlockedShips;
    final selectedShip = widget.storage.selectedShip;

    return Scaffold(
      backgroundColor: const Color(0xFF090919),
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF00E5FF)),
                    onPressed: widget.onBack,
                  ),
                  Text(
                    Localization.text('hangar_title'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E38),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFD700)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, color: Color(0xFFFFD700), size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.storage.totalScrap}',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tabs: Modules | Fleet
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF12122A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                    value: 0,
                    label: Text(Localization.text('upgrades')),
                    icon: const Icon(Icons.build, size: 18),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text(Localization.text('select_ship')),
                    icon: const Icon(Icons.space_dashboard, size: 18),
                  ),
                ],
                selected: {_tabIndex},
                onSelectionChanged: (Set<int> selection) {
                  setState(() {
                    _tabIndex = selection.first;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            // Content
            Expanded(
              child: _tabIndex == 0
                  ? _buildModulesTab()
                  : _buildFleetTab(unlockedShips, selectedShip),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesTab() {
    final blasterLevel = widget.storage.getBlasterLevel(_selectedShipInHangar);
    final shieldLevel = widget.storage.getShieldLevel(_selectedShipInHangar);
    final missileUnlocked = widget.storage.getMissileUnlocked(_selectedShipInHangar);
    final magnetLevel = widget.storage.getMagnetLevel(_selectedShipInHangar);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        _buildUpgradeCard(
          title: Localization.text('blasters'),
          subtitle: _getBlasterDescription(blasterLevel),
          icon: Icons.electric_bolt,
          color: const Color(0xFF00E5FF),
          currentLevel: blasterLevel,
          maxLevel: 5,
          cost: widget.storage.getBlasterUpgradeCost(_selectedShipInHangar),
          onUpgrade: _upgradeBlaster,
          onDowngrade: _downgradeBlaster,
        ),
        const SizedBox(height: 12),
        _buildUpgradeCard(
          title: Localization.text('shield_mod'),
          subtitle: '${Localization.text('shield_capacity')}: ${80 + shieldLevel * 25} HP',
          icon: Icons.shield,
          color: const Color(0xFF76FF03),
          currentLevel: shieldLevel,
          maxLevel: 5,
          cost: widget.storage.getShieldUpgradeCost(_selectedShipInHangar),
          onUpgrade: _upgradeShield,
          onDowngrade: _downgradeShield,
        ),
        const SizedBox(height: 12),
        _buildUpgradeCard(
          title: Localization.text('missiles'),
          subtitle: missileUnlocked
              ? Localization.text('status_selected')
              : '${Localization.text('missile_deploy')} (${Localization.text('missile_fire_rate')})',
          icon: Icons.rocket_launch,
          color: const Color(0xFFFF9100),
          currentLevel: missileUnlocked ? 1 : 0,
          maxLevel: 1,
          cost: widget.storage.getMissileUnlockCost(_selectedShipInHangar),
          onUpgrade: _unlockMissile,
          isUnlock: true,
        ),
        const SizedBox(height: 12),
        _buildUpgradeCard(
          title: Localization.text('magnet_mod'),
          subtitle: '${Localization.text('magnet_radius')}: ${110 + magnetLevel * 35}px',
          icon: Icons.all_inclusive,
          color: const Color(0xFFFF007F),
          currentLevel: magnetLevel,
          maxLevel: 5,
          cost: widget.storage.getMagnetUpgradeCost(_selectedShipInHangar),
          onUpgrade: _upgradeMagnet,
          onDowngrade: _downgradeMagnet,
        ),
        const SizedBox(height: 20),

        // Info: upgrades are per-ship
        Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: const Color(0xFF14142B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white54, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  Localization.text('per_ship_info'),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Visual Themes
        Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: const Color(0xFF14142B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF007F).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.format_color_fill, color: Color(0xFFFF007F), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      Localization.text('theme'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, i) {
                    final isCurrent = i == widget.storage.themeIndex;
                    final purchased = widget.storage.isThemePurchased(i);
                    final price = widget.storage.getThemePrice(i);
                    final Color themeColor = switch (i) {
                      1 => const Color(0xFFFF1744),
                      2 => const Color(0xFFFFD700),
                      3 => const Color(0xFF00E5FF),
                      4 => const Color(0xFFFF5722),
                      _ => const Color(0xFF00E5FF),
                    };
                    final themeName = i == 0
                        ? Localization.text('theme_deep_space')
                        : i == 1
                            ? Localization.text('theme_void_crimson')
                            : i == 2
                                ? Localization.text('theme_neon_gold')
                                : i == 3
                                    ? Localization.text('theme_ice_blue')
                                    : Localization.text('theme_solar_flare');

                    return GestureDetector(
                      onTap: () async {
                        final purchased = widget.storage.isThemePurchased(i);
                        final price = widget.storage.getThemePrice(i);
                        final canAfford = widget.storage.totalScrap >= price;

                        if (purchased) {
                          await widget.storage.selectTheme(i);
                        } else if (canAfford) {
                          await widget.storage.purchaseTheme(i);
                        }
                        setState(() {});
                        SoundEffects.playPowerUp();
                      },
                      child: Container(
                        width: 95,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: isCurrent ? themeColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCurrent ? themeColor : Colors.white10,
                            width: isCurrent ? 2.0 : 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: themeColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: themeColor, width: 1.5),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              themeName,
                              style: TextStyle(
                                color: isCurrent ? themeColor : Colors.white60,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            if (!widget.storage.isThemePurchased(i))
                              Text(
                                '${price} ${Localization.text('scrap_cost')}',
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 8,
                                ),
                              )
                            else if (isCurrent)
                              const Icon(
                                Icons.radio_button_checked,
                                color: Colors.greenAccent,
                                size: 14,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFleetTab(List<int> unlockedShips, int selectedShip) {
    final shipConfigs = [
      {
        'index': 0,
        'name': Localization.text('ship_viper'),
        'desc': Localization.text('ship_viper_desc'),
        'cost': widget.storage.getShipCost(0),
        'color': const Color(0xFF00E5FF),
        'free': true,
      },
      {
        'index': 1,
        'name': Localization.text('ship_phantom'),
        'desc': Localization.text('ship_phantom_desc'),
        'cost': widget.storage.getShipCost(1),
        'color': const Color(0xFF76FF03),
        'free': false,
      },
      {
        'index': 2,
        'name': Localization.text('ship_aegis'),
        'desc': Localization.text('ship_aegis_desc'),
        'cost': widget.storage.getShipCost(2),
        'color': const Color(0xFFFF007F),
        'free': false,
      },
      {
        'index': 3,
        'name': Localization.text('ship_phoenix'),
        'desc': Localization.text('ship_phoenix_desc'),
        'cost': widget.storage.getShipCost(3),
        'color': const Color(0xFFFFD700),
        'free': false,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: shipConfigs.length,
      itemBuilder: (context, i) {
        final cfg = shipConfigs[i];
        final shipIdx = cfg['index'] as int;
        final isUnlocked = unlockedShips.contains(shipIdx);
        final isSelected = selectedShip == shipIdx;
        final canAfford = widget.storage.totalScrap >= (cfg['cost'] as int);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: const Color(0xFF14142B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? (cfg['color'] as Color).withOpacity(0.8)
                  : Colors.white12,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: (cfg['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (cfg['color'] as Color).withOpacity(0.5),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(70, 70),
                    painter: _HangarShipPainter(
                      phase: _animController.value * 2 * pi * 0.5,
                      shipColor: cfg['color'] as Color,
                      shipIndex: shipIdx,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cfg['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isUnlocked && isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              Localization.text('status_selected'),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (!isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              Localization.text('status_locked'),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cfg['desc'] as String,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                    if (!isUnlocked) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.bolt, color: Color(0xFFFFD700), size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${cfg['cost']} ${Localization.text('scrap_cost')}',
                            style: TextStyle(
                              color: canAfford ? const Color(0xFFFFD700) : Colors.white38,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (isUnlocked && !isSelected)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () => _selectShip(shipIdx),
                  child: Text(Localization.text('btn_select'), style: const TextStyle(fontWeight: FontWeight.bold)),
                )
              else if (!isUnlocked)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford
                        ? const Color(0xFFFF007F)
                        : Colors.white24,
                    foregroundColor: canAfford ? Colors.white : Colors.white54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: canAfford ? () => _unlockShip(shipIdx) : null,
                  child: Text(
                    (cfg['free'] as bool) ? Localization.text('select') : Localization.text('unlock'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              else
                Text(
                  Localization.text('status_selected'),
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpgradeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int currentLevel,
    required int maxLevel,
    required int cost,
    required VoidCallback onUpgrade,
    VoidCallback? onDowngrade,
    bool isUnlock = false,
  }) {
    final levelText = isUnlock
        ? (currentLevel >= 1 ? Localization.text('selected') : '${Localization.text('unlock')} • ${cost} ${Localization.text('scrap_cost')}')
        : '${currentLevel} / $maxLevel';

    final canAfford = widget.storage.totalScrap >= cost;
    final isMax = currentLevel >= maxLevel;

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFF101026),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMax ? Colors.greenAccent.withOpacity(0.5) : Colors.white10,
          width: isMax ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isMax)
                      Text(
                        Localization.text('max'),
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      levelText,
                      style: TextStyle(
                        color: isMax ? Colors.greenAccent : Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (!isMax)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canAfford ? color : Colors.white10,
                          foregroundColor: canAfford ? Colors.black : Colors.white38,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: canAfford ? onUpgrade : null,
                        child: Text(
                          isUnlock ? Localization.text('unlock') : '${cost}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    if (!isUnlock && currentLevel > 1 && onDowngrade != null)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white54,
                          side: BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: onDowngrade,
                        child: const Text(
                          '-1',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getBlasterDescription(int level) {
    switch (level) {
      case 1:
        return 'Level 1: Single Pulse Laser (Next: Dual)';
      case 2:
        return 'Level 2: Dual Cannons (Next: Tri-Spread)';
      case 3:
        return 'Level 3: Tri-Spread Cannons (Next: Quad)';
      case 4:
        return 'Level 4: Quad Heavy Barrage (Next: Plasma)';
      case 5:
      default:
        return 'Level 5 [MAX]: Hyper Plasma Overdrive';
    }
  }
}

class _HangarShipPainter extends CustomPainter {
  final double phase;
  final Color shipColor;
  final int shipIndex;
  _HangarShipPainter({
    required this.phase,
    this.shipColor = const Color(0xFF00E5FF),
    this.shipIndex = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    ShipDesigns.drawPlayerShip(
      canvas,
      size.width / 2,
      size.height / 2,
      32.0,
      100.0,
      100.0,
      0.0,
      phase,
      shipIndex: shipIndex,
    );
  }

  @override
  bool shouldRepaint(covariant _HangarShipPainter oldDelegate) => true;
}
