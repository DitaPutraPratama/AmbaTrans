import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/strings.dart';
import '../../application/settings_controller.dart';
import 'engine_info.dart';

/// API key (and model) of one online engine. A saved key is read-only until
/// the user taps "Ubah", so a stray tap cannot wreck a working key.
class EngineFields extends StatefulWidget {
  const EngineFields({
    super.key,
    required this.engine,
    required this.apiKey,
    required this.model,
    required this.editing,
    required this.onEdit,
    required this.onOpenUrl,
  });

  final TranslationEngine engine;
  final TextEditingController apiKey;

  /// Null for engines without a model (DeepL).
  final TextEditingController? model;
  final bool editing;
  final VoidCallback onEdit;
  final ValueChanged<String> onOpenUrl;

  @override
  State<EngineFields> createState() => _EngineFieldsState();
}

class _EngineFieldsState extends State<EngineFields> {
  bool _showKey = false;

  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    final model = widget.model;
    final keysUrl = engine.keysUrl;
    final modelsUrl = engine.modelsUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('api-key-field'),
          controller: widget.apiKey,
          readOnly: !widget.editing,
          obscureText: !_showKey,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            hintText: Strings.apiKeyHint,
            prefixIcon: const Icon(Icons.key_rounded),
            suffixIcon: IconButton(
              key: const Key('toggle-key'),
              tooltip: _showKey ? Strings.hideKey : Strings.showKey,
              icon: Icon(
                _showKey
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
              ),
              onPressed: () => setState(() => _showKey = !_showKey),
            ),
          ),
        ),
        if (model != null) ...[
          const SizedBox(height: AppSpacing.sm),
          TextField(
            key: const Key('model-field'),
            controller: model,
            readOnly: !widget.editing,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              hintText: Strings.modelHint,
              prefixIcon: Icon(Icons.memory_rounded),
            ),
          ),
        ],
        Wrap(
          spacing: AppSpacing.xs,
          children: [
            if (!widget.editing)
              TextButton.icon(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text(
                  model == null ? Strings.editKey : Strings.editKeyAndModel,
                ),
              ),
            if (keysUrl != null)
              TextButton.icon(
                onPressed: () => widget.onOpenUrl(keysUrl),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text(Strings.getApiKey),
              ),
            if (modelsUrl != null)
              TextButton.icon(
                onPressed: () => widget.onOpenUrl(modelsUrl),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text(Strings.modelList),
              ),
          ],
        ),
        Text(
          Strings.sentTo(engine.label),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
