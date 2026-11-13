import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import 'icon_circle_button.dart';
import 'pastel_icon_tile.dart';

/// Opens [builder] in a modal sheet styled per docs/DESIGN.md (32 dp top radius).
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    builder: builder,
  );
}

/// Sheet content: drag handle, header (tile, title, subtitle, close), body, actions.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.icon,
    required this.iconColors,
    required this.title,
    required this.closeLabel,
    this.subtitle,
    this.onClose,
    this.closeEnabled = true,
    this.child,
    this.actions = const [],
  });

  final IconData icon;
  final PastelColors iconColors;
  final String title;
  final String closeLabel;
  final String? subtitle;
  final VoidCallback? onClose;

  /// When false the close button is disabled (e.g. while a download runs).
  final bool closeEnabled;
  final Widget? child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ExcludeSemantics(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.outline,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                PastelIconTile(
                  icon: icon,
                  colors: iconColors,
                  size: PastelTileSize.small,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(title, style: textTheme.titleMedium),
                      ),
                      if (subtitle != null)
                        Text(subtitle!, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                IconCircleButton(
                  icon: Icons.close_rounded,
                  semanticLabel: closeLabel,
                  onPressed: closeEnabled
                      ? (onClose ?? () => Navigator.of(context).maybePop())
                      : null,
                ),
              ],
            ),
            if (child != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Flexible(child: child!),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              for (final action in actions) ...[
                action,
                if (action != actions.last)
                  const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
