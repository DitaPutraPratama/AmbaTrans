import 'package:ambatrans/core/platform/permissions_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_permissions_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodPermissionsChannel', () {
    const channel = MethodChannel(MethodPermissionsChannel.channelName);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <String>[];

    setUp(calls.clear);
    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('getStatus maps the native map', () async {
      messenger.setMockMethodCallHandler(
        channel,
        (call) async => {
          'overlay': true,
          'notifications': false,
          'accessibility': true,
        },
      );
      final status = await MethodPermissionsChannel().getStatus();
      expect(
        status,
        const PermissionStatus(
          overlay: true,
          notifications: false,
          accessibility: true,
        ),
      );
    });

    test('getStatus treats missing keys as not granted', () async {
      messenger.setMockMethodCallHandler(channel, (call) async => {});
      final status = await MethodPermissionsChannel().getStatus();
      expect(status.overlay, isFalse);
      expect(status.notifications, isFalse);
      expect(status.accessibility, isFalse);
    });

    test('requestNotifications returns the native answer', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return true;
      });
      expect(await MethodPermissionsChannel().requestNotifications(), isTrue);
      expect(calls, ['requestNotifications']);
    });

    test('open settings methods invoke the matching native method', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return null;
      });
      final client = MethodPermissionsChannel();
      await client.openOverlaySettings();
      await client.openAccessibilitySettings();
      expect(calls, ['openOverlaySettings', 'openAccessibilitySettings']);
    });
  });

  group('FakePermissionsChannel', () {
    test('requestNotifications grants when configured', () async {
      final fake = FakePermissionsChannel();
      expect(await fake.requestNotifications(), isTrue);
      expect((await fake.getStatus()).notifications, isTrue);
    });

    test('requestNotifications can be denied', () async {
      final fake = FakePermissionsChannel(grantNotificationsOnRequest: false);
      expect(await fake.requestNotifications(), isFalse);
      expect(fake.requestNotificationsCalls, 1);
    });
  });
}
