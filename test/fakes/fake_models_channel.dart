import 'dart:async';

import 'package:ambatrans/core/platform/models_channel.dart';

/// Controllable [ModelsChannel]. Models in [downloaded] count as installed.
/// Give [downloadGate] a Completer to hold `download` open (loading state).
class FakeModelsChannel implements ModelsChannel {
  FakeModelsChannel({
    Set<String>? downloaded,
    this.languages = const ['en', 'id', 'ja', 'fr'],
    this.failDownload = false,
    this.downloadGate,
  }) : downloaded = downloaded ?? {};

  final Set<String> downloaded;
  final List<String> languages;
  bool failDownload;
  Completer<void>? downloadGate;

  int downloadCalls = 0;

  @override
  Future<List<String>> getSupportedLanguages() async => languages;

  @override
  Future<ModelStatus> getStatus(String source, String target) async {
    final needed = {source, target, if (source != 'en' && target != 'en') 'en'}
      ..remove('auto');
    final missing = needed.where((c) => !downloaded.contains(c)).toList();
    return ModelStatus(ready: missing.isEmpty, missing: missing);
  }

  @override
  Future<void> download(String source, String target) async {
    downloadCalls++;
    await downloadGate?.future;
    if (failDownload) throw const ModelDownloadException('offline');
    downloaded.addAll({
      source,
      target,
      if (source != 'en' && target != 'en') 'en',
    });
  }
}
