import 'dart:async';

import 'package:ambatrans/core/strings.dart';
import 'package:ambatrans/core/widgets/icon_circle_button.dart';
import 'package:ambatrans/core/widgets/indeterminate_bar.dart';
import 'package:ambatrans/features/onboarding/presentation/onboarding_screen.dart';
import 'package:ambatrans/features/settings/presentation/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../fakes/fake_models_channel.dart';
import '../../fakes/fake_permissions_channel.dart';
import '../../fakes/fake_settings_channel.dart';
import '../../helpers/pump_home.dart';

const _idleBody = 'Inggris dan Indonesia, ±60 MB.';

Future<void> openSheet(WidgetTester tester) async {
  await tester.tap(find.text(Strings.download));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('missing models: status, button and confirmation sheet', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const SettingsScreen(),
      models: FakeModelsChannel(),
    );
    expect(find.text(Strings.notDownloaded), findsOneWidget);
    await openSheet(tester);
    expect(find.text(Strings.downloadModelTitle), findsOneWidget);
    expect(find.text(_idleBody), findsOneWidget);
    expect(find.text(Strings.later), findsOneWidget);
  });

  testWidgets(
    'shows progress, then success, closes itself and updates status',
    (tester) async {
      final gate = Completer<void>();
      final models = FakeModelsChannel(downloadGate: gate);
      await pumpScreen(tester, const SettingsScreen(), models: models);
      await openSheet(tester);

      await tester.tap(find.widgetWithText(TextButton, Strings.download).last);
      await tester.pump();
      expect(find.text(Strings.downloading(0)), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text(Strings.downloading(2)), findsOneWidget);
      expect(find.byType(IndeterminateBar), findsOneWidget);
      expect(find.text(Strings.later), findsNothing);
      final close = tester
          .widgetList<IconCircleButton>(find.byType(IconCircleButton))
          .last; // the sheet's close button, above the Settings back button
      expect(close.onPressed, isNull);

      gate.complete();
      await tester.pump();
      await tester.pump();
      expect(find.text(Strings.readyOffline), findsWidgets);
      expect(models.downloaded, containsAll(['en', 'id']));

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text(Strings.downloadModelTitle), findsNothing);
      expect(
        find.text(Strings.readyOffline),
        findsOneWidget,
      ); // chip in Settings
      expect(find.text(Strings.download), findsNothing);
    },
  );

  testWidgets('failure shows an error and retry can succeed', (tester) async {
    final models = FakeModelsChannel(failDownload: true);
    await pumpScreen(tester, const SettingsScreen(), models: models);
    await openSheet(tester);
    await tester.tap(find.widgetWithText(TextButton, Strings.download).last);
    await tester.pumpAndSettle();
    expect(find.text(Strings.downloadFailed), findsOneWidget);
    expect(find.text(Strings.retry), findsOneWidget);
    expect(models.downloaded, isEmpty);

    models.failDownload = false;
    await tester.tap(find.text(Strings.retry));
    await tester.pump();
    await tester.pump();
    expect(find.text(Strings.downloadFailed), findsNothing);
    expect(models.downloaded, containsAll(['en', 'id']));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('"Nanti saja" closes the sheet without downloading', (
    tester,
  ) async {
    final models = FakeModelsChannel();
    await pumpScreen(tester, const SettingsScreen(), models: models);
    await openSheet(tester);
    await tester.tap(find.text(Strings.later));
    await tester.pumpAndSettle();
    expect(find.text(Strings.downloadModelTitle), findsNothing);
    expect(models.downloadCalls, 0);
  });

  testWidgets('choosing a language without models offers the download', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const SettingsScreen(),
      models: FakeModelsChannel(downloaded: {'en', 'id'}),
    );
    await tester.tap(find.text(Strings.sourceLanguage));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jepang'));
    await tester.pumpAndSettle();
    expect(find.text(Strings.downloadModelTitle), findsOneWidget);
    expect(find.text('Jepang, ±30 MB.'), findsOneWidget);
  });

  testWidgets('onboarding downloads the default pair', (tester) async {
    final models = FakeModelsChannel();
    await pumpHome(
      tester,
      settings: FakeSettingsChannel(),
      permissions: FakePermissionsChannel(),
      models: models,
    );
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text(Strings.notDownloaded), findsOneWidget);
    await openSheet(tester);
    await tester.tap(find.widgetWithText(TextButton, Strings.download).last);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(models.downloaded, containsAll(['en', 'id']));
    expect(find.text(Strings.readyOffline), findsOneWidget);
  });

  testWidgets('sheet states do not overflow at 200% font scale', (
    tester,
  ) async {
    final models = FakeModelsChannel(failDownload: true);
    await pumpScreen(
      tester,
      const SettingsScreen(),
      models: models,
      textScale: 2,
    );
    await tester.scrollUntilVisible(
      find.text(Strings.download),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text(Strings.download));
    await tester.pumpAndSettle();
    await openSheet(tester);
    expect(find.text(Strings.downloadModelTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.widgetWithText(TextButton, Strings.download).last);
    await tester.pumpAndSettle();
    expect(find.text(Strings.downloadFailed), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
