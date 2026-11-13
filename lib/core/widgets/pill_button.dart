import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import 'press_scale.dart';

enum PillButtonVariant {
  /// Solid primary fill.
  filled,

  /// Translucent white, for use on the hero card.
  tonal,

  /// Text only.
  text,
}

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PillButtonVariant.filled,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground) = switch (variant) {
      PillButtonVariant.filled => (colors.primary, colors.onPrimary),
      PillButtonVariant.tonal => (
        colors.onPrimary.withValues(alpha: 0.2),
        colors.onPrimary,
      ),
      PillButtonVariant.text => (Colors.transparent, colors.primary),
    };
    final style = TextButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      disabledBackgroundColor: background.withValues(alpha: 0.5),
      minimumSize: Size(expand ? double.infinity : 0, 48),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.md,
      ),
      shape: const StadiumBorder(),
      textStyle: Theme.of(context).textTheme.labelLarge,
    );
    final active = !loading && onPressed != null;
    return PressScale(
      enabled: active,
      child: TextButton(
        style: style,
        onPressed: loading ? null : onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foreground,
                ),
              )
            else if (icon != null)
              Icon(icon, size: 20),
            if (loading || icon != null) const SizedBox(width: AppSpacing.sm),
            Flexible(child: Text(label, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
