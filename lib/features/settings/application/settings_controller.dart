import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/languages.dart';
import '../../../core/platform/channel_providers.dart';
import '../../../core/platform/models_channel.dart';
import '../../../core/platform/settings_channel.dart';

/// Translation engines (ADR-024). [id] is the stored `translate_engine` value.
enum TranslationEngine {
  mlkit('mlkit'),
  deepl('deepl'),
  groq('groq');

  const TranslationEngine(this.id);

  final String id;

  bool get online => this != mlkit;

  static TranslationEngine fromId(Object? id) =>
      values.firstWhere((e) => e.id == id, orElse: () => mlkit);
}

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
    this.overlayBgOpacity = defaultOverlayBgOpacity,
    this.engine = TranslationEngine.mlkit,
    this.apiKeys = const {},
    this.groqModel = defaultGroqModel,
  });

  static const defaultGroqModel = 'llama-3.3-70b-versatile';
  static const defaultOverlayTextColor = 0xFFFFFF;
  static const defaultOverlayBgColor = 0x424242;
  static const defaultOverlayBgOpacity = 100;

  final String source;
  final String target;
  final ModelStatus models;
  final bool overlayGranted;
  final bool notificationsGranted;

  /// Overlay label colours as 0xRRGGBB (docs/DATABASE.md).
  final int overlayTextColor;
  final int overlayBgColor;

  /// Background opacity in percent (0–100).
  final int overlayBgOpacity;

  final TranslationEngine engine;

  /// Saved API key per online engine; kept when switching engines.
  final Map<TranslationEngine, String> apiKeys;
  final String groqModel;

  SettingsState copyWith({
    String? source,
    String? target,
    ModelStatus? models,
    bool? overlayGranted,
    bool? notificationsGranted,
    int? overlayTextColor,
    int? overlayBgColor,
    int? overlayBgOpacity,
    TranslationEngine? engine,
    Map<TranslationEngine, String>? apiKeys,
    String? groqModel,
  }) => SettingsState(
    source: source ?? this.source,
    target: target ?? this.target,
    models: models ?? this.models,
    overlayGranted: overlayGranted ?? this.overlayGranted,
    notificationsGranted: notificationsGranted ?? this.notificationsGranted,
    overlayTextColor: overlayTextColor ?? this.overlayTextColor,
    overlayBgColor: overlayBgColor ?? this.overlayBgColor,
    overlayBgOpacity: overlayBgOpacity ?? this.overlayBgOpacity,
    engine: engine ?? this.engine,
    apiKeys: apiKeys ?? this.apiKeys,
    groqModel: groqModel ?? this.groqModel,
  );
}

enum LanguageSide { source, target }

/// Overlay label settings, each stored as an int under [key].
enum OverlayStyle {
  textColor('overlay_text_color'),
  bgColor('overlay_bg_color'),
  bgOpacity('overlay_bg_opacity');

  const OverlayStyle(this.key);

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
      overlayBgOpacity:
          all['overlay_bg_opacity'] as int? ??
          SettingsState.defaultOverlayBgOpacity,
      engine: TranslationEngine.fromId(all['translate_engine']),
      apiKeys: {
        for (final e in TranslationEngine.values.where((e) => e.online))
          e: all['${e.id}_api_key'] as String? ?? '',
      },
      groqModel: all['groq_model'] as String? ?? SettingsState.defaultGroqModel,
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

  Future<void> setOverlayStyle(OverlayStyle style, int value) async {
    final current = state.requireValue;
    await ref.read(settingsChannelProvider).set(style.key, value);
    state = AsyncData(switch (style) {
      OverlayStyle.textColor => current.copyWith(overlayTextColor: value),
      OverlayStyle.bgColor => current.copyWith(overlayBgColor: value),
      OverlayStyle.bgOpacity => current.copyWith(overlayBgOpacity: value),
    });
  }

  /// Saves the key (and model) first, then switches to [engine], so an online
  /// engine is never active without its key. Throws [InvalidValueException].
  Future<void> setEngine(
    TranslationEngine engine, {
    String? apiKey,
    String? model,
  }) async {
    final settings = ref.read(settingsChannelProvider);
    final current = state.requireValue;
    if (apiKey != null) await settings.set('${engine.id}_api_key', apiKey);
    if (model != null) await settings.set('groq_model', model);
    await settings.set('translate_engine', engine.id);
    state = AsyncData(
      current.copyWith(
        engine: engine,
        apiKeys: apiKey == null
            ? null
            : {...current.apiKeys, engine: apiKey.trim()},
        groqModel: model?.trim(),
      ),
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
