import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// Blue gradient card: label, big value, optional chip and action.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.label,
    required this.value,
    this.chip,
    this.action,
  });

  final String label;
  final String value;
  final Widget? chip;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: '$label, $value',
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.primary, colors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(AppRadius.hero),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ExcludeSemantics(
                child: Text(
                  value,
                  style: textTheme.headlineLarge?.copyWith(
                    color: colors.onPrimary,
                  ),
                ),
              ),
              if (chip != null) ...[
                const SizedBox(height: AppSpacing.md),
                chip!,
              ],
              if (action != null) ...[
                const SizedBox(height: AppSpacing.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
