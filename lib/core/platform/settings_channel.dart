import 'package:flutter/services.dart';

/// Thrown when native rejects a value (error code `E_INVALID_VALUE`).
class InvalidValueException implements Exception {
  const InvalidValueException(this.message);

  final String message;

  @override
  String toString() => 'InvalidValueException: $message';
}

/// Client for the `settings` channel (docs/ARCHITECTURE.md §6).
abstract class SettingsChannel {
  Future<Map<String, Object?>> getAll();

  Future<void> set(String key, Object value);
}

class MethodSettingsChannel implements SettingsChannel {
  MethodSettingsChannel([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'com.ambatrans.app/settings';

  final MethodChannel _channel;

  @override
  Future<Map<String, Object?>> getAll() async {
    final result = await _channel.invokeMapMethod<String, Object?>('getAll');
    return result ?? const {};
  }

  @override
  Future<void> set(String key, Object value) async {
    try {
      await _channel.invokeMethod<void>('set', {'key': key, 'value': value});
    } on PlatformException catch (e) {
      if (e.code == 'E_INVALID_VALUE') {
        throw InvalidValueException(e.message ?? key);
      }
      rethrow;
    }
  }
}
