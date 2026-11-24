import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'engine/sound_effects.dart';
import 'services/localization_service.dart';
import 'services/storage_service.dart';
import 'ui/game_view.dart';
import 'ui/hangar_view.dart';
import 'ui/main_menu.dart';
import 'ui/settings_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for optimal mobile gaming experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set immersive edge-to-edge status & navigation bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF070714),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Fullscreen: hide system chrome (status bar + navigation buttons) so the
  // game fills the whole tablet screen without a popup or manual resize.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final storage = await StorageService.init();
  await SoundEffects.init(
    sound: storage.soundEnabled,
    haptics: storage.hapticsEnabled,
  );

  runApp(NovaStrikeApp(storage: storage));
}

enum AppScreen {
  menu,
  game,
  hangar,
}

class NovaStrikeApp extends StatefulWidget {
  final StorageService storage;

  const NovaStrikeApp({super.key, required this.storage});

  @override
  State<NovaStrikeApp> createState() => _NovaStrikeAppState();
}

class _NovaStrikeAppState extends State<NovaStrikeApp> {
  AppScreen _currentScreen = AppScreen.menu;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nova Strike: Cyber Galaxy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF070714),
        primaryColor: const Color(0xFF00E5FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFFF007F),
          surface: Color(0xFF101026),
        ),
      ),
      home: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case AppScreen.menu:
        return MainMenu(
          storage: widget.storage,
          onStartGame: () => setState(() => _currentScreen = AppScreen.game),
          onOpenHangar: () => setState(() => _currentScreen = AppScreen.hangar),
        );

      case AppScreen.game:
        return GameView(
          storage: widget.storage,
          onQuitToMenu: () => setState(() => _currentScreen = AppScreen.menu),
          onOpenHangar: () => setState(() => _currentScreen = AppScreen.hangar),
        );

      case AppScreen.hangar:
        return HangarView(
          storage: widget.storage,
          onBack: () => setState(() => _currentScreen = AppScreen.menu),
        );
    }
  }
}
