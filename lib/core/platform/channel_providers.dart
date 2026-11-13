import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models_channel.dart';
import 'permissions_channel.dart';
import 'service_channel.dart';
import 'settings_channel.dart';

// Tests override these with fakes (test/fakes/).
final settingsChannelProvider = Provider<SettingsChannel>(
  (ref) => MethodSettingsChannel(),
);

final permissionsChannelProvider = Provider<PermissionsChannel>(
  (ref) => MethodPermissionsChannel(),
);

final serviceChannelProvider = Provider<ServiceChannel>(
  (ref) => MethodServiceChannel(),
);

final modelsChannelProvider = Provider<ModelsChannel>(
  (ref) => MethodModelsChannel(),
);
