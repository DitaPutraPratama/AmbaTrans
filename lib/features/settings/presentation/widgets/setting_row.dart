import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/strings.dart';

/// Row for a [SettingGroup]: label on the left, value and chevron on the right.
/// [value] == null shows a grey placeholder (loading).
class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.valueColor,
  });

  final String label;
  final String? value;
  final VoidCallback? onTap;

  /// Defaults to the primary colour; warning rows pass the warning colour.
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: '$label, ${value ?? Strings.loading}',
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          // spaceBetween pins value + chevron to the right edge on every row.
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(label, style: textTheme.bodyMedium)),
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (value == null)
                      Container(
                        key: const Key('value-placeholder'),
                        width: 72,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      )
                    else
                      Flexible(
                        child: Text(
                          value!,
                          textAlign: TextAlign.end,
                          style: textTheme.labelLarge?.copyWith(
                            color: valueColor ?? colors.primary,
                          ),
                        ),
                      ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
