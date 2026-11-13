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
    this.accessibilityMode = false,
    this.accessibilityEnabledInSystem = false,
  });

  final String source;
  final String target;
  final ModelStatus models;

  /// The user's choice (stored); the real service state is [accessibilityEnabledInSystem].
  final bool accessibilityMode;
  final bool accessibilityEnabledInSystem;

  SettingsState copyWith({
    String? source,
    String? target,
    ModelStatus? models,
    bool? accessibilityMode,
    bool? accessibilityEnabledInSystem,
  }) => SettingsState(
    source: source ?? this.source,
    target: target ?? this.target,
    models: models ?? this.models,
    accessibilityMode: accessibilityMode ?? this.accessibilityMode,
    accessibilityEnabledInSystem:
        accessibilityEnabledInSystem ?? this.accessibilityEnabledInSystem,
  );
}

enum LanguageSide { source, target }

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
      accessibilityMode: all['accessibility_mode'] == true,
      accessibilityEnabledInSystem: permissions.accessibility,
    );
  }

  Future<ModelStatus> _models(String source, String target) async {
    try {
      return await ref.read(modelsChannelProvider).getStatus(source, target);
    } on PlatformException {
      return const ModelStatus(ready: false, missing: []);
    }
  }

  /// Re-reads the system accessibility state (e.g. after returning from system settings).
  Future<void> refreshAccessibility() async {
    final current = state.value;
    if (current == null) return;
    final permissions = await ref.read(permissionsChannelProvider).getStatus();
    state = AsyncData(
      current.copyWith(accessibilityEnabledInSystem: permissions.accessibility),
    );
  }

  Future<void> setAccessibilityMode(bool enabled) async {
    final current = state.requireValue;
    await ref.read(settingsChannelProvider).set('accessibility_mode', enabled);
    state = AsyncData(current.copyWith(accessibilityMode: enabled));
  }

  Future<void> openAccessibilitySettings() =>
      ref.read(permissionsChannelProvider).openAccessibilitySettings();

  Future<void> refreshModels() async {
    final current = state.value;
    if (current == null) return;
    final models = await _models(current.source, current.target);
    state = AsyncData(current.copyWith(models: models));
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
