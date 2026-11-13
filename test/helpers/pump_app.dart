import 'package:ambatrans/app/theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Pumps [child] inside the app theme on a phone-sized surface.
/// [textScale] simulates the system font scale (DESIGN §6: up to 2.0).
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  double textScale = 1.0,
  ThemeData? theme,
}) async {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.light,
      home: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
}
