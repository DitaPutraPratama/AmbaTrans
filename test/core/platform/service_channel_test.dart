import 'package:ambatrans/core/platform/service_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_service_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodServiceChannel', () {
    const method = MethodChannel(MethodServiceChannel.methodChannelName);
    const events = EventChannel(MethodServiceChannel.eventChannelName);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() {
      messenger.setMockMethodCallHandler(method, null);
      messenger.setMockStreamHandler(events, null);
    });

    test(
      'start, stop and isRunning call the matching native methods',
      () async {
        final calls = <String>[];
        messenger.setMockMethodCallHandler(method, (call) async {
          calls.add(call.method);
          return call.method == 'isRunning' ? true : null;
        });
        final client = MethodServiceChannel();
        await client.start();
        await client.stop();
        expect(await client.isRunning(), isTrue);
        expect(calls, ['start', 'stop', 'isRunning']);
      },
    );

    test('E_NO_OVERLAY_PERMISSION becomes a typed exception', () async {
      messenger.setMockMethodCallHandler(method, (call) async {
        throw PlatformException(code: 'E_NO_OVERLAY_PERMISSION');
      });
      expect(
        MethodServiceChannel().start(),
        throwsA(
          isA<ServiceStartException>().having(
            (e) => e.error,
            'error',
            ServiceStartError.noOverlayPermission,
          ),
        ),
      );
    });

    test('E_SERVICE_START_FAILED becomes a typed exception', () async {
      messenger.setMockMethodCallHandler(method, (call) async {
        throw PlatformException(code: 'E_SERVICE_START_FAILED');
      });
      expect(
        MethodServiceChannel().start(),
        throwsA(
          isA<ServiceStartException>().having(
            (e) => e.error,
            'error',
            ServiceStartError.startFailed,
          ),
        ),
      );
    });

    test('unknown platform errors are rethrown', () async {
      messenger.setMockMethodCallHandler(method, (call) async {
        throw PlatformException(code: 'E_OTHER');
      });
      expect(MethodServiceChannel().start(), throwsA(isA<PlatformException>()));
    });

    test('running maps "running"/"stopped" to booleans', () async {
      messenger.setMockStreamHandler(
        events,
        MockStreamHandler.inline(
          onListen: (arguments, sink) {
            sink.success('running');
            sink.success('stopped');
            sink.endOfStream();
          },
        ),
      );
      expect(await MethodServiceChannel().running.toList(), [true, false]);
    });
  });

  group('FakeServiceChannel', () {
    test('start/stop update state and stream', () async {
      final fake = FakeServiceChannel();
      final emitted = <bool>[];
      final sub = fake.running.listen(emitted.add);
      await Future<void>.delayed(Duration.zero);
      await fake.start();
      fake.killFromSystem();
      await Future<void>.delayed(Duration.zero);
      expect(emitted, [false, true, false]);
      expect(await fake.isRunning(), isFalse);
      await sub.cancel();
    });

    test('start throws the configured error', () async {
      final fake = FakeServiceChannel(
        startError: ServiceStartError.noOverlayPermission,
      );
      expect(fake.start(), throwsA(isA<ServiceStartException>()));
    });
  });
}
