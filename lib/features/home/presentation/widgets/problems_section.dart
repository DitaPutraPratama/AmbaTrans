import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/strings.dart';
import '../../../../core/widgets/problem_tile.dart';
import '../../../../core/widgets/section_title.dart';
import '../../application/home_state.dart';

/// "Perlu diperhatikan": active problems, or an all-ready card when there are none.
class ProblemsSection extends StatelessWidget {
  const ProblemsSection({
    super.key,
    required this.state,
    required this.onSettings,
    required this.onStart,
    required this.onCapture,
  });

  final HomeState state;

  /// Opens Settings, where overlay, notification and model problems are fixed.
  final VoidCallback onSettings;
  final VoidCallback onStart;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final problems = <Widget>[
      if (!state.permissions.overlay)
        ProblemTile(text: Strings.problemOverlay, onTap: onSettings),
      if (!state.permissions.notifications)
        ProblemTile(text: Strings.problemNotifications, onTap: onSettings),
      if (!state.models.ready)
        ProblemTile(text: Strings.problemModels, onTap: onSettings),
      if (state.running && !state.permissions.capture)
        ProblemTile(text: Strings.problemCapture, onTap: onCapture),
      if (state.stoppedBySystem)
        ProblemTile(text: Strings.problemStoppedBySystem, onTap: onStart),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(Strings.needsAttention),
        const SizedBox(height: AppSpacing.md),
        if (problems.isEmpty)
          const _AllReadyCard()
        else
          for (final tile in problems) ...[
            tile,
            const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }
}

class _AllReadyCard extends StatelessWidget {
  const _AllReadyCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: colors.success),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                Strings.allReady,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
