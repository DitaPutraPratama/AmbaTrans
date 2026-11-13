import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/strings.dart';

/// "Mode akurat" switch with a short description.
class AccurateModeCard extends StatelessWidget {
  const AccurateModeCard({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    Strings.accurateMode,
                    style: textTheme.labelLarge,
                  ),
                ),
                Switch(value: enabled, onChanged: onChanged),
              ],
            ),
            Text(Strings.accurateModeDescription, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
