import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/languages.dart';
import '../../../core/platform/channel_providers.dart';
import '../../../core/platform/models_channel.dart';
import '../../../core/platform/settings_channel.dart';

@immutable
class SettingsState {
  const SettingsState({
    required this.source,
    required this.target,
    required this.models,
    this.overlayGranted = false,
    this.notificationsGranted = false,
    this.overlayTextColor = defaultOverlayTextColor,
    this.overlayBgColor = defaultOverlayBgColor,
  });

  static const defaultOverlayTextColor = 0xFFFFFF;
  static const defaultOverlayBgColor = 0x424242;

  final String source;
  final String target;
  final ModelStatus models;
  final bool overlayGranted;
  final bool notificationsGranted;

  /// Overlay label colours as 0xRRGGBB (docs/DATABASE.md).
  final int overlayTextColor;
  final int overlayBgColor;

  SettingsState copyWith({
    String? source,
    String? target,
    ModelStatus? models,
    bool? overlayGranted,
    bool? notificationsGranted,
    int? overlayTextColor,
    int? overlayBgColor,
  }) => SettingsState(
    source: source ?? this.source,
    target: target ?? this.target,
    models: models ?? this.models,
    overlayGranted: overlayGranted ?? this.overlayGranted,
    notificationsGranted: notificationsGranted ?? this.notificationsGranted,
    overlayTextColor: overlayTextColor ?? this.overlayTextColor,
    overlayBgColor: overlayBgColor ?? this.overlayBgColor,
  );
}

enum LanguageSide { source, target }

enum OverlayColorRole {
  text('overlay_text_color'),
  background('overlay_bg_color');

  const OverlayColorRole(this.key);

  final String key;
}

/// Language codes offered as the *target*, sorted by Indonesian display name.
final supportedLanguagesProvider = FutureProvider<List<String>>(
  (ref) => _sortedLanguages(
    () => ref.read(modelsChannelProvider).getSupportedLanguages(),
  ),
);

/// Language codes offered as the *source*: only those OCR can read.
final supportedSourceLanguagesProvider = FutureProvider<List<String>>(
  (ref) => _sortedLanguages(
    () => ref.read(modelsChannelProvider).getSourceLanguages(),
  ),
);

Future<List<String>> _sortedLanguages(
  Future<List<String>> Function() load,
) async {
  List<String> codes;
  try {
    codes = await load();
  } on PlatformException {
    codes = const [];
  }
  if (codes.isEmpty) codes = Languages.codes.toList();
  return [...codes]
    ..sort((a, b) => Languages.nameOf(a).compareTo(Languages.nameOf(b)));
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, SettingsState>(
      SettingsController.new,
    );

class SettingsController extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() => _load();

  Future<SettingsState> _load() async {
    final all = await ref.read(settingsChannelProvider).getAll();
    final source = all['source_lang'] as String? ?? 'en';
    final target = all['target_lang'] as String? ?? 'id';
    final permissions = await ref.read(permissionsChannelProvider).getStatus();
    return SettingsState(
      source: source,
      target: target,
      models: await _models(source, target),
      overlayGranted: permissions.overlay,
      notificationsGranted: permissions.notifications,
      overlayTextColor:
          all['overlay_text_color'] as int? ??
          SettingsState.defaultOverlayTextColor,
      overlayBgColor:
          all['overlay_bg_color'] as int? ??
          SettingsState.defaultOverlayBgColor,
    );
  }

  Future<ModelStatus> _models(String source, String target) async {
    try {
      return await ref.read(modelsChannelProvider).getStatus(source, target);
    } on PlatformException {
      return const ModelStatus(ready: false, missing: []);
    }
  }

  /// Re-reads permission states (e.g. after returning from system settings).
  Future<void> refreshPermissions() async {
    final current = state.value;
    if (current == null) return;
    final permissions = await ref.read(permissionsChannelProvider).getStatus();
    state = AsyncData(
      current.copyWith(
        overlayGranted: permissions.overlay,
        notificationsGranted: permissions.notifications,
      ),
    );
  }

  Future<void> openOverlaySettings() =>
      ref.read(permissionsChannelProvider).openOverlaySettings();

  /// Notifications are optional: when on, opens system settings so the user can
  /// turn them off; when off, asks for them, falling back to system settings.
  Future<void> toggleNotifications() async {
    final permissions = ref.read(permissionsChannelProvider);
    final granted = state.value?.notificationsGranted ?? false;
    if (granted || !await permissions.requestNotifications()) {
      await permissions.openNotificationSettings();
    }
    await refreshPermissions();
  }

  Future<void> openBatterySettings() =>
      ref.read(permissionsChannelProvider).openBatterySettings();

  Future<void> refreshModels() async {
    final current = state.value;
    if (current == null) return;
    final models = await _models(current.source, current.target);
    state = AsyncData(current.copyWith(models: models));
  }

  Future<void> setOverlayColor(OverlayColorRole role, int rgb) async {
    final current = state.requireValue;
    await ref.read(settingsChannelProvider).set(role.key, rgb);
    state = AsyncData(
      role == OverlayColorRole.text
          ? current.copyWith(overlayTextColor: rgb)
          : current.copyWith(overlayBgColor: rgb),
    );
  }

  /// Saves [code] for [side]. Throws [InvalidValueException] if native rejects it
  /// (e.g. source equal to target); the stored state is then unchanged.
  Future<void> setLanguage(LanguageSide side, String code) async {
    final current = state.requireValue;
    final key = side == LanguageSide.source ? 'source_lang' : 'target_lang';
    await ref.read(settingsChannelProvider).set(key, code);
    final next = side == LanguageSide.source
        ? current.copyWith(source: code)
        : current.copyWith(target: code);
    state = AsyncData(
      next.copyWith(models: await _models(next.source, next.target)),
    );
  }
}
