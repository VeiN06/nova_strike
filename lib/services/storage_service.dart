import 'package:shared_preferences/shared_preferences.dart';
import 'localization_service.dart';

class StorageService {
  // High score & currency
  static const String _keyHighScore = 'nova_high_score';
  static const String _keyTotalScrap = 'nova_total_scrap';

  // Per-ship upgrade levels (ship 0 = Viper, 1 = Phantom, 2 = Aegis, 3 = Phoenix)
  // Blaster levels per ship
  static const String _keyBlasterLevel0 = 'nova_blaster_level_0';
  static const String _keyBlasterLevel1 = 'nova_blaster_level_1';
  static const String _keyBlasterLevel2 = 'nova_blaster_level_2';
  static const String _keyBlasterLevel3 = 'nova_blaster_level_3';

  // Shield levels per ship
  static const String _keyShieldLevel0 = 'nova_shield_level_0';
  static const String _keyShieldLevel1 = 'nova_shield_level_1';
  static const String _keyShieldLevel2 = 'nova_shield_level_2';
  static const String _keyShieldLevel3 = 'nova_shield_level_3';

  // Magnet levels per ship
  static const String _keyMagnetLevel0 = 'nova_magnet_level_0';
  static const String _keyMagnetLevel1 = 'nova_magnet_level_1';
  static const String _keyMagnetLevel2 = 'nova_magnet_level_2';
  static const String _keyMagnetLevel3 = 'nova_magnet_level_3';

  // Missile unlocked per ship
  static const String _keyMissileUnlocked0 = 'nova_missile_unlocked_0';
  static const String _keyMissileUnlocked1 = 'nova_missile_unlocked_1';
  static const String _keyMissileUnlocked2 = 'nova_missile_unlocked_2';
  static const String _keyMissileUnlocked3 = 'nova_missile_unlocked_3';

  // Settings
  static const String _keySoundEnabled = 'nova_sound_enabled';
  static const String _keyHapticsEnabled = 'nova_haptics_enabled';
  static const String _keyLanguage = 'nova_language';

  // Ship selection & unlocks
  static const String _keySelectedShip = 'nova_selected_ship';
  static const String _keyUnlockedShips = 'nova_unlocked_ships';

  // Visual themes (0 = Deep Space, 1 = Void Crimson, 2 = Neon Gold, 3 = Ice Blue, 4 = Solar Flare)
  static const int _themeCount = 5;
  static const String _keyThemeIndex = 'nova_theme_index';

  // Theme prices kept for reference only; all themes are now free to select.
  static final List<int> _themePrices = [0, 1500, 3000, 2500, 4000];

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = StorageService(prefs);

    // Initialize localization state
    Localization.currentLanguage = service.language;
    return service;
  }

  // ========== GETTERS ==========

  int get highScore => _prefs.getInt(_keyHighScore) ?? 0;
  int get totalScrap => _prefs.getInt(_keyTotalScrap) ?? 0;

  // Per-ship upgrade getters
  int getBlasterLevel(int shipIndex) {
    switch (shipIndex) {
      case 1:
        return _prefs.getInt(_keyBlasterLevel1) ?? 1;
      case 2:
        return _prefs.getInt(_keyBlasterLevel2) ?? 1;
      case 3:
        return _prefs.getInt(_keyBlasterLevel3) ?? 1;
      case 0:
      default:
        return _prefs.getInt(_keyBlasterLevel0) ?? 1;
    }
  }

  int getShieldLevel(int shipIndex) {
    switch (shipIndex) {
      case 1:
        return _prefs.getInt(_keyShieldLevel1) ?? 1;
      case 2:
        return _prefs.getInt(_keyShieldLevel2) ?? 1;
      case 3:
        return _prefs.getInt(_keyShieldLevel3) ?? 1;
      case 0:
      default:
        return _prefs.getInt(_keyShieldLevel0) ?? 1;
    }
  }

  int getMagnetLevel(int shipIndex) {
    switch (shipIndex) {
      case 1:
        return _prefs.getInt(_keyMagnetLevel1) ?? 1;
      case 2:
        return _prefs.getInt(_keyMagnetLevel2) ?? 1;
      case 3:
        return _prefs.getInt(_keyMagnetLevel3) ?? 1;
      case 0:
      default:
        return _prefs.getInt(_keyMagnetLevel0) ?? 1;
    }
  }

  bool getMissileUnlocked(int shipIndex) {
    switch (shipIndex) {
      case 1:
        return _prefs.getBool(_keyMissileUnlocked1) ?? false;
      case 2:
        return _prefs.getBool(_keyMissileUnlocked2) ?? false;
      case 3:
        return _prefs.getBool(_keyMissileUnlocked3) ?? false;
      case 0:
      default:
        return _prefs.getBool(_keyMissileUnlocked0) ?? false;
    }
  }

  bool get soundEnabled => _prefs.getBool(_keySoundEnabled) ?? true;
  bool get hapticsEnabled => _prefs.getBool(_keyHapticsEnabled) ?? true;

  AppLanguage get language {
    final langStr = _prefs.getString(_keyLanguage) ?? 'tr';
    return langStr == 'en' ? AppLanguage.en : AppLanguage.tr;
  }

  int get selectedShip => _prefs.getInt(_keySelectedShip) ?? 0;

  List<int> get unlockedShips {
    final list = _prefs.getStringList(_keyUnlockedShips);
    if (list == null || list.isEmpty) {
      return [0]; // Viper unlocked by default
    }
    return list.map((e) => int.tryParse(e) ?? 0).toList();
  }

  // ========== SETTERS ==========

  Future<void> saveHighScore(int score) async {
    if (score > highScore) {
      await _prefs.setInt(_keyHighScore, score);
    }
  }

  Future<void> addScrap(int amount) async {
    await _prefs.setInt(_keyTotalScrap, totalScrap + amount);
  }

  Future<bool> spendScrap(int cost) async {
    if (totalScrap >= cost) {
      await _prefs.setInt(_keyTotalScrap, totalScrap - cost);
      return true;
    }
    return false;
  }

  // Per-ship upgrade setters
  Future<void> upgradeBlaster(int shipIndex) async {
    final current = getBlasterLevel(shipIndex);
    if (current < 5) {
      switch (shipIndex) {
        case 1:
          await _prefs.setInt(_keyBlasterLevel1, current + 1);
          break;
        case 2:
          await _prefs.setInt(_keyBlasterLevel2, current + 1);
          break;
        case 3:
          await _prefs.setInt(_keyBlasterLevel3, current + 1);
          break;
        case 0:
        default:
          await _prefs.setInt(_keyBlasterLevel0, current + 1);
          break;
      }
    }
  }

  Future<void> upgradeShield(int shipIndex) async {
    final current = getShieldLevel(shipIndex);
    if (current < 5) {
      switch (shipIndex) {
        case 1:
          await _prefs.setInt(_keyShieldLevel1, current + 1);
          break;
        case 2:
          await _prefs.setInt(_keyShieldLevel2, current + 1);
          break;
        case 3:
          await _prefs.setInt(_keyShieldLevel3, current + 1);
          break;
        case 0:
        default:
          await _prefs.setInt(_keyShieldLevel0, current + 1);
          break;
      }
    }
  }

  Future<void> unlockMissile(int shipIndex) async {
    switch (shipIndex) {
      case 1:
        await _prefs.setBool(_keyMissileUnlocked1, true);
        break;
      case 2:
        await _prefs.setBool(_keyMissileUnlocked2, true);
        break;
      case 3:
        await _prefs.setBool(_keyMissileUnlocked3, true);
        break;
      case 0:
      default:
        await _prefs.setBool(_keyMissileUnlocked0, true);
        break;
    }
  }

  Future<void> upgradeMagnet(int shipIndex) async {
    final current = getMagnetLevel(shipIndex);
    if (current < 5) {
      switch (shipIndex) {
        case 1:
          await _prefs.setInt(_keyMagnetLevel1, current + 1);
          break;
        case 2:
          await _prefs.setInt(_keyMagnetLevel2, current + 1);
          break;
        case 3:
          await _prefs.setInt(_keyMagnetLevel3, current + 1);
          break;
        case 0:
        default:
          await _prefs.setInt(_keyMagnetLevel0, current + 1);
          break;
      }
    }
  }

  // Downgrade by exactly one level. Deliberately does NOT refund scrap: the
  // player can step back to test a lower tier, but the spent currency is gone.
  Future<void> _setLevel(List<String> keys, int shipIndex, int value) async {
    await _prefs.setInt(keys[shipIndex.clamp(0, keys.length - 1)], value);
  }

  Future<bool> downgradeBlaster(int shipIndex) async {
    final current = getBlasterLevel(shipIndex);
    if (current <= 1) return false;
    await _setLevel(
      [_keyBlasterLevel0, _keyBlasterLevel1, _keyBlasterLevel2, _keyBlasterLevel3],
      shipIndex,
      current - 1,
    );
    return true;
  }

  Future<bool> downgradeShield(int shipIndex) async {
    final current = getShieldLevel(shipIndex);
    if (current <= 1) return false;
    await _setLevel(
      [_keyShieldLevel0, _keyShieldLevel1, _keyShieldLevel2, _keyShieldLevel3],
      shipIndex,
      current - 1,
    );
    return true;
  }

  Future<bool> downgradeMagnet(int shipIndex) async {
    final current = getMagnetLevel(shipIndex);
    if (current <= 1) return false;
    await _setLevel(
      [_keyMagnetLevel0, _keyMagnetLevel1, _keyMagnetLevel2, _keyMagnetLevel3],
      shipIndex,
      current - 1,
    );
    return true;
  }

  // ========== THEMES ==========

  int get themeIndex => _prefs.getInt(_keyThemeIndex) ?? 0;

  // Per-theme purchase flags
  static const String _keyTheme0Purchased = 'nova_theme_0_purchased';
  static const String _keyTheme1Purchased = 'nova_theme_1_purchased';
  static const String _keyTheme2Purchased = 'nova_theme_2_purchased';
  static const String _keyTheme3Purchased = 'nova_theme_3_purchased';
  static const String _keyTheme4Purchased = 'nova_theme_4_purchased';

  static final List<String> _themePurchasedKeys = [
    _keyTheme0Purchased,
    _keyTheme1Purchased,
    _keyTheme2Purchased,
    _keyTheme3Purchased,
    _keyTheme4Purchased,
  ];

  bool isThemePurchased(int themeIndex) {
    if (themeIndex < 0 || themeIndex >= _themeCount) return false;
    if (themeIndex == 0) return true; // Deep Space is always free
    return _prefs.getBool(_themePurchasedKeys[themeIndex]) ?? false;
  }

  int getThemePrice(int themeIndex) {
    if (themeIndex < 0 || themeIndex >= _themeCount) return 0;
    return _themePrices[themeIndex];
  }

  Future<bool> purchaseTheme(int themeIndex) async {
    if (themeIndex < 0 || themeIndex >= _themeCount) return false;
    final price = _themePrices[themeIndex];
    if (price == 0) {
      await setThemeIndex(themeIndex);
      return true;
    }
    if (totalScrap >= price && !isThemePurchased(themeIndex)) {
      final success = await spendScrap(price);
      if (success) {
        await _prefs.setBool(_themePurchasedKeys[themeIndex], true);
        await setThemeIndex(themeIndex);
        return true;
      }
    }
    return false;
  }

  /// Switch between already-purchased themes without spending scrap.
  Future<bool> selectTheme(int themeIndex) async {
    if (themeIndex < 0 || themeIndex >= _themeCount) return false;
    if (!isThemePurchased(themeIndex)) return false;
    await setThemeIndex(themeIndex);
    return true;
  }

  Future<void> setThemeIndex(int index) async {
    await _prefs.setInt(_keyThemeIndex, index);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_keySoundEnabled, enabled);
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    await _prefs.setBool(_keyHapticsEnabled, enabled);
  }

  Future<void> setLanguage(AppLanguage lang) async {
    Localization.currentLanguage = lang;
    await _prefs.setString(_keyLanguage, lang == AppLanguage.en ? 'en' : 'tr');
  }

  Future<void> setSelectedShip(int shipIndex) async {
    await _prefs.setInt(_keySelectedShip, shipIndex);
  }

  Future<bool> unlockShip(int shipIndex, int cost) async {
    if (totalScrap >= cost) {
      final success = await spendScrap(cost);
      if (success) {
        final current = unlockedShips;
        if (!current.contains(shipIndex)) {
          current.add(shipIndex);
          await _prefs.setStringList(
            _keyUnlockedShips,
            current.map((e) => e.toString()).toList(),
          );
        }
        await setSelectedShip(shipIndex);
        return true;
      }
    }
    return false;
  }

  // ========== REBALANCED COSTS ==========

  int getBlasterUpgradeCost(int shipIndex) {
    final level = getBlasterLevel(shipIndex);
    switch (level) {
      case 1:
        return 250;
      case 2:
        return 600;
      case 3:
        return 1200;
      case 4:
        return 2200;
      default:
        return 3500;
    }
  }

  int getShieldUpgradeCost(int shipIndex) {
    final level = getShieldLevel(shipIndex);
    switch (level) {
      case 1:
        return 200;
      case 2:
        return 500;
      case 3:
        return 1000;
      case 4:
        return 1800;
      default:
        return 3000;
    }
  }

  int getMissileUnlockCost(int shipIndex) => 600;

  int getMagnetUpgradeCost(int shipIndex) {
    final level = getMagnetLevel(shipIndex);
    switch (level) {
      case 1:
        return 150;
      case 2:
        return 350;
      case 3:
        return 700;
      case 4:
        return 1300;
      default:
        return 2200;
    }
  }

  // Ship unlock costs - increased
  int getShipCost(int shipIndex) {
    switch (shipIndex) {
      case 0:
        return 0; // Free starter
      case 1:
        return 500; // Phantom Stryker
      case 2:
        return 1200; // Void Aegis
      case 3:
        return 2500; // Solar Phoenix
      default:
        return 9999;
    }
  }

  // Upgrade cost descriptions
  String getUpgradeTitle(int moduleType, int shipIndex) {
    switch (moduleType) {
      case 0: // Blasters
        return Localization.text('blasters');
      case 1: // Shield
        return Localization.text('shield_mod');
      case 2: // Missiles
        return Localization.text('missiles');
      case 3: // Magnet
        return Localization.text('magnet_mod');
      default:
        return 'Upgrade';
    }
  }
}
