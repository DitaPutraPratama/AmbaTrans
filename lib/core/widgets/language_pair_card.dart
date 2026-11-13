import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../strings.dart';
import 'press_scale.dart';

/// One white card showing "Dari" source, an arrow, then "Ke" target; tapping opens settings.
class LanguagePairCard extends StatelessWidget {
  const LanguagePairCard({
    super.key,
    required this.source,
    required this.target,
    this.onTap,
  });

  final String source;
  final String target;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final shape = BorderRadius.circular(AppRadius.card);
    return Semantics(
      button: onTap != null,
      label: '${Strings.from} $source, ${Strings.to} $target',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _Side(Strings.from, source, textTheme)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: colors.textSecondary,
                    ),
                  ),
                  Expanded(child: _Side(Strings.to, target, textTheme)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side(this.title, this.value, this.textTheme);

  final String title;
  final String value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: textTheme.bodySmall),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: textTheme.titleMedium),
      ],
    );
  }
}
