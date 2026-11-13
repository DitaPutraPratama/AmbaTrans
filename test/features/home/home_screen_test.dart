import 'package:ambatrans/core/platform/service_channel.dart';
import 'package:ambatrans/core/strings.dart';
import 'package:ambatrans/core/widgets/language_pair_card.dart';
import 'package:ambatrans/features/settings/presentation/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../fakes/fake_models_channel.dart';
import '../../fakes/fake_permissions_channel.dart';
import '../../fakes/fake_service_channel.dart';
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
    expect(find.text('Inggris'), findsOneWidget);
    expect(find.text('Indonesia'), findsOneWidget);
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
    expect(permissions.openOverlaySettingsCalls, 1);
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

  testWidgets('notification problem requests permission and clears', (
    tester,
  ) async {
    final permissions = FakePermissionsChannel(overlay: true);
    await pumpHome(tester, permissions: permissions);
    expect(find.text(Strings.problemNotifications), findsOneWidget);
    await tester.tap(find.text(Strings.problemNotifications));
    await tester.pumpAndSettle();
    expect(permissions.requestNotificationsCalls, 1);
    expect(find.text(Strings.problemNotifications), findsNothing);
    expect(find.text(Strings.allReady), findsOneWidget);
  });

  testWidgets('header shows the name and tagline, no greeting or gear', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.text(Strings.appName), findsOneWidget);
    expect(find.text(Strings.appTagline), findsOneWidget);
    expect(find.byIcon(Icons.settings_rounded), findsNothing);
  });

  testWidgets('language card opens settings', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byType(LanguagePairCard));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('readiness tiles are exposed to accessibility', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpHome(tester, models: FakeModelsChannel());
    expect(
      find.bySemanticsLabel(
        '${Strings.tileModels}, ${Strings.tileNeedsAction}',
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('${Strings.tileOverlay}, ${Strings.tileReady}'),
      findsOneWidget,
    );
    handle.dispose();
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
