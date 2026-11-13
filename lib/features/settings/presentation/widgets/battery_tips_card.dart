import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/strings.dart';
import '../../../../core/widgets/pill_button.dart';

/// "Agar bubble tidak mati": help text and a link to battery settings.
class BatteryTipsCard extends StatelessWidget {
  const BatteryTipsCard({super.key, required this.onOpenBatterySettings});

  final VoidCallback onOpenBatterySettings;

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
            Semantics(
              header: true,
              child: Text(Strings.tipsTitle, style: textTheme.labelLarge),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(Strings.tipsBody, style: textTheme.bodySmall),
            const SizedBox(height: AppSpacing.md),
            PillButton(
              label: Strings.tipsAction,
              icon: Icons.battery_saver_rounded,
              variant: PillButtonVariant.text,
              onPressed: onOpenBatterySettings,
            ),
          ],
        ),
      ),
    );
  }
}
