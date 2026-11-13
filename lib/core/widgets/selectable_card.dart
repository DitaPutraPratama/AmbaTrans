import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// Outlined card. Selected = primary border + selectedBg; disabled = dimmed, no taps.
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.title,
    this.subtitle,
    this.selected = false,
    this.enabled = true,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final shape = BorderRadius.circular(AppRadius.selectableCard);
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: subtitle == null ? title : '$title, $subtitle',
      onTap: enabled ? onTap : null,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Material(
          color: selected ? colors.selectedBg : colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: shape,
            side: BorderSide(
              color: selected ? colors.primary : colors.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: shape,
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: textTheme.labelLarge),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(subtitle!, style: textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle_rounded, color: colors.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
