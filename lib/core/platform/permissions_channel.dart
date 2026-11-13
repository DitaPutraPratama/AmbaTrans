import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@immutable
class PermissionStatus {
  const PermissionStatus({
    required this.overlay,
    required this.notifications,
    required this.accessibility,
  });

  final bool overlay;
  final bool notifications;
  final bool accessibility;

  @override
  bool operator ==(Object other) =>
      other is PermissionStatus &&
      other.overlay == overlay &&
      other.notifications == notifications &&
      other.accessibility == accessibility;

  @override
  int get hashCode => Object.hash(overlay, notifications, accessibility);
}

/// Client for the `permissions` channel (docs/ARCHITECTURE.md §6).
abstract class PermissionsChannel {
  Future<PermissionStatus> getStatus();

  Future<void> openOverlaySettings();

  /// Resolves to whether notifications are allowed after the request.
  Future<bool> requestNotifications();

  Future<void> openAccessibilitySettings();
}

class MethodPermissionsChannel implements PermissionsChannel {
  MethodPermissionsChannel([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'com.ambatrans.app/permissions';

  final MethodChannel _channel;

  @override
  Future<PermissionStatus> getStatus() async {
    final map = await _channel.invokeMapMethod<String, Object?>('getStatus');
    return PermissionStatus(
      overlay: map?['overlay'] == true,
      notifications: map?['notifications'] == true,
      accessibility: map?['accessibility'] == true,
    );
  }

  @override
  Future<void> openOverlaySettings() =>
      _channel.invokeMethod<void>('openOverlaySettings');

  @override
  Future<bool> requestNotifications() async =>
      await _channel.invokeMethod<bool>('requestNotifications') ?? false;

  @override
  Future<void> openAccessibilitySettings() =>
      _channel.invokeMethod<void>('openAccessibilitySettings');
}
