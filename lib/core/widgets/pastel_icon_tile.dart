import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

enum PastelTileSize {
  small(40),
  medium(56),
  large(80);

  const PastelTileSize(this.dimension);

  final double dimension;
}

enum PastelBadge { none, ok, warning }

/// Rounded pastel square with an icon and an optional status badge.
class PastelIconTile extends StatelessWidget {
  const PastelIconTile({
    super.key,
    required this.icon,
    required this.colors,
    this.size = PastelTileSize.medium,
    this.badge = PastelBadge.none,
  });

  final IconData icon;
  final PastelColors colors;
  final PastelTileSize size;
  final PastelBadge badge;

  @override
  Widget build(BuildContext context) {
    final app = context.colors;
    final radius = size == PastelTileSize.large
        ? AppRadius.tileLarge
        : AppRadius.tile;
    final dimension = size.dimension;
    return SizedBox.square(
      dimension: dimension,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Icon(icon, size: dimension * 0.5, color: colors.icon),
            ),
          ),
          if (badge != PastelBadge.none)
            Positioned(
              top: -4,
              right: -4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: badge == PastelBadge.ok ? app.success : app.warning,
                  shape: BoxShape.circle,
                  border: Border.all(color: app.surface, width: 2),
                ),
                child: Icon(
                  badge == PastelBadge.ok
                      ? Icons.check_rounded
                      : Icons.priority_high_rounded,
                  size: 14,
                  color: app.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
