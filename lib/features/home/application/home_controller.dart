import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/channel_providers.dart';
import '../../../core/platform/models_channel.dart';
import '../../../core/platform/service_channel.dart';
import 'home_state.dart';

final homeControllerProvider = AsyncNotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

class HomeController extends AsyncNotifier<HomeState> {
  bool _userStopping = false;

  @override
  Future<HomeState> build() async {
    final subscription = ref
        .read(serviceChannelProvider)
        .running
        .listen(_onRunningChanged);
    ref.onDispose(subscription.cancel);
    return _load();
  }

  Future<HomeState> _load() async {
    final settings = await ref.read(settingsChannelProvider).getAll();
    final source = settings['source_lang'] as String? ?? 'en';
    final target = settings['target_lang'] as String? ?? 'id';
    final permissions = await ref.read(permissionsChannelProvider).getStatus();
    final models = await _modelStatus(source, target);
    final running = await ref.read(serviceChannelProvider).isRunning();
    final previous = state.value;
    return HomeState(
      running: running,
      permissions: permissions,
      models: models,
      source: source,
      target: target,
      stoppedBySystem: !running && (previous?.stoppedBySystem ?? false),
    );
  }

  Future<ModelStatus> _modelStatus(String source, String target) async {
    try {
      return await ref.read(modelsChannelProvider).getStatus(source, target);
    } on PlatformException {
      return const ModelStatus(ready: false, missing: []);
    }
  }

  void _onRunningChanged(bool running) {
    final current = state.value;
    if (current == null || current.running == running) return;
    final diedUnexpectedly = current.running && !running && !_userStopping;
    if (!running) _userStopping = false;
    state = AsyncData(
      current.copyWith(
        running: running,
        stoppedBySystem: diedUnexpectedly
            ? true
            : (running ? false : current.stoppedBySystem),
      ),
    );
  }

  /// Re-reads permissions, models and settings (e.g. after returning from system settings).
  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  Future<void> start() async {
    final current = state.value;
    if (current == null || current.starting) return;
    _userStopping = false;
    state = AsyncData(current.copyWith(starting: true, startError: null));
    try {
      await ref.read(serviceChannelProvider).start();
      state = AsyncData(
        state.requireValue.copyWith(starting: false, stoppedBySystem: false),
      );
    } on ServiceStartException catch (e) {
      state = AsyncData(
        state.requireValue.copyWith(starting: false, startError: e.error),
      );
      if (e.error == ServiceStartError.noOverlayPermission) await refresh();
    }
  }

  Future<void> stop() async {
    // The "stopped" event arrives asynchronously; _onRunningChanged consumes the flag.
    _userStopping = true;
    await ref.read(serviceChannelProvider).stop();
  }

  Future<void> openOverlaySettings() =>
      ref.read(permissionsChannelProvider).openOverlaySettings();

  Future<void> openAccessibilitySettings() =>
      ref.read(permissionsChannelProvider).openAccessibilitySettings();

  /// Shows the capture dialog, then re-reads state once the service has taken the result.
  Future<void> requestCapture() async {
    await ref.read(permissionsChannelProvider).requestCapture();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    await refresh();
  }

  Future<void> requestNotifications() async {
    await ref.read(permissionsChannelProvider).requestNotifications();
    await refresh();
  }
}
