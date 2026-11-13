import 'package:ambatrans/core/strings.dart';
import 'package:ambatrans/features/settings/presentation/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../fakes/fake_permissions_channel.dart';
import '../../helpers/pump_home.dart';

Finder switchOf(String title) => find.descendant(
  of: find.ancestor(of: find.text(title), matching: find.byType(Row)).first,
  matching: find.byType(Switch),
);

bool isOn(WidgetTester tester, String title) =>
    tester.widget<Switch>(switchOf(title)).value;

void main() {
  testWidgets('Izin section mirrors both permissions as switches', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const SettingsScreen(),
      permissions: FakePermissionsChannel(overlay: true),
    );
    expect(find.text(Strings.permissionsSection), findsOneWidget);
    expect(isOn(tester, Strings.overlayTitle), isTrue);
    expect(isOn(tester, Strings.notificationsTitle), isFalse);
  });

  testWidgets('overlay switch opens the system overlay screen', (tester) async {
    final permissions = FakePermissionsChannel();
    await pumpScreen(tester, const SettingsScreen(), permissions: permissions);
    await tester.tap(switchOf(Strings.overlayTitle));
    expect(permissions.openOverlaySettingsCalls, 1);
  });

  testWidgets('notifications switch asks for the permission and updates', (
    tester,
  ) async {
    final permissions = FakePermissionsChannel();
    await pumpScreen(tester, const SettingsScreen(), permissions: permissions);
    await tester.tap(switchOf(Strings.notificationsTitle));
    await tester.pumpAndSettle();
    expect(permissions.requestNotificationsCalls, 1);
    expect(isOn(tester, Strings.notificationsTitle), isTrue);
  });

  testWidgets('status updates when the user returns from system settings', (
    tester,
  ) async {
    final permissions = FakePermissionsChannel();
    await pumpScreen(tester, const SettingsScreen(), permissions: permissions);
    expect(isOn(tester, Strings.overlayTitle), isFalse);
    permissions.overlay = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(isOn(tester, Strings.overlayTitle), isTrue);
  });
}
