import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/strings.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../../core/widgets/status_chip.dart';

/// Model status chip, plus an "Unduh" button while models are missing.
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
        // Wrap: at large font scales the button drops below the chip.
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            StatusChip(
              ready ? Strings.readyOffline : Strings.notDownloaded,
              tone: ready ? StatusChipTone.success : StatusChipTone.warning,
            ),
            if (!ready)
              PillButton(
                label: Strings.download,
                icon: Icons.download_rounded,
                onPressed: onDownload,
              ),
          ],
        ),
      ),
    );
  }
}
