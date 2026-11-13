import 'package:ambatrans/app/theme.dart';
import 'package:ambatrans/features/home/presentation/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_home.dart';

void main() {
  testWidgets('App builds with the custom theme', (tester) async {
    await pumpHome(tester);
    final context = tester.element(find.byType(HomeScreen));
    final theme = Theme.of(context);
    expect(theme.extension<AppColors>(), isNotNull);
    expect(theme.textTheme.headlineLarge?.fontSize, 36);
    expect(theme.textTheme.bodyMedium?.fontFamily, AppTheme.fontFamily);
  });
}
