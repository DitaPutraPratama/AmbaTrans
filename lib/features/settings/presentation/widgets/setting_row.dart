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
  });

  final String label;
  final String? value;
  final VoidCallback? onTap;

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
          child: Row(
            children: [
              Flexible(child: Text(label, style: textTheme.bodyMedium)),
              const SizedBox(width: AppSpacing.md),
              if (value == null) ...[
                const Spacer(),
                Container(
                  key: const Key('value-placeholder'),
                  width: 72,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ] else
                Expanded(
                  child: Text(
                    value!,
                    textAlign: TextAlign.end,
                    style: textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ),
              Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
