import 'package:flutter/foundation.dart';

import '../../../core/platform/models_channel.dart';
import '../../../core/platform/permissions_channel.dart';
import '../../../core/platform/service_channel.dart';

@immutable
class HomeState {
  const HomeState({
    required this.running,
    required this.permissions,
    required this.models,
    required this.source,
    required this.target,
    this.stoppedBySystem = false,
    this.startError,
    this.starting = false,
  });

  final bool running;
  final PermissionStatus permissions;
  final ModelStatus models;
  final String source;
  final String target;

  /// The service ended without the user asking for it (F-02, shown under "Perlu diperhatikan").
  final bool stoppedBySystem;
  final ServiceStartError? startError;
  final bool starting;

  /// Everything required to start is in place.
  bool get canStart => permissions.overlay;

  HomeState copyWith({
    bool? running,
    PermissionStatus? permissions,
    ModelStatus? models,
    String? source,
    String? target,
    bool? stoppedBySystem,
    Object? startError = _keep,
    bool? starting,
  }) {
    return HomeState(
      running: running ?? this.running,
      permissions: permissions ?? this.permissions,
      models: models ?? this.models,
      source: source ?? this.source,
      target: target ?? this.target,
      stoppedBySystem: stoppedBySystem ?? this.stoppedBySystem,
      startError: identical(startError, _keep)
          ? this.startError
          : startError as ServiceStartError?,
      starting: starting ?? this.starting,
    );
  }

  static const _keep = Object();
}
