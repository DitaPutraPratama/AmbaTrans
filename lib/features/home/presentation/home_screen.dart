import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/languages.dart';
import '../../../core/platform/service_channel.dart';
import '../../../core/strings.dart';
import '../../../core/widgets/hero_card.dart';
import '../../../core/widgets/icon_circle_button.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/pastel_icon_tile.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_chip.dart';
import '../application/home_controller.dart';
import '../application/home_state.dart';
import 'widgets/problems_section.dart';
import 'widgets/readiness_tiles.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
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

  // Permissions may have changed in system settings while we were away.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(homeControllerProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: home.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _LoadError(
            onRetry: () => ref.read(homeControllerProvider.notifier).refresh(),
          ),
          data: (state) => _HomeContent(state: state),
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(homeControllerProvider.notifier);
    void openSettings() => Navigator.of(context).pushNamed(AppRoutes.settings);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          children: [
            _Header(onSettings: openSettings),
            const SizedBox(height: AppSpacing.xl),
            _Hero(state: state, controller: controller),
            if (state.startError == ServiceStartError.startFailed) ...[
              const SizedBox(height: AppSpacing.md),
              _StartErrorCard(onRetry: controller.start),
            ],
            const SizedBox(height: AppSpacing.xl),
            ReadinessTiles(
              state: state,
              onOverlay: controller.openOverlaySettings,
              onNotifications: controller.requestNotifications,
              onModels: openSettings,
              onAccurate: controller.openAccessibilitySettings,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InfoCard(
                    title: Strings.from,
                    value: Languages.nameOf(state.source),
                    onTap: openSettings,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: InfoCard(
                    title: Strings.to,
                    value: Languages.nameOf(state.target),
                    onTap: openSettings,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            ProblemsSection(
              state: state,
              onOverlay: controller.openOverlaySettings,
              onNotifications: controller.requestNotifications,
              onModels: openSettings,
              onStart: controller.start,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        const PastelIconTile(
          icon: Icons.translate_rounded,
          colors: AppPastels.blue,
          size: PastelTileSize.small,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Strings.greeting, style: textTheme.bodySmall),
              Semantics(
                header: true,
                child: Text(Strings.appName, style: textTheme.headlineMedium),
              ),
            ],
          ),
        ),
        IconCircleButton(
          icon: Icons.settings_rounded,
          semanticLabel: Strings.settingsTitle,
          onPressed: onSettings,
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.state, required this.controller});

  final HomeState state;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final PillButton action;
    if (!state.permissions.overlay) {
      action = PillButton(
        label: Strings.completePermissions,
        variant: PillButtonVariant.tonal,
        expand: true,
        onPressed: controller.openOverlaySettings,
      );
    } else if (state.running) {
      action = PillButton(
        label: Strings.stop,
        icon: Icons.stop_rounded,
        variant: PillButtonVariant.tonal,
        expand: true,
        onPressed: controller.stop,
      );
    } else {
      action = PillButton(
        label: Strings.start,
        icon: Icons.play_arrow_rounded,
        variant: PillButtonVariant.tonal,
        expand: true,
        loading: state.starting,
        onPressed: controller.start,
      );
    }
    return HeroCard(
      label: Strings.heroLabel,
      value: state.running ? Strings.statusActive : Strings.statusInactive,
      chip: StatusChip(
        '${Languages.nameOf(state.source)} → ${Languages.nameOf(state.target)}',
      ),
      action: action,
    );
  }
}

class _StartErrorCard extends StatelessWidget {
  const _StartErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.errorBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Strings.startFailed,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.error),
            ),
            const SizedBox(height: AppSpacing.sm),
            PillButton(
              label: Strings.retry,
              variant: PillButtonVariant.text,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: _StartErrorCard(onRetry: onRetry),
      ),
    );
  }
}
