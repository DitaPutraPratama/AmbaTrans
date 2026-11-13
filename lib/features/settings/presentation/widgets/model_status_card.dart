import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/strings.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../../core/widgets/status_chip.dart';

/// "Model offline" row: status chip, plus an "Unduh" button while models are missing.
class ModelStatusCard extends StatelessWidget {
  const ModelStatusCard({
    super.key,
    required this.ready,
    required this.onDownload,
  });

  final bool ready;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    Strings.offlineModel,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Flexible: at large font scales the chip text wraps instead of overflowing.
                Flexible(
                  child: StatusChip(
                    ready ? Strings.readyOffline : Strings.notDownloaded,
                    tone: ready
                        ? StatusChipTone.success
                        : StatusChipTone.warning,
                  ),
                ),
              ],
            ),
            if (!ready) ...[
              const SizedBox(height: AppSpacing.md),
              PillButton(
                label: Strings.download,
                icon: Icons.download_rounded,
                onPressed: onDownload,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
