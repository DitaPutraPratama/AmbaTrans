import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/languages.dart';
import '../../../core/strings.dart';
import '../../../core/widgets/icon_circle_button.dart';
import '../../../core/widgets/section_title.dart';
import '../application/settings_controller.dart';
import 'language_picking.dart';
import 'widgets/accurate_mode_card.dart';
import 'widgets/battery_tips_card.dart';
import 'widgets/accurate_mode_sheet.dart';
import 'widgets/model_download_sheet.dart';
import 'widgets/model_status_card.dart';
import 'widgets/setting_row.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
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

  // The user may have toggled the Accessibility service in system settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(settingsControllerProvider.notifier).refreshAccessibility();
    }
  }

  Future<void> _toggleAccurate(bool enable) async {
    final controller = ref.read(settingsControllerProvider.notifier);
    if (!enable) {
      await controller.setAccessibilityMode(false);
      return;
    }
    // Explain first (S-06), then save the choice and open system settings.
    if (!await showAccurateModeSheet(context)) return;
    await controller.setAccessibilityMode(true);
    await controller.openAccessibilitySettings();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final state = settings.value;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              children: [
                const _Header(),
                const SizedBox(height: AppSpacing.xl),
                const SectionTitle(Strings.languageSection),
                const SizedBox(height: AppSpacing.md),
                SettingRow(
                  label: Strings.sourceLanguage,
                  value: state == null ? null : Languages.nameOf(state.source),
                  onTap: state == null
                      ? null
                      : () => pickLanguage(
                          context,
                          ref,
                          LanguageSide.source,
                          state,
                        ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SettingRow(
                  label: Strings.targetLanguage,
                  value: state == null ? null : Languages.nameOf(state.target),
                  onTap: state == null
                      ? null
                      : () => pickLanguage(
                          context,
                          ref,
                          LanguageSide.target,
                          state,
                        ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const SectionTitle(Strings.offlineModel),
                const SizedBox(height: AppSpacing.md),
                if (state != null)
                  ModelStatusCard(
                    ready: state.models.ready,
                    onDownload: () => showModelDownloadSheet(context),
                  ),
                const SizedBox(height: AppSpacing.xl),
                if (state != null)
                  AccurateModeCard(
                    enabled: state.accessibilityMode,
                    enabledInSystem: state.accessibilityEnabledInSystem,
                    onChanged: _toggleAccurate,
                    onOpenSystemSettings: ref
                        .read(settingsControllerProvider.notifier)
                        .openAccessibilitySettings,
                  ),
                const SizedBox(height: AppSpacing.xl),
                BatteryTipsCard(
                  onOpenBatterySettings: ref
                      .read(settingsControllerProvider.notifier)
                      .openBatterySettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconCircleButton(
          icon: Icons.arrow_back_rounded,
          semanticLabel: Strings.back,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              Strings.settingsTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
      ],
    );
  }
}
