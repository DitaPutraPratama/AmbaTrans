import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/languages.dart';
import '../../../core/strings.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/icon_circle_button.dart';
import '../../../core/widgets/section_title.dart';
import '../application/settings_controller.dart';
import 'language_picking.dart';
import 'widgets/battery_tips_card.dart';
import 'widgets/engine_info.dart';
import 'widgets/engine_sheet.dart';
import 'widgets/model_download_sheet.dart';
import 'widgets/model_status_card.dart';
import 'widgets/overlay_color_card.dart';
import 'widgets/setting_group.dart';
import 'widgets/setting_row.dart';
import 'widgets/switch_card.dart';

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
    // The controller may be cached from onboarding, before the permissions were granted.
    ref.read(settingsControllerProvider.notifier).refreshPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // The user may have changed a permission in system settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(settingsControllerProvider.notifier).refreshPermissions();
    }
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
                SettingGroup(
                  children: [
                    SettingRow(
                      label: Strings.sourceLanguage,
                      value: state == null
                          ? null
                          : Languages.nameOf(state.source),
                      onTap: state == null
                          ? null
                          : () => pickLanguage(
                              context,
                              ref,
                              LanguageSide.source,
                              state,
                            ),
                    ),
                    SettingRow(
                      label: Strings.targetLanguage,
                      value: state == null
                          ? null
                          : Languages.nameOf(state.target),
                      onTap: state == null
                          ? null
                          : () => pickLanguage(
                              context,
                              ref,
                              LanguageSide.target,
                              state,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                const SectionTitle(Strings.engineSection),
                const SizedBox(height: AppSpacing.md),
                SettingGroup(
                  children: [
                    SettingRow(
                      label: Strings.engine,
                      value: state?.engine.label,
                      onTap: state == null
                          ? null
                          : () => showEngineSheet(context),
                    ),
                  ],
                ),
                // Offline models matter only to ML Kit.
                if (state != null && !state.engine.online) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const SectionTitle(Strings.offlineModel),
                  const SizedBox(height: AppSpacing.md),
                  ModelStatusCard(
                    ready: state.models.ready,
                    onDownload: () => showModelDownloadSheet(context),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                const SectionTitle(Strings.permissionsSection),
                const SizedBox(height: AppSpacing.md),
                if (state != null) ...[
                  // The switch mirrors the system state; flipping it opens the place to change it.
                  SwitchCard(
                    title: Strings.overlayTitle,
                    description: Strings.overlayBody,
                    value: state.overlayGranted,
                    onChanged: (_) => ref
                        .read(settingsControllerProvider.notifier)
                        .openOverlaySettings(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SwitchCard(
                    title: Strings.notificationsTitle,
                    description: Strings.notificationsBody,
                    value: state.notificationsGranted,
                    onChanged: (_) => ref
                        .read(settingsControllerProvider.notifier)
                        .toggleNotifications(),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                const SectionTitle(Strings.overlayColorSection),
                const SizedBox(height: AppSpacing.md),
                if (state != null)
                  OverlayColorCard(
                    textColor: state.overlayTextColor,
                    bgColor: state.overlayBgColor,
                    bgOpacity: state.overlayBgOpacity,
                    textScale: state.overlayTextScale,
                    onChanged: ref
                        .read(settingsControllerProvider.notifier)
                        .setOverlayStyle,
                    onCommitted: () => showAppToast(
                      ScaffoldMessenger.of(context),
                      Strings.overlayStyleSaved,
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),
                const SectionTitle(Strings.advancedSection),
                const SizedBox(height: AppSpacing.md),
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
