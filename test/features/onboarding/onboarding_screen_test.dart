import 'package:ambatrans/app/theme.dart';
import 'package:ambatrans/core/strings.dart';
import 'package:ambatrans/core/widgets/pill_button.dart';
import 'package:ambatrans/features/home/presentation/home_screen.dart';
import 'package:ambatrans/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../fakes/fake_permissions_channel.dart';
import '../../fakes/fake_settings_channel.dart';
import '../../helpers/pump_home.dart';

PillButton button(WidgetTester tester, String label) =>
    tester.widget<PillButton>(
      find.ancestor(of: find.text(label), matching: find.byType(PillButton)),
    );

Future<void> tapPrimary(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> resume(WidgetTester tester) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first launch shows onboarding step 1 with default languages', (
    tester,
  ) async {
    await pumpHome(
      tester,
      settings: FakeSettingsChannel(),
      permissions: FakePermissionsChannel(),
    );
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text(Strings.stepOf(1, 4)), findsOneWidget);
    expect(find.text('Inggris'), findsOneWidget);
    expect(find.text('Indonesia'), findsOneWidget);
    expect(find.text(Strings.back), findsNothing);
  });

  testWidgets('goes straight to Home once onboarding is done', (tester) async {
    await pumpHome(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  testWidgets('language card opens the sheet and saves the choice', (
    tester,
  ) async {
    final settings = FakeSettingsChannel();
    await pumpHome(tester, settings: settings);
    await tester.tap(find.text(Strings.from));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jepang'));
    await tester.pumpAndSettle();
    expect((await settings.getAll())['source_lang'], 'ja');
    expect(find.text('Jepang'), findsOneWidget);
  });

  testWidgets('full flow: permissions, ready, Home, never shown again', (
    tester,
  ) async {
    final settings = FakeSettingsChannel();
    final permissions = FakePermissionsChannel();
    await pumpHome(tester, settings: settings, permissions: permissions);

    await tapPrimary(tester, Strings.next); // language -> overlay
    expect(find.text(Strings.stepOf(2, 4)), findsOneWidget);
    expect(button(tester, Strings.next).onPressed, isNull);

    await tester.tap(find.text(Strings.openSettings));
    expect(permissions.openOverlaySettingsCalls, 1);
    permissions.overlay = true; // granted in system settings
    await resume(tester);
    expect(find.text(Strings.permissionGranted), findsOneWidget);
    expect(button(tester, Strings.next).onPressed, isNotNull);

    await tapPrimary(tester, Strings.next); // overlay -> notifications
    expect(find.text(Strings.stepOf(3, 4)), findsOneWidget);
    await tester.tap(find.text(Strings.allow));
    await tester.pumpAndSettle();
    expect(permissions.requestNotificationsCalls, 1);
    expect(find.text(Strings.permissionGranted), findsOneWidget);

    await tapPrimary(tester, Strings.next); // notifications -> ready
    expect(find.text(Strings.readyTitle), findsOneWidget);
    expect(find.text('Inggris → Indonesia'), findsOneWidget);

    await tapPrimary(tester, Strings.startApp);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect((await settings.getAll())['onboarding_done'], isTrue);

    // Next launch: straight to Home.
    await tester.pumpWidget(const SizedBox());
    await pumpHome(tester, settings: settings, permissions: permissions);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('notification step is skipped when already granted', (
    tester,
  ) async {
    await pumpHome(
      tester,
      settings: FakeSettingsChannel(),
      permissions: FakePermissionsChannel(overlay: true, notifications: true),
    );
    expect(find.text(Strings.stepOf(1, 3)), findsOneWidget);
    await tapPrimary(tester, Strings.next);
    await tapPrimary(tester, Strings.next);
    expect(find.text(Strings.readyTitle), findsOneWidget);
    expect(find.text(Strings.stepOf(3, 3)), findsOneWidget);
  });

  testWidgets('permission step content is left-aligned, not centred', (
    tester,
  ) async {
    await pumpHome(
      tester,
      settings: FakeSettingsChannel(),
      permissions: FakePermissionsChannel(overlay: true),
    );
    await tapPrimary(tester, Strings.next);
    await tapPrimary(tester, Strings.next);
    final left = tester.getTopLeft(find.text(Strings.notificationsTitle)).dx;
    expect(left, AppSpacing.screenHorizontal);
  });

  testWidgets('notification step can be postponed', (tester) async {
    await pumpHome(
      tester,
      settings: FakeSettingsChannel(),
      permissions: FakePermissionsChannel(overlay: true),
    );
    await tapPrimary(tester, Strings.next);
    await tapPrimary(tester, Strings.next);
    expect(find.text(Strings.notificationsTitle), findsOneWidget);
    await tapPrimary(tester, Strings.later);
    expect(find.text(Strings.readyTitle), findsOneWidget);
  });

  testWidgets('Start is disabled if the overlay permission is revoked', (
    tester,
  ) async {
    final permissions = FakePermissionsChannel(
      overlay: true,
      notifications: true,
    );
    await pumpHome(
      tester,
      settings: FakeSettingsChannel(),
      permissions: permissions,
    );
    await tapPrimary(tester, Strings.next);
    await tapPrimary(tester, Strings.next);
    expect(button(tester, Strings.startApp).onPressed, isNotNull);

    permissions.overlay = false;
    await resume(tester);
    expect(button(tester, Strings.startApp).onPressed, isNull);
  });

  testWidgets('back returns to the previous step', (tester) async {
    await pumpHome(
      tester,
      settings: FakeSettingsChannel(),
      permissions: FakePermissionsChannel(overlay: true, notifications: true),
    );
    await tapPrimary(tester, Strings.next);
    expect(find.text(Strings.overlayTitle), findsOneWidget);
    await tapPrimary(tester, Strings.back);
    expect(find.text(Strings.onboardingLanguageTitle), findsOneWidget);
  });

  testWidgets('no step overflows at 200% font scale', (tester) async {
    await pumpHome(
      tester,
      settings: FakeSettingsChannel(),
      permissions: FakePermissionsChannel(overlay: true),
      textScale: 2,
    );
    for (var i = 0; i < 3; i++) {
      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(PillButton).first);
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });
}
