import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/languages.dart';
import '../../../core/strings.dart';
import '../../../core/widgets/icon_circle_button.dart';
import '../../../core/widgets/section_title.dart';
import '../application/settings_controller.dart';
import 'language_picking.dart';
import 'widgets/model_download_sheet.dart';
import 'widgets/model_status_card.dart';
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
