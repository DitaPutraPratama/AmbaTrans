import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// White card with a small title and a value ("Dari" / "Ke" language cards).
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: onTap != null,
      label: '$title, $value',
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(value, style: textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
