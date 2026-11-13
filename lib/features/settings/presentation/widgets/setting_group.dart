import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';

/// One white rounded card holding several rows, separated by thin dividers.
class SettingGroup extends StatelessWidget {
  const SettingGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
                color: colors.outline,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}
