import 'package:flutter/services.dart';

enum ServiceStartError { noOverlayPermission, startFailed }

/// Thrown by [ServiceChannel.start] (codes `E_NO_OVERLAY_PERMISSION`, `E_SERVICE_START_FAILED`).
class ServiceStartException implements Exception {
  const ServiceStartException(this.error);

  final ServiceStartError error;

  @override
  String toString() => 'ServiceStartException: $error';
}

/// Client for the `service` and `service_state` channels (docs/ARCHITECTURE.md §6).
abstract class ServiceChannel {
  Future<void> start();

  Future<void> stop();

  Future<bool> isRunning();

  /// Emits `true` while the service runs and `false` when it stops; the current value arrives first.
  Stream<bool> get running;
}

class MethodServiceChannel implements ServiceChannel {
  MethodServiceChannel([MethodChannel? method, EventChannel? events])
    : _method = method ?? const MethodChannel(methodChannelName),
      _events = events ?? const EventChannel(eventChannelName);

  static const methodChannelName = 'com.ambatrans.app/service';
  static const eventChannelName = 'com.ambatrans.app/service_state';

  final MethodChannel _method;
  final EventChannel _events;

  @override
  Future<void> start() async {
    try {
      await _method.invokeMethod<void>('start');
    } on PlatformException catch (e) {
      throw switch (e.code) {
        'E_NO_OVERLAY_PERMISSION' => const ServiceStartException(
          ServiceStartError.noOverlayPermission,
        ),
        'E_SERVICE_START_FAILED' => const ServiceStartException(
          ServiceStartError.startFailed,
        ),
        _ => e,
      };
    }
  }

  @override
  Future<void> stop() => _method.invokeMethod<void>('stop');

  @override
  Future<bool> isRunning() async =>
      await _method.invokeMethod<bool>('isRunning') ?? false;

  @override
  Stream<bool> get running =>
      _events.receiveBroadcastStream().map((event) => event == 'running');
}
