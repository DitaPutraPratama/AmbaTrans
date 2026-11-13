import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/languages.dart';
import '../../../../core/strings.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../application/model_download_controller.dart';
import '../../application/settings_controller.dart';

/// Approximate size of one ML Kit translation model, shown to the user.
const _megabytesPerModel = 30;

Future<void> showModelDownloadSheet(BuildContext context) {
  return showAppBottomSheet<void>(
    context: context,
    builder: (_) => const ModelDownloadSheet(),
  );
}

/// S-05: confirm, download, retry on failure, close itself after success.
class ModelDownloadSheet extends ConsumerWidget {
  const ModelDownloadSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(modelDownloadProvider);
    final settings = ref.watch(settingsControllerProvider).value;
    ref.listen(modelDownloadProvider, (_, next) {
      if (next == DownloadStatus.done) {
        Future<void>.delayed(const Duration(seconds: 1), () {
          if (context.mounted) Navigator.of(context).maybePop();
        });
      }
    });
    final download = ref.read(modelDownloadProvider.notifier).download;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final busy = status == DownloadStatus.downloading;

    return AppBottomSheet(
      icon: Icons.download_rounded,
      iconColors: AppPastels.green,
      title: Strings.downloadModelTitle,
      closeLabel: Strings.close,
      closeEnabled: !busy,
      actions: [
        if (status == DownloadStatus.idle)
          PillButton(
            label: Strings.download,
            expand: true,
            onPressed: download,
          ),
        if (status == DownloadStatus.failed)
          PillButton(label: Strings.retry, expand: true, onPressed: download),
        if (status == DownloadStatus.idle || status == DownloadStatus.failed)
          PillButton(
            label: Strings.later,
            variant: PillButtonVariant.text,
            expand: true,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
      ],
      child: switch (status) {
        DownloadStatus.idle => Text(
          _body(settings),
          style: textTheme.bodyMedium,
        ),
        DownloadStatus.downloading => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            const _ElapsedText(),
          ],
        ),
        DownloadStatus.failed => DecoratedBox(
          decoration: BoxDecoration(
            color: colors.errorBg,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              Strings.downloadFailed,
              style: textTheme.bodyMedium?.copyWith(color: colors.error),
            ),
          ),
        ),
        DownloadStatus.done => Row(
          children: [
            Icon(Icons.check_circle_rounded, color: colors.success),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(Strings.readyOffline, style: textTheme.titleMedium),
            ),
          ],
        ),
      },
    );
  }

  String _body(SettingsState? settings) {
    if (settings == null) return '';
    final codes = settings.models.missing.isEmpty
        ? [settings.source, settings.target]
        : settings.models.missing;
    final names = codes.map(Languages.nameOf).join(' dan ');
    return Strings.downloadModelBody(names, codes.length * _megabytesPerModel);
  }
}

/// "Mengunduh… N dtk". ML Kit reports no progress, so the ticking counter is
/// what shows the download is still alive.
class _ElapsedText extends StatefulWidget {
  const _ElapsedText();

  @override
  State<_ElapsedText> createState() => _ElapsedTextState();
}

class _ElapsedTextState extends State<_ElapsedText> {
  int _seconds = 0;
  late final Timer _timer = Timer.periodic(
    const Duration(seconds: 1),
    (_) => setState(() => _seconds++),
  );

  @override
  void initState() {
    super.initState();
    _timer; // starts the lazy timer
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(
    Strings.downloading(_seconds),
    style: Theme.of(context).textTheme.bodyMedium,
  );
}
