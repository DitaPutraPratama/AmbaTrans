import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/languages.dart';
import '../../../core/platform/settings_channel.dart';
import '../../../core/strings.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/icon_circle_button.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/status_chip.dart';
import '../application/settings_controller.dart';
import 'widgets/language_picker_sheet.dart';
import 'widgets/setting_row.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      : () => _pick(context, ref, LanguageSide.source, state),
                ),
                const SizedBox(height: AppSpacing.sm),
                SettingRow(
                  label: Strings.targetLanguage,
                  value: state == null ? null : Languages.nameOf(state.target),
                  onTap: state == null
                      ? null
                      : () => _pick(context, ref, LanguageSide.target, state),
                ),
                const SizedBox(height: AppSpacing.xl),
                const SectionTitle(Strings.offlineModel),
                const SizedBox(height: AppSpacing.md),
                if (state != null) _ModelCard(ready: state.models.ready),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    LanguageSide side,
    SettingsState state,
  ) async {
    final isSource = side == LanguageSide.source;
    final code = await showAppBottomSheet<String>(
      context: context,
      builder: (_) => LanguagePickerSheet(
        side: side,
        selected: isSource ? state.source : state.target,
        other: isSource ? state.target : state.source,
      ),
    );
    if (code == null) return;
    try {
      await ref
          .read(settingsControllerProvider.notifier)
          .setLanguage(side, code);
    } on InvalidValueException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(Strings.sameLanguage)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Strings.settingsSaveFailed)));
    }
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

class _ModelCard extends StatelessWidget {
  const _ModelCard({required this.ready});

  final bool ready;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Text(
                Strings.offlineModel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Flexible: at large font scales the chip text wraps instead of overflowing.
            Flexible(
              child: StatusChip(
                ready ? Strings.readyOffline : Strings.notDownloaded,
                tone: ready ? StatusChipTone.success : StatusChipTone.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
