import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/languages.dart';
import '../../../../core/strings.dart';
import '../../../../core/widgets/selectable_card.dart';
import '../../../settings/application/settings_controller.dart';
import '../../../settings/presentation/language_picking.dart';

/// Step 1: two cards, "Dari" and "Ke", each opening the language sheet.
class LanguageStep extends ConsumerWidget {
  const LanguageStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider).value;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            Strings.onboardingLanguageTitle,
            style: textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(Strings.onboardingLanguageBody, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xl),
        if (settings != null) ...[
          SelectableCard(
            title: Strings.from,
            subtitle: Languages.nameOf(settings.source),
            selected: true,
            onTap: () =>
                pickLanguage(context, ref, LanguageSide.source, settings),
          ),
          const SizedBox(height: AppSpacing.md),
          SelectableCard(
            title: Strings.to,
            subtitle: Languages.nameOf(settings.target),
            selected: true,
            onTap: () =>
                pickLanguage(context, ref, LanguageSide.target, settings),
          ),
        ] else
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
