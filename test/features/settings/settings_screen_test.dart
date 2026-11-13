import 'package:ambatrans/core/platform/channel_providers.dart';
import 'package:ambatrans/core/platform/settings_channel.dart';
import 'package:ambatrans/core/strings.dart';
import 'package:ambatrans/core/widgets/selectable_card.dart';
import 'package:ambatrans/features/settings/application/settings_controller.dart';
import 'package:ambatrans/features/settings/presentation/settings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../fakes/fake_models_channel.dart';
import '../../fakes/fake_permissions_channel.dart';
import '../../fakes/fake_settings_channel.dart';
import '../../helpers/pump_home.dart';

Future<void> openSourceSheet(WidgetTester tester) async {
  await tester.tap(find.text(Strings.sourceLanguage));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows placeholders while loading, then the saved languages', (
    tester,
  ) async {
    await pumpScreen(tester, const SettingsScreen(), settle: false);
    expect(find.byKey(const Key('value-placeholder')), findsNWidgets(2));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('value-placeholder')), findsNothing);
    expect(find.text('Inggris'), findsOneWidget);
    expect(find.text('Indonesia'), findsOneWidget);
    expect(find.text(Strings.readyOffline), findsOneWidget);
  });

  testWidgets('source sheet lists languages; the other side is disabled', (
    tester,
  ) async {
    await pumpScreen(tester, const SettingsScreen());
    await openSourceSheet(tester);
    expect(find.text(Strings.sourceSheetSubtitle), findsOneWidget);
    expect(find.byType(SelectableCard), findsNWidgets(4)); // fake: en id ja fr
    expect(find.text(Strings.alreadyChosenAsTarget), findsOneWidget);
    final cards = tester
        .widgetList<SelectableCard>(find.byType(SelectableCard))
        .toList();
    expect(cards.firstWhere((c) => c.title == 'Indonesia').enabled, isFalse);
    expect(cards.firstWhere((c) => c.title == 'Inggris').selected, isTrue);
  });

  testWidgets(
    'source sheet hides languages OCR cannot read; target keeps them',
    (tester) async {
      final models = FakeModelsChannel(
        downloaded: {'en', 'id'},
        languages: ['en', 'id', 'ru', 'ja'],
        unsupportedSources: {'ru'},
      );
      await pumpScreen(tester, const SettingsScreen(), models: models);
      await openSourceSheet(tester);
      expect(find.text('Rusia'), findsNothing);
      expect(find.text('Jepang'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text(Strings.targetLanguage));
      await tester.pumpAndSettle();
      expect(find.text('Rusia'), findsOneWidget);
    },
  );

  testWidgets('search filters the list and shows an empty state', (
    tester,
  ) async {
    await pumpScreen(tester, const SettingsScreen());
    await openSourceSheet(tester);
    await tester.enterText(find.byType(TextField), 'jep');
    await tester.pumpAndSettle();
    expect(find.byType(SelectableCard), findsOneWidget);
    expect(find.text('Jepang'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text(Strings.languageNotFound), findsOneWidget);
  });

  testWidgets('choosing a language saves it and updates model status', (
    tester,
  ) async {
    final settings = FakeSettingsChannel();
    await pumpScreen(tester, const SettingsScreen(), settings: settings);
    await openSourceSheet(tester);
    await tester.tap(find.text('Jepang'));
    await tester.pumpAndSettle();
    expect((await settings.getAll())['source_lang'], 'ja');
    expect(find.text('Jepang'), findsOneWidget);
    expect(find.text(Strings.notDownloaded), findsOneWidget);
  });

  testWidgets('target sheet disables the source language', (tester) async {
    await pumpScreen(tester, const SettingsScreen());
    await tester.tap(find.text(Strings.targetLanguage));
    await tester.pumpAndSettle();
    expect(find.text(Strings.alreadyChosenAsSource), findsOneWidget);
    final cards = tester
        .widgetList<SelectableCard>(find.byType(SelectableCard))
        .toList();
    expect(cards.firstWhere((c) => c.title == 'Inggris').enabled, isFalse);
  });

  testWidgets('selection persists across a rebuild of the app', (tester) async {
    final settings = FakeSettingsChannel();
    await pumpScreen(tester, const SettingsScreen(), settings: settings);
    await openSourceSheet(tester);
    await tester.tap(find.text('Prancis'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    await pumpScreen(tester, const SettingsScreen(), settings: settings);
    expect(find.text('Prancis'), findsOneWidget);
  });

  testWidgets('back button leaves the screen', (tester) async {
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
          ),
          child: const Text('buka'),
        ),
      ),
    );
    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsNothing);
  });

  testWidgets('does not overflow at 200% font scale with the sheet open', (
    tester,
  ) async {
    await pumpScreen(tester, const SettingsScreen(), textScale: 2);
    await openSourceSheet(tester);
    expect(tester.takeException(), isNull);
  });

  group('SettingsController', () {
    ProviderContainer container(FakeSettingsChannel settings) {
      final c = ProviderContainer(
        overrides: [
          settingsChannelProvider.overrideWithValue(settings),
          modelsChannelProvider.overrideWithValue(
            FakeModelsChannel(downloaded: {'en', 'id'}),
          ),
          permissionsChannelProvider.overrideWithValue(
            FakePermissionsChannel(),
          ),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('rejects source equal to target and keeps the old value', () async {
      final c = container(FakeSettingsChannel());
      await c.read(settingsControllerProvider.future);
      final notifier = c.read(settingsControllerProvider.notifier);
      await expectLater(
        notifier.setLanguage(LanguageSide.source, 'id'),
        throwsA(isA<InvalidValueException>()),
      );
      expect(c.read(settingsControllerProvider).requireValue.source, 'en');
    });

    test('supportedLanguagesProvider sorts by Indonesian name', () async {
      final c = container(FakeSettingsChannel());
      final codes = await c.read(supportedLanguagesProvider.future);
      // Indonesia, Inggris, Jepang, Prancis
      expect(codes, ['id', 'en', 'ja', 'fr']);
    });
  });
}
