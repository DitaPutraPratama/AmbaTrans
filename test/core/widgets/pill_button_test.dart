import 'package:ambatrans/core/widgets/pill_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  for (final variant in PillButtonVariant.values) {
    testWidgets('$variant renders and handles taps', (tester) async {
      var taps = 0;
      await pumpApp(
        tester,
        PillButton(label: 'Mulai', variant: variant, onPressed: () => taps++),
      );
      await tester.tap(find.text('Mulai'));
      expect(taps, 1);
    });
  }

  testWidgets('loading shows a spinner and ignores taps', (tester) async {
    var taps = 0;
    await pumpApp(
      tester,
      PillButton(label: 'Unduh', loading: true, onPressed: () => taps++),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Unduh'), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('disabled when onPressed is null', (tester) async {
    await pumpApp(tester, const PillButton(label: 'Mulai', onPressed: null));
    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('long label wraps at 200% font scale', (tester) async {
    await pumpApp(
      tester,
      const PillButton(
        label: 'Mulai AmbaTrans sekarang juga',
        icon: Icons.play_arrow_rounded,
        expand: true,
        onPressed: null,
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
