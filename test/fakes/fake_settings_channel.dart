import 'package:ambatrans/core/platform/settings_channel.dart';

/// In-memory [SettingsChannel] with defaults from docs/DATABASE.md.
/// Enforces only the source != target rule; native tests cover the rest.
class FakeSettingsChannel implements SettingsChannel {
  FakeSettingsChannel([Map<String, Object?>? initial])
    : _data = {
        'schema_version': 1,
        'onboarding_done': false,
        'source_lang': 'en',
        'target_lang': 'id',
        'bubble_edge': 'right',
        'bubble_y_fraction': 0.35,
        ...?initial,
      };

  final Map<String, Object?> _data;

  @override
  Future<Map<String, Object?>> getAll() async => Map.of(_data);

  @override
  Future<void> set(String key, Object value) async {
    final other = switch (key) {
      'source_lang' => _data['target_lang'],
      'target_lang' => _data['source_lang'],
      _ => null,
    };
    if (other != null && other == value) {
      throw InvalidValueException('$key must differ from the other language');
    }
    _data[key] = value;
  }
}
