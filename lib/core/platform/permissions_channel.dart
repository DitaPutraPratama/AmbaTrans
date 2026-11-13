import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@immutable
class PermissionStatus {
  const PermissionStatus({
    required this.overlay,
    required this.notifications,
    required this.accessibility,
    this.capture = false,
  });

  final bool overlay;
  final bool notifications;
  final bool accessibility;

  /// A screen-capture session is live (needs the user's consent each session).
  final bool capture;

  @override
  bool operator ==(Object other) =>
      other is PermissionStatus &&
      other.overlay == overlay &&
      other.notifications == notifications &&
      other.accessibility == accessibility &&
      other.capture == capture;

  @override
  int get hashCode =>
      Object.hash(overlay, notifications, accessibility, capture);
}

/// Client for the `permissions` channel (docs/ARCHITECTURE.md §6).
abstract class PermissionsChannel {
  Future<PermissionStatus> getStatus();

  Future<void> openOverlaySettings();

  /// Resolves to whether notifications are allowed after the request.
  Future<bool> requestNotifications();

  Future<void> openAccessibilitySettings();

  /// Shows the system screen-capture dialog (service must be running).
  Future<void> requestCapture();

  /// Switches the Accessibility service off in system settings (no-op if it is off).
  Future<void> disableAccessibility();

  /// Opens battery-optimization settings so the user can exempt the app (F-02 reliability).
  Future<void> openBatterySettings();
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
      capture: map?['capture'] == true,
    );
  }

  @override
  Future<void> openOverlaySettings() =>
      _channel.invokeMethod<void>('openOverlaySettings');

  @override
  Future<bool> requestNotifications() async =>
      await _channel.invokeMethod<bool>('requestNotifications') ?? false;

  @override
  Future<void> disableAccessibility() =>
      _channel.invokeMethod<void>('disableAccessibility');

  @override
  Future<void> requestCapture() =>
      _channel.invokeMethod<void>('requestCapture');

  @override
  Future<void> openBatterySettings() =>
      _channel.invokeMethod<void>('openBatterySettings');

  @override
  Future<void> openAccessibilitySettings() =>
      _channel.invokeMethod<void>('openAccessibilitySettings');
}
