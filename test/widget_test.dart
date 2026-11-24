import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nova_strike/main.dart';
import 'package:nova_strike/services/storage_service.dart';

void main() {
  testWidgets('Nova Strike App launch, menu display and navigation test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'nova_high_score': 12500,
      'nova_total_scrap': 450,
      'nova_blaster_level': 2,
      'nova_shield_level': 1,
      'nova_missile_unlocked': false,
      'nova_magnet_level': 1,
    });

    final storage = await StorageService.init();

    await tester.pumpWidget(NovaStrikeApp(storage: storage));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Title & Badges are rendered properly
    expect(find.text('NOVA STRIKE'), findsOneWidget);
    expect(find.text('CYBER GALAXY'), findsOneWidget);
    expect(find.text('BEST: 12500'), findsOneWidget);
    expect(find.text('450'), findsOneWidget);

    // Verify Main Buttons exist
    expect(find.text('LAUNCH MISSION'), findsOneWidget);
    expect(find.text('SHIP HANGAR'), findsOneWidget);
    expect(find.text('INTEL'), findsOneWidget);
    expect(find.text('STORE & PRIVACY'), findsOneWidget);

    // Open Hangar
    await tester.tap(find.text('SHIP HANGAR'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('BLASTER CANNONS'), findsOneWidget);
    expect(find.text('QUANTUM SHIELDING'), findsOneWidget);
    expect(find.text('HOMING MICRO-MISSILES'), findsOneWidget);

    // Navigate back to menu
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('LAUNCH MISSION'), findsOneWidget);
  });
}
