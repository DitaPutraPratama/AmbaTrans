import 'package:ambatrans/core/strings.dart';
import 'package:ambatrans/features/settings/presentation/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../fakes/fake_permissions_channel.dart';
import '../../fakes/fake_settings_channel.dart';
import '../../helpers/pump_home.dart';

/// The Mode akurat switch (the Izin cards have switches too).
Finder get accurateSwitch => find.descendant(
  of: find
      .ancestor(of: find.text(Strings.accurateMode), matching: find.byType(Row))
      .first,
  matching: find.byType(Switch),
);

Future<void> scrollToSwitch(WidgetTester tester) async {
  // The list is lazy: reach the title first, then the switch next to it.
  await tester.scrollUntilVisible(
    find.text(Strings.accurateMode),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(accurateSwitch);
  await tester.pumpAndSettle();
}

bool switchValue(WidgetTester tester) =>
    tester.widget<Switch>(accurateSwitch).value;

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
    await tester.tap(accurateSwitch);
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

  testWidgets('proceeding opens system settings but saves nothing yet', (
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
    await tester.tap(accurateSwitch);
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.proceed));
    await tester.pumpAndSettle();

    expect(permissions.openAccessibilitySettingsCalls, 1);
    expect((await settings.getAll())['accessibility_mode'], isFalse);
    expect(switchValue(tester), isFalse);
  });

  testWidgets('backing out of system settings leaves the switch off', (
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
    await tester.tap(accurateSwitch);
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.proceed));
    await tester.pumpAndSettle();

    // The user comes back without enabling the service.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(switchValue(tester), isFalse);
    expect((await settings.getAll())['accessibility_mode'], isFalse);
  });

  testWidgets('enabling the service in system settings turns the switch on', (
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
    await tester.tap(accurateSwitch);
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.proceed));
    await tester.pumpAndSettle();

    permissions.accessibility = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(switchValue(tester), isTrue);
    expect((await settings.getAll())['accessibility_mode'], isTrue);
  });

  testWidgets('already enabled in the system: turning on needs no detour', (
    tester,
  ) async {
    final permissions = FakePermissionsChannel(accessibility: true);
    final settings = FakeSettingsChannel();
    await pumpScreen(
      tester,
      const SettingsScreen(),
      settings: settings,
      permissions: permissions,
    );
    await scrollToSwitch(tester);
    await tester.tap(accurateSwitch);
    await tester.pumpAndSettle();
    expect(find.text(Strings.accurateSheetBody), findsNothing);
    expect(permissions.openAccessibilitySettingsCalls, 0);
    expect(switchValue(tester), isTrue);
  });

  testWidgets('switching the service off in the system turns the mode off', (
    tester,
  ) async {
    final permissions = FakePermissionsChannel(accessibility: true);
    final settings = FakeSettingsChannel({'accessibility_mode': true});
    await pumpScreen(
      tester,
      const SettingsScreen(),
      settings: settings,
      permissions: permissions,
    );
    await scrollToSwitch(tester);
    expect(switchValue(tester), isTrue);

    permissions.accessibility = false;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(switchValue(tester), isFalse);
    expect((await settings.getAll())['accessibility_mode'], isFalse);
  });

  testWidgets('turning off also switches the service off in the system', (
    tester,
  ) async {
    final settings = FakeSettingsChannel({'accessibility_mode': true});
    final permissions = FakePermissionsChannel(accessibility: true);
    await pumpScreen(
      tester,
      const SettingsScreen(),
      settings: settings,
      permissions: permissions,
    );
    await scrollToSwitch(tester);
    await tester.tap(accurateSwitch);
    await tester.pumpAndSettle();
    expect(find.text(Strings.accurateSheetBody), findsNothing);
    expect((await settings.getAll())['accessibility_mode'], isFalse);
    expect(switchValue(tester), isFalse);
    expect(permissions.disableAccessibilityCalls, 1);
    expect(permissions.accessibility, isFalse);
  });

  testWidgets('turning on again after off goes to system settings', (
    tester,
  ) async {
    final permissions = FakePermissionsChannel(accessibility: true);
    await pumpScreen(
      tester,
      const SettingsScreen(),
      settings: FakeSettingsChannel({'accessibility_mode': true}),
      permissions: permissions,
    );
    await scrollToSwitch(tester);
    await tester.tap(accurateSwitch); // off
    await tester.pumpAndSettle();
    await tester.tap(accurateSwitch); // on again
    await tester.pumpAndSettle();
    expect(find.text(Strings.accurateSheetBody), findsOneWidget);
    await tester.tap(find.text(Strings.proceed));
    await tester.pumpAndSettle();
    expect(permissions.openAccessibilitySettingsCalls, 1);
  });

  testWidgets('does not overflow at 200% font scale', (tester) async {
    await pumpScreen(
      tester,
      const SettingsScreen(),
      settings: FakeSettingsChannel({'accessibility_mode': true}),
      permissions: FakePermissionsChannel(accessibility: true),
      textScale: 2,
    );
    await scrollToSwitch(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(accurateSwitch);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
