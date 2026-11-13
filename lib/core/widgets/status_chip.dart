import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

enum StatusChipTone { neutral, success, warning, error }

/// Small pill label. Non-neutral tones also carry an icon (never color alone).
class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, this.tone = StatusChipTone.neutral});

  final String label;
  final StatusChipTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground, icon) = switch (tone) {
      StatusChipTone.neutral => (
        colors.surfaceVariant,
        colors.textPrimary,
        null,
      ),
      StatusChipTone.success => (
        colors.success.withValues(alpha: 0.14),
        colors.success,
        Icons.check_circle_rounded,
      ),
      StatusChipTone.warning => (
        colors.warning.withValues(alpha: 0.18),
        colors.textPrimary,
        Icons.error_rounded,
      ),
      StatusChipTone.error => (
        colors.errorBg,
        colors.error,
        Icons.error_rounded,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
