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
  });

  final String source;
  final String target;
  final ModelStatus models;

  SettingsState copyWith({
    String? source,
    String? target,
    ModelStatus? models,
  }) => SettingsState(
    source: source ?? this.source,
    target: target ?? this.target,
    models: models ?? this.models,
  );
}

enum LanguageSide { source, target }

/// Language codes offered in the picker, sorted by their Indonesian display name.
final supportedLanguagesProvider = FutureProvider<List<String>>((ref) async {
  List<String> codes;
  try {
    codes = await ref.read(modelsChannelProvider).getSupportedLanguages();
  } on PlatformException {
    codes = const [];
  }
  if (codes.isEmpty) codes = Languages.codes.toList();
  return [...codes]
    ..sort((a, b) => Languages.nameOf(a).compareTo(Languages.nameOf(b)));
});

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
    return SettingsState(
      source: source,
      target: target,
      models: await _models(source, target),
    );
  }

  Future<ModelStatus> _models(String source, String target) async {
    try {
      return await ref.read(modelsChannelProvider).getStatus(source, target);
    } on PlatformException {
      return const ModelStatus(ready: false, missing: []);
    }
  }

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
