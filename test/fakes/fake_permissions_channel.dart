import 'package:ambatrans/core/platform/permissions_channel.dart';

/// Controllable [PermissionsChannel]; mutate the fields to simulate the system.
class FakePermissionsChannel implements PermissionsChannel {
  FakePermissionsChannel({
    this.overlay = false,
    this.notifications = false,
    this.accessibility = false,
    this.grantNotificationsOnRequest = true,
  });

  bool overlay;
  bool notifications;
  bool accessibility;
  bool grantNotificationsOnRequest;

  int openOverlaySettingsCalls = 0;
  int openAccessibilitySettingsCalls = 0;
  int requestNotificationsCalls = 0;
  int openBatterySettingsCalls = 0;

  @override
  Future<PermissionStatus> getStatus() async => PermissionStatus(
    overlay: overlay,
    notifications: notifications,
    accessibility: accessibility,
  );

  @override
  Future<void> openOverlaySettings() async => openOverlaySettingsCalls++;

  @override
  Future<void> openBatterySettings() async => openBatterySettingsCalls++;

  @override
  Future<void> openAccessibilitySettings() async =>
      openAccessibilitySettingsCalls++;

  @override
  Future<bool> requestNotifications() async {
    requestNotificationsCalls++;
    if (grantNotificationsOnRequest) notifications = true;
    return notifications;
  }
}
