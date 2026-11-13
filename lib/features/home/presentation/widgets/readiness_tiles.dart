import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/strings.dart';
import '../../../../core/widgets/pastel_icon_tile.dart';
import '../../../../core/widgets/press_scale.dart';
import '../../application/home_state.dart';

/// Four readiness tiles (overlay, notifications, models, accurate mode).
/// 4 columns normally, 2 columns from 150% font scale (DESIGN §6).
class ReadinessTiles extends StatelessWidget {
  const ReadinessTiles({
    super.key,
    required this.state,
    required this.onOverlay,
    required this.onNotifications,
    required this.onModels,
    required this.onAccurate,
  });

  final HomeState state;
  final VoidCallback onOverlay;
  final VoidCallback onNotifications;
  final VoidCallback onModels;
  final VoidCallback onAccurate;

  @override
  Widget build(BuildContext context) {
    final columns = MediaQuery.textScalerOf(context).scale(1) >= 1.5 ? 2 : 4;
    final tiles = [
      _Tile(
        Strings.tileOverlay,
        Icons.layers_rounded,
        AppPastels.blue,
        state.permissions.overlay ? PastelBadge.ok : PastelBadge.warning,
        onOverlay,
      ),
      _Tile(
        Strings.tileNotifications,
        Icons.notifications_rounded,
        AppPastels.yellow,
        state.permissions.notifications ? PastelBadge.ok : PastelBadge.warning,
        onNotifications,
      ),
      _Tile(
        Strings.tileModels,
        Icons.translate_rounded,
        AppPastels.green,
        state.models.ready ? PastelBadge.ok : PastelBadge.warning,
        onModels,
      ),
      // Optional feature: a check when on, no badge when off.
      _Tile(
        Strings.tileAccurate,
        Icons.accessibility_new_rounded,
        AppPastels.purple,
        state.permissions.accessibility ? PastelBadge.ok : PastelBadge.none,
        onAccurate,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.sm;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: AppSpacing.md,
          children: [
            for (final tile in tiles) SizedBox(width: width, child: tile),
          ],
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.label, this.icon, this.colors, this.badge, this.onTap);

  final String label;
  final IconData icon;
  final PastelColors colors;
  final PastelBadge badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = badge == PastelBadge.warning
        ? Strings.tileNeedsAction
        : Strings.tileReady;
    return Semantics(
      button: true,
      label: '$label, $status',
      onTap: onTap,
      excludeSemantics: true,
      child: PressScale(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.tile),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PastelIconTile(icon: icon, colors: colors, badge: badge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
