import 'package:ambatrans/core/widgets/info_card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('shows title and value, and handles taps', (tester) async {
    var taps = 0;
    await pumpApp(
      tester,
      InfoCard(title: 'Dari', value: 'English', onTap: () => taps++),
    );
    expect(find.text('Dari'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    await tester.tap(find.byType(InfoCard));
    expect(taps, 1);
  });

  testWidgets('semantic label joins title and value', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(
      tester,
      InfoCard(title: 'Ke', value: 'Indonesia', onTap: () {}),
    );
    expect(find.bySemanticsLabel('Ke, Indonesia'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('long value wraps at 200% font scale', (tester) async {
    await pumpApp(
      tester,
      const InfoCard(title: 'Dari', value: 'Bahasa Indonesia Baku Panjang'),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
