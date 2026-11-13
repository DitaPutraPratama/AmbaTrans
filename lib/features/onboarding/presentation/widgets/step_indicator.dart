import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/strings.dart';

/// Segmented progress bar with a "Langkah n dari N" caption.
class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.current, required this.total});

  /// Zero-based index of the current step.
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: Strings.stepOf(current + 1, total),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < total; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: i <= current
                          ? colors.primary
                          : colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const SizedBox(height: 6),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            Strings.stepOf(current + 1, total),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
