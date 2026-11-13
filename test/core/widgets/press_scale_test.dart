import 'package:ambatrans/core/widgets/press_scale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  double scale(WidgetTester tester) =>
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

  testWidgets('shrinks while pressed and returns on release', (tester) async {
    await pumpApp(
      tester,
      const PressScale(child: SizedBox(width: 100, height: 50)),
    );
    expect(scale(tester), 1);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PressScale)),
    );
    await tester.pump();
    expect(scale(tester), lessThan(1));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(scale(tester), 1);
  });

  testWidgets('does nothing when disabled', (tester) async {
    await pumpApp(
      tester,
      const PressScale(enabled: false, child: SizedBox(width: 100, height: 50)),
    );
    expect(find.byType(AnimatedScale), findsNothing);
  });
}
