import 'package:ambatrans/app/theme.dart';
import 'package:ambatrans/core/widgets/selectable_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

Material _material(WidgetTester tester) => tester.widget<Material>(
  find.descendant(
    of: find.byType(SelectableCard),
    matching: find.byType(Material),
  ),
);

void main() {
  testWidgets('unselected: outline border, surface background', (tester) async {
    await pumpApp(tester, SelectableCard(title: 'English', onTap: () {}));
    final material = _material(tester);
    final shape = material.shape! as RoundedRectangleBorder;
    expect(material.color, AppColors.light.surface);
    expect(shape.side.color, AppColors.light.outline);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
  });

  testWidgets('selected: primary border, selectedBg, check icon', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const SelectableCard(title: 'English', selected: true),
    );
    final material = _material(tester);
    final shape = material.shape! as RoundedRectangleBorder;
    expect(material.color, AppColors.light.selectedBg);
    expect(shape.side.color, AppColors.light.primary);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('disabled ignores taps and shows its subtitle', (tester) async {
    var taps = 0;
    await pumpApp(
      tester,
      SelectableCard(
        title: 'Indonesia',
        subtitle: 'Sudah dipilih sebagai bahasa tujuan',
        enabled: false,
        onTap: () => taps++,
      ),
    );
    await tester.tap(find.byType(SelectableCard), warnIfMissed: false);
    expect(taps, 0);
    expect(find.text('Sudah dipilih sebagai bahasa tujuan'), findsOneWidget);
  });

  testWidgets('enabled card handles taps; semantics expose selected', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await pumpApp(
      tester,
      SelectableCard(title: 'Jepang', selected: true, onTap: () => taps++),
    );
    await tester.tap(find.byType(SelectableCard));
    expect(taps, 1);
    expect(
      tester.getSemantics(find.byType(SelectableCard)),
      isSemantics(
        label: 'Jepang',
        isButton: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('long text wraps at 200% font scale', (tester) async {
    await pumpApp(
      tester,
      const SelectableCard(
        title: 'Bahasa dengan nama yang sangat panjang sekali',
        subtitle: 'Keterangan tambahan yang juga panjang',
        selected: true,
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
