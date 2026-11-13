import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/platform/settings_channel.dart';
import '../../../core/strings.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../application/settings_controller.dart';
import 'widgets/language_picker_sheet.dart';

/// Opens the language sheet for [side] and saves the choice; shows a snackbar on failure.
Future<void> pickLanguage(
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
    await ref.read(settingsControllerProvider.notifier).setLanguage(side, code);
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
