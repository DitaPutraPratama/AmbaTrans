import 'dart:async';

import 'package:ambatrans/core/platform/service_channel.dart';

/// Controllable [ServiceChannel]. Set [startError] to make `start` fail.
class FakeServiceChannel implements ServiceChannel {
  FakeServiceChannel({this.startError});

  ServiceStartError? startError;
  bool _running = false;
  final _controller = StreamController<bool>.broadcast();

  int startCalls = 0;
  int stopCalls = 0;

  /// Simulates the system killing the service.
  void killFromSystem() => _set(false);

  void _set(bool value) {
    _running = value;
    _controller.add(value);
  }

  @override
  Future<void> start() async {
    startCalls++;
    if (startError != null) throw ServiceStartException(startError!);
    _set(true);
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    _set(false);
  }

  @override
  Future<bool> isRunning() async => _running;

  @override
  Stream<bool> get running async* {
    yield _running;
    yield* _controller.stream;
  }
}
