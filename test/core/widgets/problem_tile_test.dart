import 'package:ambatrans/core/widgets/problem_tile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('shows text and chevron, handles taps', (tester) async {
    var taps = 0;
    await pumpApp(
      tester,
      ProblemTile(
        text: 'Izin tampil di atas aplikasi lain',
        onTap: () => taps++,
      ),
    );
    expect(find.text('Izin tampil di atas aplikasi lain'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    await tester.tap(find.byType(ProblemTile));
    expect(taps, 1);
  });

  testWidgets('is announced as a button with a tap action', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, ProblemTile(text: 'Layanan mati', onTap: () {}));
    expect(
      tester.getSemantics(find.byType(ProblemTile)),
      isSemantics(label: 'Layanan mati', isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });

  testWidgets('without onTap there is no chevron', (tester) async {
    await pumpApp(tester, const ProblemTile(text: 'Layanan mati'));
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
  });

  testWidgets('long text wraps at 200% font scale', (tester) async {
    await pumpApp(
      tester,
      ProblemTile(
        text: 'Izin "Tampil di atas aplikasi lain" belum diberikan',
        onTap: () {},
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
