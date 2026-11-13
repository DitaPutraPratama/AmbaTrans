import 'package:ambatrans/app/app.dart';
import 'package:ambatrans/app/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('App builds with the custom theme', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    final context = tester.element(find.byType(Scaffold));
    final theme = Theme.of(context);
    expect(theme.extension<AppColors>(), isNotNull);
    expect(theme.textTheme.headlineLarge?.fontSize, 36);
    expect(theme.textTheme.bodyMedium?.fontFamily, AppTheme.fontFamily);
  });
}
