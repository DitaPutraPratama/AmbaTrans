import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/strings.dart';
import '../../../../core/widgets/pastel_icon_tile.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../../core/widgets/status_chip.dart';

/// Shared layout of the overlay and notification steps: big tile, text, action.
class PermissionStep extends StatelessWidget {
  const PermissionStep({
    super.key,
    required this.icon,
    required this.pastel,
    required this.title,
    required this.body,
    required this.granted,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final PastelColors pastel;
  final String title;
  final String body;
  final bool granted;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PastelIconTile(
          icon: icon,
          colors: pastel,
          size: PastelTileSize.large,
          badge: granted ? PastelBadge.ok : PastelBadge.none,
        ),
        const SizedBox(height: AppSpacing.xl),
        Semantics(
          header: true,
          child: Text(title, style: textTheme.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(body, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xl),
        if (granted)
          const StatusChip(
            Strings.permissionGranted,
            tone: StatusChipTone.success,
          )
        else
          PillButton(label: actionLabel, onPressed: onAction),
      ],
    );
  }
}
