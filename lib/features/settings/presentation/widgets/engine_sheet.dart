import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/platform/settings_channel.dart';
import '../../../../core/strings.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../../core/widgets/selectable_card.dart';
import '../../application/settings_controller.dart';

const _deeplKeysUrl = 'https://www.deepl.com/your-account/keys';
const _groqKeysUrl = 'https://console.groq.com/keys';
const _groqModelsUrl = 'https://console.groq.com/docs/models';

Future<void> showEngineSheet(BuildContext context) => showAppBottomSheet<void>(
  context: context,
  builder: (_) => const EngineSheet(),
);

extension TranslationEngineLabel on TranslationEngine {
  String get label => switch (this) {
    TranslationEngine.mlkit => Strings.engineMlkit,
    TranslationEngine.deepl => Strings.engineDeepl,
    TranslationEngine.groq => Strings.engineGroq,
  };

  String get body => switch (this) {
    TranslationEngine.mlkit => Strings.engineMlkitBody,
    TranslationEngine.deepl => Strings.engineDeeplBody,
    TranslationEngine.groq => Strings.engineGroqBody,
  };
}

/// Pick the engine; online engines ask for their API key (and model for AI).
/// Saved keys stay, so switching back needs no retyping.
class EngineSheet extends ConsumerStatefulWidget {
  const EngineSheet({super.key});

  @override
  ConsumerState<EngineSheet> createState() => _EngineSheetState();
}

class _EngineSheetState extends ConsumerState<EngineSheet> {
  late final SettingsState _initial = ref
      .read(settingsControllerProvider)
      .requireValue;
  late TranslationEngine _engine = _initial.engine;
  late final Map<TranslationEngine, TextEditingController> _keys = {
    for (final e in TranslationEngine.values.where((e) => e.online))
      e: TextEditingController(text: _initial.apiKeys[e] ?? ''),
  };
  late final _model = TextEditingController(text: _initial.groqModel);
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in _keys.values) {
      c.dispose();
    }
    _model.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final key = _keys[_engine]?.text.trim();
    final model = _engine == TranslationEngine.groq ? _model.text.trim() : null;
    final error = key != null && key.isEmpty
        ? Strings.apiKeyRequired
        : (model != null && model.isEmpty ? Strings.modelRequired : null);
    setState(() => _error = error);
    if (error != null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(settingsControllerProvider.notifier)
          .setEngine(_engine, apiKey: key, model: model);
      if (mounted) Navigator.of(context).pop();
    } on InvalidValueException {
      setState(() => _error = Strings.settingsSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      icon: Icons.auto_awesome_rounded,
      iconColors: AppPastels.purple,
      title: Strings.engineSection,
      subtitle: Strings.engineSheetSubtitle,
      closeLabel: Strings.close,
      actions: [
        PillButton(
          label: Strings.save,
          expand: true,
          loading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final e in TranslationEngine.values) ...[
              SelectableCard(
                title: e.label,
                subtitle: e.body,
                selected: e == _engine,
                onTap: () => setState(() {
                  _engine = e;
                  _error = null;
                }),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (_engine.online) ..._onlineFields(context),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: context.colors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _onlineFields(BuildContext context) {
    final small = Theme.of(context).textTheme.bodySmall;
    final isGroq = _engine == TranslationEngine.groq;
    return [
      const SizedBox(height: AppSpacing.sm),
      TextField(
        key: const Key('api-key-field'),
        controller: _keys[_engine],
        obscureText: true,
        autocorrect: false,
        enableSuggestions: false,
        decoration: const InputDecoration(
          labelText: Strings.apiKey,
          prefixIcon: Icon(Icons.key_rounded),
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      SelectableText(
        Strings.getApiKeyAt(isGroq ? _groqKeysUrl : _deeplKeysUrl),
        style: small,
      ),
      if (isGroq) ...[
        const SizedBox(height: AppSpacing.md),
        TextField(
          key: const Key('model-field'),
          controller: _model,
          autocorrect: false,
          enableSuggestions: false,
          decoration: const InputDecoration(
            labelText: Strings.aiModel,
            prefixIcon: Icon(Icons.memory_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SelectableText(Strings.modelListAt(_groqModelsUrl), style: small),
      ],
      const SizedBox(height: AppSpacing.md),
      Text(Strings.sentOnline(isGroq ? 'Groq' : 'DeepL'), style: small),
    ];
  }
}
