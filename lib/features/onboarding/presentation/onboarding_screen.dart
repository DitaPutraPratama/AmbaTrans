import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/languages.dart';
import '../../../core/strings.dart';
import '../../../core/widgets/pastel_icon_tile.dart';
import '../../../core/widgets/pill_button.dart';
import '../../settings/application/settings_controller.dart';
import '../application/onboarding_controller.dart';
import 'widgets/language_step.dart';
import 'widgets/permission_step.dart';
import 'widgets/step_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // The user may have granted a permission in system settings while we were away.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(onboardingControllerProvider.notifier).refreshPermissions();
    }
  }

  Future<void> _finish() async {
    await ref.read(onboardingControllerProvider.notifier).finish();
    if (!mounted) return;
    await Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: onboarding.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SizedBox.shrink(),
          data: _content,
        ),
      ),
    );
  }

  Widget _content(OnboardingState state) {
    final controller = ref.read(onboardingControllerProvider.notifier);
    final overlayGranted = state.permissions.overlay;
    final notificationsGranted = state.permissions.notifications;

    final Widget body;
    var primaryLabel = Strings.next;
    VoidCallback? primaryAction = controller.next;
    switch (state.step) {
      case OnboardingStep.language:
        body = const LanguageStep();
      case OnboardingStep.overlay:
        body = PermissionStep(
          icon: Icons.layers_rounded,
          pastel: AppPastels.blue,
          title: Strings.overlayTitle,
          body: Strings.overlayBody,
          granted: overlayGranted,
          actionLabel: Strings.openSettings,
          onAction: controller.openOverlaySettings,
        );
        if (!overlayGranted) primaryAction = null;
      case OnboardingStep.notifications:
        body = PermissionStep(
          icon: Icons.notifications_rounded,
          pastel: AppPastels.yellow,
          title: Strings.notificationsTitle,
          body: Strings.notificationsBody,
          granted: notificationsGranted,
          actionLabel: Strings.allow,
          onAction: controller.requestNotifications,
        );
        if (!notificationsGranted) primaryLabel = Strings.later;
      case OnboardingStep.ready:
        body = _ReadySummary(state: state);
        primaryLabel = Strings.startApp;
        primaryAction = overlayGranted ? _finish : null;
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            children: [
              StepIndicator(current: state.index, total: state.steps.length),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: SingleChildScrollView(
                  child: SizedBox(width: double.infinity, child: body),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PillButton(
                label: primaryLabel,
                expand: true,
                onPressed: primaryAction,
              ),
              if (!state.isFirst)
                PillButton(
                  label: Strings.back,
                  variant: PillButtonVariant.text,
                  expand: true,
                  onPressed: controller.back,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadySummary extends ConsumerWidget {
  const _ReadySummary({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final settings = ref.watch(settingsControllerProvider).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PastelIconTile(
          icon: Icons.check_rounded,
          colors: AppPastels.green,
          size: PastelTileSize.large,
        ),
        const SizedBox(height: AppSpacing.xl),
        Semantics(
          header: true,
          child: Text(Strings.readyTitle, style: textTheme.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(Strings.readyBody, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xl),
        if (settings != null)
          Text(
            '${Languages.nameOf(settings.source)} → ${Languages.nameOf(settings.target)}',
            style: textTheme.titleMedium,
          ),
      ],
    );
  }
}
