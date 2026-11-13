import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/strings.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/pill_button.dart';

/// S-06: explanation shown before sending the user to system Accessibility settings.
/// Resolves to true when the user chooses "Lanjutkan".
Future<bool> showAccurateModeSheet(BuildContext context) async {
  final proceed = await showAppBottomSheet<bool>(
    context: context,
    builder: (sheetContext) => AppBottomSheet(
      icon: Icons.accessibility_new_rounded,
      iconColors: AppPastels.purple,
      title: Strings.accurateSheetTitle,
      closeLabel: Strings.close,
      actions: [
        PillButton(
          label: Strings.proceed,
          expand: true,
          onPressed: () => Navigator.of(sheetContext).pop(true),
        ),
        PillButton(
          label: Strings.cancel,
          variant: PillButtonVariant.text,
          expand: true,
          onPressed: () => Navigator.of(sheetContext).pop(false),
        ),
      ],
      child: Text(
        Strings.accurateSheetBody,
        style: Theme.of(sheetContext).textTheme.bodyMedium,
      ),
    ),
  );
  return proceed ?? false;
}
