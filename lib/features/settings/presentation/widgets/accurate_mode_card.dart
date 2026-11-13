import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/strings.dart';

/// "Mode akurat" switch with a description and, when needed, a hint to enable the system service.
class AccurateModeCard extends StatelessWidget {
  const AccurateModeCard({
    super.key,
    required this.enabled,
    required this.enabledInSystem,
    required this.onChanged,
    required this.onOpenSystemSettings,
  });

  final bool enabled;
  final bool enabledInSystem;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpenSystemSettings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final needsSystem = enabled && !enabledInSystem;
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
            if (needsSystem) ...[
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: onOpenSystemSettings,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Text(
                    Strings.accurateModeNeedsSystem,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
