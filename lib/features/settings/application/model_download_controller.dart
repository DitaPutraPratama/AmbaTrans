import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/channel_providers.dart';
import '../../../core/platform/models_channel.dart';
import 'settings_controller.dart';

enum DownloadStatus { idle, downloading, failed, done }

final modelDownloadProvider =
    NotifierProvider.autoDispose<ModelDownloadController, DownloadStatus>(
      ModelDownloadController.new,
    );

class ModelDownloadController extends Notifier<DownloadStatus> {
  @override
  DownloadStatus build() => DownloadStatus.idle;

  /// Downloads the models of the current language pair, then refreshes their status.
  Future<void> download() async {
    if (state == DownloadStatus.downloading) return;
    final settings = await ref.read(settingsControllerProvider.future);
    state = DownloadStatus.downloading;
    try {
      await ref
          .read(modelsChannelProvider)
          .download(settings.source, settings.target);
      await ref.read(settingsControllerProvider.notifier).refreshModels();
      state = DownloadStatus.done;
    } on ModelDownloadException {
      state = DownloadStatus.failed;
    }
  }
}
