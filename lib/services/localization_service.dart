import 'dart:ui';

enum AppLanguage {
  tr,
  en,
}

class Localization {
  static AppLanguage currentLanguage = AppLanguage.tr;

  static const Map<String, Map<AppLanguage, String>> _localizedValues = {
    // ========== MENU & GENERAL ==========
    'title': {
      AppLanguage.tr: 'NOVA STRIKE',
      AppLanguage.en: 'NOVA STRIKE',
    },
    'subtitle': {
      AppLanguage.tr: 'UZAY SAVAŞI',
      AppLanguage.en: 'ARCADE SPACE COMBAT',
    },
    'launch_mission': {
      AppLanguage.tr: 'GÖREVİ BAŞLAT',
      AppLanguage.en: 'LAUNCH MISSION',
    },
    'ship_hangar': {
      AppLanguage.tr: 'UZAY GEMİSİ HANGARI',
      AppLanguage.en: 'SHIP HANGAR',
    },
    'settings': {
      AppLanguage.tr: 'AYARLAR',
      AppLanguage.en: 'SETTINGS',
    },
    'intel': {
      AppLanguage.tr: 'KILAVUZ',
      AppLanguage.en: 'INTEL',
    },
    'store_privacy': {
      AppLanguage.tr: 'GİZLİLİK & MAĞAZA',
      AppLanguage.en: 'STORE & PRIVACY',
    },
    'best_score': {
      AppLanguage.tr: 'EN İYİ SKOR',
      AppLanguage.en: 'BEST SCORE',
    },
    'total_scrap': {
      AppLanguage.tr: 'TOPLAM HURDA',
      AppLanguage.en: 'TOTAL SCRAP',
    },

    // ========== SETTINGS ==========
    'audio_effects': {
      AppLanguage.tr: 'Ses Efektleri',
      AppLanguage.en: 'Audio Effects',
    },
    'tactile_haptics': {
      AppLanguage.tr: 'Titreşim Geri Bildirimi',
      AppLanguage.en: 'Tactile Haptics',
    },
    'language': {
      AppLanguage.tr: 'Dil',
      AppLanguage.en: 'Language',
    },
    'language_tr': {
      AppLanguage.tr: 'Türkçe',
      AppLanguage.en: 'Türkçe',
    },
    'language_en': {
      AppLanguage.tr: 'İngilizce',
      AppLanguage.en: 'English',
    },
    'back': {
      AppLanguage.tr: 'GERİ',
      AppLanguage.en: 'BACK',
    },

    // ========== IN-GAME HUD ==========
    'shield': {
      AppLanguage.tr: 'KALKAN',
      AppLanguage.en: 'SHIELD',
    },
    'hull': {
      AppLanguage.tr: 'GÖVDE',
      AppLanguage.en: 'HULL',
    },
    'sector': {
      AppLanguage.tr: 'SEKTÖR',
      AppLanguage.en: 'SECTOR',
    },
    'combo': {
      AppLanguage.tr: 'KOMBO',
      AppLanguage.en: 'COMBO',
    },
    'score': {
      AppLanguage.tr: 'SKOR',
      AppLanguage.en: 'SCORE',
    },
    'nova_ready': {
      AppLanguage.tr: 'NOVA HAZIR!',
      AppLanguage.en: 'NOVA READY!',
    },

    // ========== PAUSE DIALOG ==========
    'paused': {
      AppLanguage.tr: 'DURAKLATILDI',
      AppLanguage.en: 'PAUSED',
    },
    'resume': {
      AppLanguage.tr: 'DEVAM ET',
      AppLanguage.en: 'RESUME',
    },
    'quit_to_menu': {
      AppLanguage.tr: 'ANA MENÜYE DÖN',
      AppLanguage.en: 'QUIT TO MENU',
    },

    // ========== GAME OVER & VICTORY ==========
    'mission_failed': {
      AppLanguage.tr: 'GÖREV BAŞARISIZ',
      AppLanguage.en: 'MISSION FAILED',
    },
    'defense_breached': {
      AppLanguage.tr: 'SEKTÖR SAVUNMASI AŞILDI',
      AppLanguage.en: 'SECTOR DEFENSE BREACHED',
    },
    'new_high_score': {
      AppLanguage.tr: 'YENİ REKOR!',
      AppLanguage.en: 'NEW HIGH SCORE!',
    },
    'final_score': {
      AppLanguage.tr: 'NİHİ AI SKOR',
      AppLanguage.en: 'FINAL SCORE',
    },
    'scrap_collected': {
      AppLanguage.tr: 'TOPLANAN HURDA',
      AppLanguage.en: 'SCRAP COLLECTED',
    },
    'hostiles_purged': {
      AppLanguage.tr: 'YOK EDİLEN DÜŞMAN',
      AppLanguage.en: 'HOSTILES PURGED',
    },
    'redeploy': {
      AppLanguage.tr: 'YENİDEN BAŞLA',
      AppLanguage.en: 'REDEPLOY',
    },
    'hangar': {
      AppLanguage.tr: 'HANGAR',
      AppLanguage.en: 'HANGAR',
    },
    'main_menu': {
      AppLanguage.tr: 'ANA MENÜ',
      AppLanguage.en: 'MAIN MENU',
    },

    // ========== HANGAR & SHIP SHOP ==========
    'hangar_title': {
      AppLanguage.tr: 'UZAY GEMİSİ HANGARI',
      AppLanguage.en: 'SHIP HANGAR',
    },
    'select_ship': {
      AppLanguage.tr: 'GEMİ FİLOSU',
      AppLanguage.en: 'STARSHIP FLEET',
    },
    'selected': {
      AppLanguage.tr: 'SEÇİLİ',
      AppLanguage.en: 'SELECTED',
    },
    'select': {
      AppLanguage.tr: 'SEÇ',
      AppLanguage.en: 'SELECT',
    },
    'unlock': {
      AppLanguage.tr: 'KİLİDİ AÇ',
      AppLanguage.en: 'UNLOCK',
    },
    'upgrades': {
      AppLanguage.tr: 'GEMİ MODÜLLERİ',
      AppLanguage.en: 'SHIP MODULES',
    },
    'max': {
      AppLanguage.tr: 'MAKS',
      AppLanguage.en: 'MAX',
    },
    'scrap_cost': {
      AppLanguage.tr: 'HURDA',
      AppLanguage.en: 'SCRAP',
    },

    // ========== SHIPS ==========
    'ship_viper': {
      AppLanguage.tr: 'VIPER MK-I (DENGELİ)',
      AppLanguage.en: 'VIPER MK-I (BALANCED)',
    },
    'ship_viper_desc': {
      AppLanguage.tr: 'Çevik, dengeli manevra ve standart kalkan kapasitesi.',
      AppLanguage.en: 'Agile fighter with balanced speed and shield.',
    },
    'ship_phantom': {
      AppLanguage.tr: 'PHANTOM STRIKER (KRİTİK HIZ)',
      AppLanguage.en: 'PHANTOM STRIKER (HIGH CRIT)',
    },
    'ship_phantom_desc': {
      AppLanguage.tr: 'Yüksek ateş hızı, %40 kritik hasar şansı, daha hafif zırh.',
      AppLanguage.en: 'Ultra-fast fire rate, 40% crit chance, light armor.',
    },
    'ship_aegis': {
      AppLanguage.tr: 'VOID AEGIS (AĞIR ZIRH)',
      AppLanguage.en: 'VOID AEGIS (HEAVY ARMOR)',
    },
    'ship_aegis_desc': {
      AppLanguage.tr: 'Ağır kalkan kaplaması, delen ikili plazma atışı.',
      AppLanguage.en: 'Heavy quantum shield armor, piercing dual plasma.',
    },
    'ship_phoenix': {
      AppLanguage.tr: 'SOLAR PHOENIX (AMİRAL GEMİSİ)',
      AppLanguage.en: 'SOLAR PHOENIX (FLAGSHIP)',
    },
    'ship_phoenix_desc': {
      AppLanguage.tr: 'Dörtlü lazer bataryası, otomatik füze sistemi ve hızlı Nova şarjı.',
      AppLanguage.en: 'Quad laser batteries, auto missiles and rapid Nova charge.',
    },

    // ========== MODULES ==========
    'blasters': {
      AppLanguage.tr: 'PLAZMA LAZERLERİ',
      AppLanguage.en: 'BLASTER CANNONS',
    },
    'shield_mod': {
      AppLanguage.tr: 'KUANTUM KALKAN',
      AppLanguage.en: 'QUANTUM SHIELDING',
    },
    'missiles': {
      AppLanguage.tr: 'GÜDÜMLÜ MİKRO FÜZELER',
      AppLanguage.en: 'HOMING MISSILES',
    },
    'magnet_mod': {
      AppLanguage.tr: 'MANYETİK ÇEKİM ALANI',
      AppLanguage.en: 'MAGNETIC FIELD',
    },
    'shield_capacity': {
      AppLanguage.tr: 'Kalkan Kapasitesi',
      AppLanguage.en: 'Shield Capacity',
    },
    'missile_deploy': {
      AppLanguage.tr: 'İkili Güdümlü Füze',
      AppLanguage.en: 'Twin Seeker Missiles',
    },
    'missile_fire_rate': {
      AppLanguage.tr: 'Her 0.85sn\'de ateş eder',
      AppLanguage.en: 'Fires every 0.85s',
    },
    'magnet_radius': {
      AppLanguage.tr: 'Hurda ve Güç Atma Çekme Yarıçapı',
      AppLanguage.en: 'Scrap & Power-up Pull Radius',
    },
    'per_ship_info': {
      AppLanguage.tr: 'Geliştirmeler her gemi için ayrı ayrı takip edilir. Her geminin kendi yükseltme ağacı vardır.',
      AppLanguage.en: 'Upgrades are tracked per ship. Each ship has its own upgrade tree.',
    },
    'status_selected': {
      AppLanguage.tr: 'SEÇİLİ',
      AppLanguage.en: 'SELECTED',
    },
    'status_locked': {
      AppLanguage.tr: 'KİLİTLİ',
      AppLanguage.en: 'LOCKED',
    },
    'btn_select': {
      AppLanguage.tr: 'SEÇ',
      AppLanguage.en: 'SELECT',
    },

    // ========== VISUAL THEMES ==========
    'theme': {
      AppLanguage.tr: 'Görünüm Teması',
      AppLanguage.en: 'Visual Theme',
    },
    'theme_deep_space': {
      AppLanguage.tr: 'Deep Space (Ücretsiz)',
      AppLanguage.en: 'Deep Space (Free)',
    },
    'theme_void_crimson': {
      AppLanguage.tr: 'Void Crimson',
      AppLanguage.en: 'Void Crimson',
    },
    'theme_neon_gold': {
      AppLanguage.tr: 'Neon Gold',
      AppLanguage.en: 'Neon Gold',
    },
    'theme_ice_blue': {
      AppLanguage.tr: 'Ice Blue',
      AppLanguage.en: 'Ice Blue',
    },
    'theme_solar_flare': {
      AppLanguage.tr: 'Solar Flare',
      AppLanguage.en: 'Solar Flare',
    },
    'theme_purchase': {
      AppLanguage.tr: 'Hurda ile satın al: ',
      AppLanguage.en: 'Purchase with scrap: ',
    },
    'theme_owned': {
      AppLanguage.tr: 'Sahipsiniz',
      AppLanguage.en: 'Owned',
    },

    // ========== WARNINGS & BOSS ==========
    'boss_warning': {
      AppLanguage.tr: 'UYARI: VOID TITAN TESPİT EDİLDİ!',
      AppLanguage.en: 'WARNING: VOID TITAN DETECTED!',
    },
    'sector_incoming': {
      AppLanguage.tr: 'SEKTÖR GİRİŞİ: DÜŞMAN FİLOSU YAKLAŞIYOR',
      AppLanguage.en: 'SECTOR ENTRY: HOSTILES INCOMING',
    },
    'sector_cleared': {
      AppLanguage.tr: 'SEKTÖR TEMİZLENDİ!',
      AppLanguage.en: 'SECTOR CLEARED!',
    },
  };

  static String text(String key) {
    final entry = _localizedValues[key];
    if (entry == null) return key;
    return entry[currentLanguage] ?? entry[AppLanguage.en] ?? key;
  }

  static String getLanguageName(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.tr:
        return text('language_tr');
      case AppLanguage.en:
        return text('language_en');
    }
  }
}

// Initialize language from system locale if not yet set
AppLanguage getSystemLanguage() {
  final locale = window.locale;
  final languageCode = locale.languageCode;
  if (languageCode == 'tr') return AppLanguage.tr;
  return AppLanguage.en;
}
