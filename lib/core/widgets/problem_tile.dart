import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import 'press_scale.dart';

/// Row in the "Perlu diperhatikan" list: warning icon, text, chevron.
class ProblemTile extends StatelessWidget {
  const ProblemTile({super.key, required this.text, this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = BorderRadius.circular(AppRadius.card);
    return Semantics(
      button: onTap != null,
      label: text,
      onTap: onTap,
      excludeSemantics: true,
      child: PressScale(
        enabled: onTap != null,
        child: Material(
          color: colors.surface,
          borderRadius: shape,
          child: InkWell(
            borderRadius: shape,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(Icons.error_rounded, color: colors.warning),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
