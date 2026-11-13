import 'package:ambatrans/core/strings.dart';
import 'package:ambatrans/features/settings/presentation/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../fakes/fake_permissions_channel.dart';
import '../../fakes/fake_settings_channel.dart';
import '../../helpers/pump_home.dart';

Future<void> scrollToSwitch(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byType(Switch),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(find.byType(Switch));
  await tester.pumpAndSettle();
}

bool switchValue(WidgetTester tester) =>
    tester.widget<Switch>(find.byType(Switch)).value;

void main() {
  testWidgets('switch is off by default with a description', (tester) async {
    await pumpScreen(tester, const SettingsScreen());
    await scrollToSwitch(tester);
    expect(find.text(Strings.accurateMode), findsOneWidget);
    expect(find.text(Strings.accurateModeDescription), findsOneWidget);
    expect(switchValue(tester), isFalse);
  });

  testWidgets('turning on shows the explanation before anything else', (
    tester,
  ) async {
    final permissions = FakePermissionsChannel();
    final settings = FakeSettingsChannel();
    await pumpScreen(
      tester,
      const SettingsScreen(),
      settings: settings,
      permissions: permissions,
    );
    await scrollToSwitch(tester);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text(Strings.accurateSheetBody), findsOneWidget);
    expect(permissions.openAccessibilitySettingsCalls, 0);
    expect((await settings.getAll())['accessibility_mode'], isFalse);

    await tester.tap(find.text(Strings.cancel));
    await tester.pumpAndSettle();
    expect(switchValue(tester), isFalse);
    expect(permissions.openAccessibilitySettingsCalls, 0);
    expect((await settings.getAll())['accessibility_mode'], isFalse);
  });

  testWidgets('proceeding saves the choice and opens system settings', (
    tester,
  ) async {
    final permissions = FakePermissionsChannel();
    final settings = FakeSettingsChannel();
    await pumpScreen(
      tester,
      const SettingsScreen(),
      settings: settings,
      permissions: permissions,
    );
    await scrollToSwitch(tester);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.proceed));
    await tester.pumpAndSettle();

    expect(permissions.openAccessibilitySettingsCalls, 1);
    expect((await settings.getAll())['accessibility_mode'], isTrue);
    expect(switchValue(tester), isTrue);
    expect(find.text(Strings.accurateModeNeedsSystem), findsOneWidget);
  });

  testWidgets('status follows the system when the user returns', (
    tester,
  ) async {
    final permissions = FakePermissionsChannel();
    await pumpScreen(
      tester,
      const SettingsScreen(),
      settings: FakeSettingsChannel({'accessibility_mode': true}),
      permissions: permissions,
    );
    await scrollToSwitch(tester);
    expect(find.text(Strings.accurateModeNeedsSystem), findsOneWidget);

    permissions.accessibility = true; // enabled in system settings
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text(Strings.accurateModeNeedsSystem), findsNothing);
    expect(switchValue(tester), isTrue);
  });

  testWidgets('tapping the hint opens the system settings', (tester) async {
    final permissions = FakePermissionsChannel();
    await pumpScreen(
      tester,
      const SettingsScreen(),
      settings: FakeSettingsChannel({'accessibility_mode': true}),
      permissions: permissions,
    );
    await scrollToSwitch(tester);
    await tester.tap(find.text(Strings.accurateModeNeedsSystem));
    expect(permissions.openAccessibilitySettingsCalls, 1);
  });

  testWidgets('turning off saves without any prompt', (tester) async {
    final settings = FakeSettingsChannel({'accessibility_mode': true});
    await pumpScreen(tester, const SettingsScreen(), settings: settings);
    await scrollToSwitch(tester);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text(Strings.accurateSheetBody), findsNothing);
    expect((await settings.getAll())['accessibility_mode'], isFalse);
    expect(switchValue(tester), isFalse);
  });

  testWidgets('does not overflow at 200% font scale', (tester) async {
    await pumpScreen(
      tester,
      const SettingsScreen(),
      settings: FakeSettingsChannel({'accessibility_mode': true}),
      textScale: 2,
    );
    await scrollToSwitch(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
