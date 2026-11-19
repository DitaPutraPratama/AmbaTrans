import 'package:ambatrans/core/widgets/press_scale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  double scale(WidgetTester tester) => tester
      .widget<ScaleTransition>(
        find.descendant(
          of: find.byType(PressScale),
          matching: find.byType(ScaleTransition),
        ),
      )
      .scale
      .value;

  testWidgets('shrinks while pressed and returns on release', (tester) async {
    await pumpApp(
      tester,
      const PressScale(child: SizedBox(width: 100, height: 50)),
    );
    expect(scale(tester), 1);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PressScale)),
    );
    await tester.pump(); // the ticker starts on this frame
    await tester.pump(const Duration(milliseconds: 100));
    expect(scale(tester), closeTo(0.96, 0.001));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(scale(tester), 1);
  });

  testWidgets('a quick tap still reaches the full press', (tester) async {
    await pumpApp(
      tester,
      const PressScale(scale: 0.8, child: SizedBox(width: 100, height: 50)),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PressScale)),
    );
    await tester.pump(); // the ticker starts on this frame
    await tester.pump(const Duration(milliseconds: 10));
    await gesture.up();
    await tester.pump(); // the continued press starts on this frame
    await tester.pump(const Duration(milliseconds: 90));
    expect(scale(tester), closeTo(0.8, 0.001));
    await tester.pumpAndSettle();
    expect(scale(tester), 1);
  });

  testWidgets('does nothing when disabled', (tester) async {
    await pumpApp(
      tester,
      const PressScale(enabled: false, child: SizedBox(width: 100, height: 50)),
    );
    expect(
      find.descendant(
        of: find.byType(PressScale),
        matching: find.byType(ScaleTransition),
      ),
      findsNothing,
    );
  });
}
