import 'package:ambatrans/core/strings.dart';
import 'package:ambatrans/features/settings/presentation/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../fakes/fake_models_channel.dart';
import '../../fakes/fake_settings_channel.dart';
import '../../helpers/pump_home.dart';

Future<void> openEngineSheet(WidgetTester tester) async {
  await tester.ensureVisible(find.text(Strings.engine));
  await tester.tap(find.text(Strings.engine));
  await tester.pumpAndSettle();
}

Future<void> save(WidgetTester tester) async {
  await tester.tap(find.text(Strings.save));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('ML Kit is the default and shows the offline model card', (
    tester,
  ) async {
    await pumpScreen(tester, const SettingsScreen());
    expect(find.text(Strings.engineMlkit), findsOneWidget);
    expect(find.text(Strings.offlineModel), findsOneWidget);
  });

  testWidgets('DeepL needs an API key before it can be saved', (tester) async {
    final settings = FakeSettingsChannel();
    await pumpScreen(tester, const SettingsScreen(), settings: settings);
    await openEngineSheet(tester);
    await tester.tap(find.text(Strings.engineDeepl));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('model-field')), findsNothing);
    await save(tester);
    expect(find.text(Strings.apiKeyRequired), findsOneWidget);

    await tester.enterText(find.byKey(const Key('api-key-field')), ' k:fx ');
    await save(tester);
    final all = await settings.getAll();
    expect(all['translate_engine'], 'deepl');
    expect(all['deepl_api_key'], 'k:fx');
    expect(find.text(Strings.engineDeepl), findsOneWidget);
    expect(find.text(Strings.offlineModel), findsNothing);
  });

  testWidgets('AI engine saves key and model; keys survive switching', (
    tester,
  ) async {
    final settings = FakeSettingsChannel({'deepl_api_key': 'old-deepl'});
    await pumpScreen(tester, const SettingsScreen(), settings: settings);
    await openEngineSheet(tester);
    await tester.tap(find.text(Strings.engineGroq));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('api-key-field')), 'gsk_1');
    await tester.enterText(find.byKey(const Key('model-field')), 'my-model');
    await save(tester);
    var all = await settings.getAll();
    expect(all['translate_engine'], 'groq');
    expect(all['groq_api_key'], 'gsk_1');
    expect(all['groq_model'], 'my-model');

    await openEngineSheet(tester);
    await tester.tap(find.text(Strings.engineDeepl));
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(
      find.byKey(const Key('api-key-field')),
    );
    expect(field.controller!.text, 'old-deepl');
    await save(tester);
    all = await settings.getAll();
    expect(all['translate_engine'], 'deepl');
    expect(all['groq_api_key'], 'gsk_1');
  });

  testWidgets('switching back to ML Kit shows the model card again', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const SettingsScreen(),
      settings: FakeSettingsChannel({'translate_engine': 'groq'}),
      models: FakeModelsChannel(),
    );
    expect(find.text(Strings.offlineModel), findsNothing);
    await openEngineSheet(tester);
    await tester.tap(find.text(Strings.engineMlkit));
    await tester.pumpAndSettle();
    await save(tester);
    expect(find.text(Strings.offlineModel), findsOneWidget);
    expect(find.text(Strings.download), findsOneWidget);
  });
}
