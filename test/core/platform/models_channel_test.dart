import 'package:ambatrans/core/platform/models_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_models_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodModelsChannel', () {
    const channel = MethodChannel(MethodModelsChannel.channelName);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('getSupportedLanguages returns the list', () async {
      messenger.setMockMethodCallHandler(channel, (call) async => ['en', 'id']);
      expect(await MethodModelsChannel().getSupportedLanguages(), ['en', 'id']);
    });

    test('getStatus sends the pair and maps the result', () async {
      MethodCall? received;
      messenger.setMockMethodCallHandler(channel, (call) async {
        received = call;
        return {
          'ready': false,
          'missing': ['id'],
        };
      });
      final status = await MethodModelsChannel().getStatus('en', 'id');
      expect(received?.arguments, {'source': 'en', 'target': 'id'});
      expect(status, const ModelStatus(ready: false, missing: ['id']));
    });

    test('download failure becomes ModelDownloadException', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(
          code: 'E_MODEL_DOWNLOAD_FAILED',
          message: 'offline',
        );
      });
      expect(
        MethodModelsChannel().download('en', 'id'),
        throwsA(isA<ModelDownloadException>()),
      );
    });

    test('other platform errors are rethrown', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'E_OTHER');
      });
      expect(
        MethodModelsChannel().download('en', 'id'),
        throwsA(isA<PlatformException>()),
      );
    });
  });

  group('FakeModelsChannel', () {
    test('pairs without English also need the English pivot', () async {
      final fake = FakeModelsChannel();
      final status = await fake.getStatus('ja', 'id');
      expect(status.ready, isFalse);
      expect(status.missing, containsAll(['ja', 'id', 'en']));
    });

    test('download marks the pair ready', () async {
      final fake = FakeModelsChannel();
      await fake.download('en', 'id');
      expect((await fake.getStatus('en', 'id')).ready, isTrue);
    });

    test('failing download throws and installs nothing', () async {
      final fake = FakeModelsChannel(failDownload: true);
      await expectLater(
        fake.download('en', 'id'),
        throwsA(isA<ModelDownloadException>()),
      );
      expect((await fake.getStatus('en', 'id')).ready, isFalse);
    });
  });
}
