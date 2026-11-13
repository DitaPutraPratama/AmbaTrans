import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@immutable
class ModelStatus {
  const ModelStatus({required this.ready, required this.missing});

  final bool ready;

  /// BCP-47 codes of models still to be downloaded.
  final List<String> missing;

  @override
  bool operator ==(Object other) =>
      other is ModelStatus &&
      other.ready == ready &&
      listEquals(other.missing, missing);

  @override
  int get hashCode => Object.hash(ready, Object.hashAll(missing));
}

/// Thrown when downloading models fails (`E_MODEL_DOWNLOAD_FAILED`).
class ModelDownloadException implements Exception {
  const ModelDownloadException([this.message]);

  final String? message;

  @override
  String toString() => 'ModelDownloadException: $message';
}

/// Client for the `models` channel (docs/ARCHITECTURE.md §6).
abstract class ModelsChannel {
  Future<List<String>> getSupportedLanguages();

  Future<ModelStatus> getStatus(String source, String target);

  /// Completes when every model of the pair is installed.
  Future<void> download(String source, String target);
}

class MethodModelsChannel implements ModelsChannel {
  MethodModelsChannel([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'com.ambatrans.app/models';

  final MethodChannel _channel;

  @override
  Future<List<String>> getSupportedLanguages() async =>
      await _channel.invokeListMethod<String>('getSupportedLanguages') ??
      const [];

  @override
  Future<ModelStatus> getStatus(String source, String target) async {
    final map = await _channel.invokeMapMethod<String, Object?>('getStatus', {
      'source': source,
      'target': target,
    });
    final missing = (map?['missing'] as List?)?.cast<String>() ?? const [];
    return ModelStatus(ready: map?['ready'] == true, missing: missing);
  }

  @override
  Future<void> download(String source, String target) async {
    try {
      await _channel.invokeMethod<void>('download', {
        'source': source,
        'target': target,
      });
    } on PlatformException catch (e) {
      if (e.code == 'E_MODEL_DOWNLOAD_FAILED') {
        throw ModelDownloadException(e.message);
      }
      rethrow;
    }
  }
}
