import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';

/// White card: bold title with a switch, and a short description below.
class SwitchCard extends StatelessWidget {
  const SwitchCard({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: textTheme.labelLarge)),
                Switch(value: value, onChanged: onChanged),
              ],
            ),
            Text(description, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
