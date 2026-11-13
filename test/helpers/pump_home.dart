import 'package:ambatrans/app/app.dart';
import 'package:ambatrans/app/theme.dart';
import 'package:ambatrans/core/platform/channel_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_models_channel.dart';
import '../fakes/fake_permissions_channel.dart';
import '../fakes/fake_service_channel.dart';
import '../fakes/fake_settings_channel.dart';

/// Pumps the whole [App] (starting on Home) with fake channels.
Future<void> pumpHome(
  WidgetTester tester, {
  FakeSettingsChannel? settings,
  FakePermissionsChannel? permissions,
  FakeServiceChannel? service,
  FakeModelsChannel? models,
  double textScale = 1.0,
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsChannelProvider.overrideWithValue(
          settings ?? FakeSettingsChannel({'onboarding_done': true}),
        ),
        permissionsChannelProvider.overrideWithValue(
          permissions ??
              FakePermissionsChannel(overlay: true, notifications: true),
        ),
        serviceChannelProvider.overrideWithValue(
          service ?? FakeServiceChannel(),
        ),
        modelsChannelProvider.overrideWithValue(
          models ?? FakeModelsChannel(downloaded: {'en', 'id'}),
        ),
      ],
      child: const App(),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

/// Pumps a single [screen] inside the app theme with fake channels.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  FakeSettingsChannel? settings,
  FakeModelsChannel? models,
  FakePermissionsChannel? permissions,
  double textScale = 1.0,
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsChannelProvider.overrideWithValue(
          settings ?? FakeSettingsChannel(),
        ),
        modelsChannelProvider.overrideWithValue(
          models ?? FakeModelsChannel(downloaded: {'en', 'id'}),
        ),
        permissionsChannelProvider.overrideWithValue(
          permissions ?? FakePermissionsChannel(),
        ),
      ],
      child: MaterialApp(theme: AppTheme.light, home: screen),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}
