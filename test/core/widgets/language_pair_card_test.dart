import 'package:ambatrans/core/widgets/language_pair_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('shows both languages in one card and handles taps', (
    tester,
  ) async {
    var taps = 0;
    await pumpApp(
      tester,
      LanguagePairCard(
        source: 'Inggris',
        target: 'Indonesia',
        onTap: () => taps++,
      ),
    );
    expect(find.text('Dari'), findsOneWidget);
    expect(find.text('Ke'), findsOneWidget);
    expect(find.text('Inggris'), findsOneWidget);
    expect(find.text('Indonesia'), findsOneWidget);
    await tester.tap(find.byType(LanguagePairCard));
    expect(taps, 1);
  });

  testWidgets('semantic label reads the whole pair as one button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpApp(
      tester,
      LanguagePairCard(source: 'Inggris', target: 'Indonesia', onTap: () {}),
    );
    expect(
      tester.getSemantics(find.byType(LanguagePairCard)),
      isSemantics(
        label: 'Dari Inggris, Ke Indonesia',
        isButton: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('shrinks while pressed and returns on release', (tester) async {
    await pumpApp(
      tester,
      LanguagePairCard(source: 'Inggris', target: 'Indonesia', onTap: () {}),
    );
    double scale() => tester
        .widget<AnimatedScale>(
          find.descendant(
            of: find.byType(LanguagePairCard),
            matching: find.byType(AnimatedScale),
          ),
        )
        .scale;
    expect(scale(), 1);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(LanguagePairCard)),
    );
    await tester.pump();
    expect(scale(), lessThan(1));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(scale(), 1);
  });

  testWidgets('long names do not overflow at 200% font scale', (tester) async {
    await pumpApp(
      tester,
      const LanguagePairCard(
        source: 'Bahasa Indonesia Baku Panjang',
        target: 'Bahasa Inggris Britania Raya',
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
