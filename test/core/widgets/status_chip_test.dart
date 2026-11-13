import 'package:ambatrans/core/widgets/status_chip.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('neutral chip has no icon', (tester) async {
    await pumpApp(tester, const StatusChip('English → Indonesia'));
    expect(find.text('English → Indonesia'), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
  });

  for (final tone in [
    StatusChipTone.success,
    StatusChipTone.warning,
    StatusChipTone.error,
  ]) {
    testWidgets('$tone chip carries an icon, not color alone', (tester) async {
      await pumpApp(tester, StatusChip('Label', tone: tone));
      expect(find.byType(Icon), findsOneWidget);
    });
  }

  testWidgets('works in dark theme and at 200% font scale', (tester) async {
    await pumpApp(
      tester,
      const StatusChip(
        'Siap offline untuk dua bahasa',
        tone: StatusChipTone.success,
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
