import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/strings.dart';

/// Colours offered for overlay labels, as 0xRRGGBB with their names.
const overlayPalette = <(int, String)>[
  (0xFFFFFF, Strings.colorWhite),
  (0x000000, Strings.colorBlack),
  (0x424242, Strings.colorGrey),
  (0xFFEB3B, Strings.colorYellow),
  (0x1565C0, Strings.colorBlue),
  (0x2E7D32, Strings.colorGreen),
  (0xC62828, Strings.colorRed),
  (0x6A1B9A, Strings.colorPurple),
];

/// Preview of an overlay label plus swatches for its text and background colour.
class OverlayColorCard extends StatelessWidget {
  const OverlayColorCard({
    super.key,
    required this.textColor,
    required this.bgColor,
    required this.onTextColor,
    required this.onBgColor,
  });

  final int textColor;
  final int bgColor;
  final ValueChanged<int> onTextColor;
  final ValueChanged<int> onBgColor;

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
            // Same opacity as the real overlay window (OverlayRenderer.WINDOW_ALPHA).
            Opacity(
              opacity: 0.75,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF000000 | bgColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  Strings.overlayPreview,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Color(0xFF000000 | textColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(Strings.overlayTextColor, style: textTheme.labelLarge),
            _Swatches(selected: textColor, onSelected: onTextColor),
            const SizedBox(height: AppSpacing.md),
            Text(Strings.overlayBgColor, style: textTheme.labelLarge),
            _Swatches(selected: bgColor, onSelected: onBgColor),
          ],
        ),
      ),
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      children: [
        for (final (rgb, name) in overlayPalette)
          Semantics(
            button: true,
            selected: rgb == selected,
            label: name,
            excludeSemantics: true,
            child: InkResponse(
              onTap: () => onSelected(rgb),
              child: SizedBox.square(
                dimension: 48,
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(0xFF000000 | rgb),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: rgb == selected
                            ? colors.primary
                            : colors.outline,
                        width: rgb == selected ? 3 : 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
