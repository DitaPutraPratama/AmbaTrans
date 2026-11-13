import 'package:ambatrans/app/app.dart';
import 'package:ambatrans/app/router.dart';
import 'package:ambatrans/features/home/presentation/home_screen.dart';
import 'package:ambatrans/features/onboarding/presentation/onboarding_screen.dart';
import 'package:ambatrans/features/settings/presentation/settings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<NavigatorState> pumpRouter(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    return tester.state<NavigatorState>(find.byType(Navigator));
  }

  testWidgets('starts on Home', (tester) async {
    await pumpRouter(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('navigates Home -> Settings -> back', (tester) async {
    final nav = await pumpRouter(tester);
    nav.pushNamed(AppRoutes.settings);
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    nav.pop();
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);
  });

  testWidgets('navigates Onboarding -> Home', (tester) async {
    final nav = await pumpRouter(tester);
    nav.pushReplacementNamed(AppRoutes.onboarding);
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
    nav.pushReplacementNamed(AppRoutes.home);
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  test('every route has a builder', () {
    expect(
      AppRoutes.table.keys,
      unorderedEquals([
        AppRoutes.onboarding,
        AppRoutes.home,
        AppRoutes.settings,
      ]),
    );
  });
}
