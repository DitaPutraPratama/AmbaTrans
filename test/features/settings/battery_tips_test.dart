import 'package:ambatrans/core/strings.dart';
import 'package:ambatrans/features/settings/presentation/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../fakes/fake_permissions_channel.dart';
import '../../helpers/pump_home.dart';

Future<void> scrollToTips(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text(Strings.tipsAction),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(find.text(Strings.tipsAction));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the tips and opens battery settings', (tester) async {
    final permissions = FakePermissionsChannel();
    await pumpScreen(tester, const SettingsScreen(), permissions: permissions);
    await scrollToTips(tester);
    expect(find.text(Strings.tipsTitle), findsOneWidget);
    expect(find.text(Strings.tipsBody), findsOneWidget);
    await tester.tap(find.text(Strings.tipsAction));
    expect(permissions.openBatterySettingsCalls, 1);
  });

  testWidgets('does not overflow at 200% font scale', (tester) async {
    await pumpScreen(tester, const SettingsScreen(), textScale: 2);
    await scrollToTips(tester);
    expect(tester.takeException(), isNull);
  });
}
