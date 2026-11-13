import 'package:ambatrans/core/platform/settings_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_settings_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodSettingsChannel', () {
    const channel = MethodChannel(MethodSettingsChannel.channelName);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('getAll returns the native map', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'getAll');
        return {'source_lang': 'en', 'bubble_y_fraction': 0.35};
      });
      final all = await MethodSettingsChannel().getAll();
      expect(all['source_lang'], 'en');
      expect(all['bubble_y_fraction'], 0.35);
    });

    test('set sends key and value', () async {
      MethodCall? received;
      messenger.setMockMethodCallHandler(channel, (call) async {
        received = call;
        return null;
      });
      await MethodSettingsChannel().set('bubble_edge', 'left');
      expect(received?.method, 'set');
      expect(received?.arguments, {'key': 'bubble_edge', 'value': 'left'});
    });

    test('E_INVALID_VALUE becomes InvalidValueException', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'E_INVALID_VALUE', message: 'nope');
      });
      expect(
        MethodSettingsChannel().set('source_lang', 'id'),
        throwsA(isA<InvalidValueException>()),
      );
    });

    test('other platform errors are rethrown', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'E_OTHER');
      });
      expect(
        MethodSettingsChannel().set('source_lang', 'ja'),
        throwsA(isA<PlatformException>()),
      );
    });
  });

  group('FakeSettingsChannel', () {
    test('returns defaults and stores values', () async {
      final fake = FakeSettingsChannel();
      expect((await fake.getAll())['target_lang'], 'id');
      await fake.set('source_lang', 'ja');
      expect((await fake.getAll())['source_lang'], 'ja');
    });

    test('rejects source equal to target', () async {
      final fake = FakeSettingsChannel();
      expect(
        fake.set('source_lang', 'id'),
        throwsA(isA<InvalidValueException>()),
      );
    });
  });
}
