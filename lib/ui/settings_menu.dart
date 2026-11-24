import 'package:flutter/material.dart';
import '../engine/sound_effects.dart';
import '../services/localization_service.dart';
import '../services/storage_service.dart';

class SettingsMenu extends StatefulWidget {
  final StorageService storage;
  final VoidCallback onBack;

  const SettingsMenu({
    super.key,
    required this.storage,
    required this.onBack,
  });

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  late bool _sound;
  late bool _haptics;
  late AppLanguage _lang;

  @override
  void initState() {
    super.initState();
    _sound = widget.storage.soundEnabled;
    _haptics = widget.storage.hapticsEnabled;
    _lang = widget.storage.language;
    SoundEffects.soundEnabled = _sound;
    SoundEffects.hapticsEnabled = _haptics;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070714),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF00E5FF)),
                    onPressed: widget.onBack,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    Localization.text('settings'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: [
                  const SizedBox(height: 24),

                  // Audio Effects
                  _buildSettingTile(
                    icon: Icons.volume_up,
                    iconColor: const Color(0xFF00E5FF),
                    title: Localization.text('audio_effects'),
                    subtitle: _sound ? 'AÇIK' : 'KAPALI',
                    value: _sound,
                    onChanged: (val) async {
                      setState(() => _sound = val);
                      await widget.storage.setSoundEnabled(val);
                      SoundEffects.soundEnabled = val;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Tactile Haptics
                  _buildSettingTile(
                    icon: Icons.vibration,
                    iconColor: const Color(0xFFFF007F),
                    title: Localization.text('tactile_haptics'),
                    subtitle: _haptics ? 'AÇIK' : 'KAPALI',
                    value: _haptics,
                    onChanged: (val) async {
                      setState(() => _haptics = val);
                      await widget.storage.setHapticsEnabled(val);
                      SoundEffects.hapticsEnabled = val;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Language
                  _buildLanguageTile(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF101026),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: value ? Colors.greenAccent : Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: iconColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF101026),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.language, color: Color(0xFFFFD700), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Localization.text('language'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Localization.getLanguageName(_lang),
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<AppLanguage>(
            value: _lang,
            dropdownColor: const Color(0xFF14142B),
            style: const TextStyle(color: Colors.white),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5FF)),
            underline: Container(),
            items: const [
              DropdownMenuItem(
                value: AppLanguage.tr,
                child: Text('Türkçe'),
              ),
              DropdownMenuItem(
                value: AppLanguage.en,
                child: Text('English'),
              ),
            ],
            onChanged: (val) async {
              if (val == null) return;
              setState(() => _lang = val);
              await widget.storage.setLanguage(val);
              Localization.currentLanguage = val;
            },
          ),
        ],
      ),
    );
  }
}
