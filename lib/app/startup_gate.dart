import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/application/onboarding_controller.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';

/// First screen: Onboarding until `onboarding_done`, then Home (docs/DESIGN.md §4).
class StartupGate extends ConsumerWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(onboardingDoneProvider)
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          // If settings cannot be read, fail open to Home rather than trapping the user.
          error: (_, _) => const HomeScreen(),
          data: (done) => done ? const HomeScreen() : const OnboardingScreen(),
        );
  }
}
