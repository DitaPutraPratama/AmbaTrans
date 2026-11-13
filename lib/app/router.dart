import 'package:material_ui/material_ui.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const settings = '/settings';

  static final Map<String, WidgetBuilder> table = {
    onboarding: (_) => const OnboardingScreen(),
    home: (_) => const HomeScreen(),
    settings: (_) => const SettingsScreen(),
  };
}
