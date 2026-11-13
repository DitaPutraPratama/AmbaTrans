import 'package:ambatrans/core/widgets/indeterminate_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('the segment keeps moving', (tester) async {
    await pumpApp(tester, const IndeterminateBar());
    double segmentLeft() => tester
        .getTopLeft(
          find.descendant(
            of: find.byType(IndeterminateBar),
            matching: find.byType(FractionallySizedBox),
          ),
        )
        .dx;
    final segment = find.descendant(
      of: find.byType(IndeterminateBar),
      matching: find.byType(FractionallySizedBox),
    );
    expect(
      tester.getSize(segment).height,
      greaterThan(0),
    ); // visible, not collapsed
    final first = segmentLeft();
    await tester.pump(const Duration(milliseconds: 450));
    final second = segmentLeft();
    await tester.pump(const Duration(milliseconds: 450));
    expect(second, isNot(first));
    expect(segmentLeft(), isNot(second));
  });
}
