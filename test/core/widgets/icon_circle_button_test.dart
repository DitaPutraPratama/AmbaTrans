import 'package:ambatrans/core/widgets/icon_circle_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('calls onPressed and exposes a semantic label', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await pumpApp(
      tester,
      IconCircleButton(
        icon: Icons.settings_rounded,
        semanticLabel: 'Pengaturan',
        onPressed: () => taps++,
      ),
    );
    expect(
      tester.getSemantics(find.byType(IconCircleButton)),
      isSemantics(label: 'Pengaturan', isButton: true, hasTapAction: true),
    );
    await tester.tap(find.byType(IconCircleButton));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('touch target is at least 48 dp', (tester) async {
    await pumpApp(
      tester,
      IconCircleButton(
        icon: Icons.close_rounded,
        semanticLabel: 'Tutup',
        onPressed: () {},
      ),
    );
    final size = tester.getSize(find.byType(IconCircleButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });
}
