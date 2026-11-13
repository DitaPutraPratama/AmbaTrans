import 'package:ambatrans/core/platform/service_channel.dart';
import 'package:ambatrans/core/strings.dart';
import 'package:ambatrans/features/settings/presentation/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../fakes/fake_models_channel.dart';
import '../../fakes/fake_permissions_channel.dart';
import '../../fakes/fake_service_channel.dart';
import '../../fakes/fake_settings_channel.dart';
import '../../helpers/pump_home.dart';

void main() {
  testWidgets('shows a progress indicator while loading', (tester) async {
    await pumpHome(tester, settle: false);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('everything ready and stopped: empty problems state', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.text(Strings.statusInactive), findsOneWidget);
    expect(find.text(Strings.start), findsOneWidget);
    expect(find.text(Strings.allReady), findsOneWidget);
    expect(find.text('Inggris → Indonesia'), findsOneWidget);
  });

  testWidgets('missing overlay permission: complete-permissions flow', (
    tester,
  ) async {
    final permissions = FakePermissionsChannel(notifications: true);
    await pumpHome(tester, permissions: permissions);
    expect(find.text(Strings.completePermissions), findsOneWidget);
    expect(find.text(Strings.start), findsNothing);
    expect(find.text(Strings.problemOverlay), findsOneWidget);
    await tester.tap(find.text(Strings.completePermissions));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('start and stop update the hero', (tester) async {
    final service = FakeServiceChannel();
    await pumpHome(tester, service: service);
    await tester.tap(find.text(Strings.start));
    await tester.pumpAndSettle();
    expect(service.startCalls, 1);
    expect(find.text(Strings.statusActive), findsOneWidget);
    expect(find.text(Strings.stop), findsOneWidget);

    await tester.tap(find.text(Strings.stop));
    await tester.pumpAndSettle();
    expect(service.stopCalls, 1);
    expect(find.text(Strings.statusInactive), findsOneWidget);
    expect(find.text(Strings.problemStoppedBySystem), findsNothing);
  });

  testWidgets('system killing the service shows "Tidak aktif" and a problem', (
    tester,
  ) async {
    final service = FakeServiceChannel();
    await service.start();
    await pumpHome(tester, service: service);
    expect(find.text(Strings.statusActive), findsOneWidget);

    service.killFromSystem();
    await tester.pumpAndSettle();
    expect(find.text(Strings.statusInactive), findsOneWidget);
    expect(find.text(Strings.problemStoppedBySystem), findsOneWidget);

    await tester.tap(find.text(Strings.problemStoppedBySystem));
    await tester.pumpAndSettle();
    expect(find.text(Strings.statusActive), findsOneWidget);
    expect(find.text(Strings.problemStoppedBySystem), findsNothing);
  });

  testWidgets('start failure shows the error card and retry works', (
    tester,
  ) async {
    final service = FakeServiceChannel(
      startError: ServiceStartError.startFailed,
    );
    await pumpHome(tester, service: service);
    await tester.tap(find.text(Strings.start));
    await tester.pumpAndSettle();
    expect(find.text(Strings.startFailed), findsOneWidget);
    expect(find.text(Strings.statusInactive), findsOneWidget);

    service.startError = null;
    await tester.tap(find.text(Strings.retry));
    await tester.pumpAndSettle();
    expect(find.text(Strings.startFailed), findsNothing);
    expect(find.text(Strings.statusActive), findsOneWidget);
  });

  testWidgets('missing model is a problem and opens settings', (tester) async {
    await pumpHome(tester, models: FakeModelsChannel());
    expect(find.text(Strings.problemModels), findsOneWidget);
    await tester.tap(find.text(Strings.problemModels));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('permission problems open Settings, where they are fixed', (
    tester,
  ) async {
    final permissions = FakePermissionsChannel(overlay: true);
    await pumpHome(tester, permissions: permissions);
    expect(find.text(Strings.problemNotifications), findsOneWidget);
    await tester.tap(find.text(Strings.problemNotifications));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(permissions.requestNotificationsCalls, 0);

    await tester.tap(
      find.descendant(
        of: find
            .ancestor(
              of: find.text(Strings.notificationsTitle),
              matching: find.byType(Row),
            )
            .first,
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();
    expect(permissions.requestNotificationsCalls, 1);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text(Strings.problemNotifications), findsNothing);
    expect(find.text(Strings.allReady), findsOneWidget);
  });

  testWidgets('header shows the name, tagline and the settings button', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.text(Strings.appName), findsOneWidget);
    expect(find.text(Strings.appTagline), findsOneWidget);
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
  });

  testWidgets(
    'running without a capture session lists the capture permission',
    (tester) async {
      final permissions = FakePermissionsChannel(
        overlay: true,
        notifications: true,
      );
      await pumpHome(tester, permissions: permissions);
      expect(find.text(Strings.problemCapture), findsNothing); // not running
      await tester.tap(find.text(Strings.start));
      await tester.pumpAndSettle();
      expect(find.text(Strings.problemCapture), findsOneWidget);
      await tester.tap(find.text(Strings.problemCapture));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(permissions.requestCaptureCalls, 1);
      expect(find.text(Strings.problemCapture), findsNothing);
    },
  );

  testWidgets('languages changed in Settings show on Home after returning', (
    tester,
  ) async {
    await pumpHome(
      tester,
      settings: FakeSettingsChannel({'onboarding_done': true}),
      models: FakeModelsChannel(downloaded: {'en', 'id', 'ja'}),
    );
    expect(find.text('Inggris → Indonesia'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.targetLanguage));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jepang'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Inggris → Jepang'), findsOneWidget);
  });

  testWidgets('settings button opens settings', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('does not overflow at 200% font scale with all problems', (
    tester,
  ) async {
    await pumpHome(
      tester,
      permissions: FakePermissionsChannel(),
      models: FakeModelsChannel(),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text(Strings.problemOverlay),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
    expect(find.text(Strings.problemOverlay), findsOneWidget);
  });
}
