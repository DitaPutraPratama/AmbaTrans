import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import 'press_scale.dart';

/// 44 dp white round icon button with a 48 dp touch target.
class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onPressed,
      excludeSemantics: true,
      child: PressScale(
        enabled: onPressed != null,
        child: SizedBox.square(
          dimension: 48,
          child: Center(
            child: Material(
              color: colors.surface,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed,
                child: SizedBox.square(
                  dimension: 44,
                  child: Icon(icon, size: 24, color: colors.textPrimary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
