import 'package:ambatrans/core/strings.dart';
import 'package:ambatrans/core/widgets/selectable_card.dart';
import 'package:ambatrans/features/settings/presentation/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../fakes/fake_models_channel.dart';
import '../../fakes/fake_permissions_channel.dart';
import '../../fakes/fake_settings_channel.dart';
import '../../helpers/pump_home.dart';

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> openEngineSheet(WidgetTester tester) =>
    tapVisible(tester, find.text(Strings.engine));

Future<void> pickEngine(WidgetTester tester, String label) =>
    tapVisible(tester, find.widgetWithText(SelectableCard, label));

Future<void> save(WidgetTester tester) =>
    tapVisible(tester, find.text(Strings.save));

TextField field(WidgetTester tester, String key) =>
    tester.widget<TextField>(find.byKey(Key(key)));

void main() {
  testWidgets('ML Kit is the default and shows the offline model card', (
    tester,
  ) async {
    await pumpScreen(tester, const SettingsScreen());
    expect(find.text('ML Kit'), findsOneWidget);
    expect(find.text(Strings.offlineModel), findsOneWidget);
  });

  testWidgets('engines are grouped offline, free and paid', (tester) async {
    await pumpScreen(tester, const SettingsScreen());
    await openEngineSheet(tester);
    for (final title in [
      Strings.groupOffline,
      Strings.groupFree,
      Strings.groupPaid,
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    expect(find.byType(SelectableCard), findsNWidgets(8));
  });

  testWidgets('DeepL needs a key; the eye shows it; no model field', (
    tester,
  ) async {
    final settings = FakeSettingsChannel();
    await pumpScreen(tester, const SettingsScreen(), settings: settings);
    await openEngineSheet(tester);
    await pickEngine(tester, 'DeepL');
    expect(find.byKey(const Key('model-field')), findsNothing);
    await save(tester);
    expect(find.text(Strings.apiKeyRequired), findsOneWidget);

    await tester.enterText(find.byKey(const Key('api-key-field')), ' k:fx ');
    expect(field(tester, 'api-key-field').obscureText, isTrue);
    await tapVisible(tester, find.byKey(const Key('toggle-key')));
    expect(field(tester, 'api-key-field').obscureText, isFalse);
    await save(tester);
    final all = await settings.getAll();
    expect(all['translate_engine'], 'deepl');
    expect(all['deepl_api_key'], 'k:fx');
    expect(find.text(Strings.offlineModel), findsNothing);
  });

  testWidgets('a saved key is locked until "Ubah" is tapped', (tester) async {
    final settings = FakeSettingsChannel({
      'translate_engine': 'groq',
      'groq_api_key': 'gsk_old',
    });
    await pumpScreen(tester, const SettingsScreen(), settings: settings);
    await openEngineSheet(tester);
    expect(field(tester, 'api-key-field').readOnly, isTrue);
    expect(field(tester, 'model-field').readOnly, isTrue);

    await tapVisible(tester, find.text(Strings.editKeyAndModel));
    expect(field(tester, 'api-key-field').readOnly, isFalse);
    await tester.enterText(find.byKey(const Key('api-key-field')), 'gsk_new');
    await tester.enterText(find.byKey(const Key('model-field')), 'my-model');
    await save(tester);
    final all = await settings.getAll();
    expect(all['groq_api_key'], 'gsk_new');
    expect(all['groq_model'], 'my-model');
  });

  testWidgets('switching engines keeps saved keys and needs no retyping', (
    tester,
  ) async {
    final settings = FakeSettingsChannel({
      'translate_engine': 'groq',
      'groq_api_key': 'gsk_1',
      'deepl_api_key': 'old-deepl',
    });
    await pumpScreen(tester, const SettingsScreen(), settings: settings);
    await openEngineSheet(tester);
    await pickEngine(tester, 'DeepL');
    expect(field(tester, 'api-key-field').controller!.text, 'old-deepl');
    await save(tester);
    final all = await settings.getAll();
    expect(all['translate_engine'], 'deepl');
    expect(all['deepl_api_key'], 'old-deepl');
    expect(all['groq_api_key'], 'gsk_1');
  });

  testWidgets('API key and model links open in the browser', (tester) async {
    final permissions = FakePermissionsChannel();
    await pumpScreen(tester, const SettingsScreen(), permissions: permissions);
    await openEngineSheet(tester);
    await pickEngine(tester, 'Groq');
    await tapVisible(tester, find.text(Strings.getApiKey));
    await tapVisible(tester, find.text(Strings.modelList));
    expect(permissions.openedUrls, [
      'https://console.groq.com/keys',
      'https://console.groq.com/docs/models',
    ]);
  });

  testWidgets('switching back to ML Kit shows the model card again', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const SettingsScreen(),
      settings: FakeSettingsChannel({
        'translate_engine': 'groq',
        'groq_api_key': 'k',
      }),
      models: FakeModelsChannel(),
    );
    expect(find.text(Strings.offlineModel), findsNothing);
    await openEngineSheet(tester);
    await pickEngine(tester, 'ML Kit');
    await save(tester);
    expect(find.text(Strings.offlineModel), findsOneWidget);
  });
}
