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
  int _generation = 0;

  @override
  DownloadStatus build() => DownloadStatus.idle;

  /// Stops waiting for the running download. The system may still finish it in the background;
  /// the result is ignored here and the next status refresh picks it up.
  void cancel() {
    _generation++;
    state = DownloadStatus.idle;
  }

  /// Downloads the models of the current language pair, then refreshes their status.
  Future<void> download() async {
    if (state == DownloadStatus.downloading) return;
    final settings = await ref.read(settingsControllerProvider.future);
    final generation = ++_generation;
    state = DownloadStatus.downloading;
    try {
      await ref
          .read(modelsChannelProvider)
          .download(settings.source, settings.target);
      if (generation != _generation) return;
      await ref.read(settingsControllerProvider.notifier).refreshModels();
      if (generation != _generation) return;
      state = DownloadStatus.done;
    } on ModelDownloadException {
      if (generation == _generation) state = DownloadStatus.failed;
    }
  }
}
