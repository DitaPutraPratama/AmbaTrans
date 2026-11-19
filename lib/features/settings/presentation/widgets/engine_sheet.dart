import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/platform/settings_channel.dart';
import '../../../../core/strings.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/pill_button.dart';
import '../../../../core/widgets/selectable_card.dart';
import '../../application/settings_controller.dart';
import 'engine_fields.dart';
import 'engine_info.dart';

Future<void> showEngineSheet(BuildContext context) => showAppBottomSheet<void>(
  context: context,
  builder: (_) => const EngineSheet(),
);

/// Pick the engine, grouped offline / free / paid. The key (and model) fields
/// open under the chosen online engine; saved values stay per engine.
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
  late final _keys = {
    for (final e in TranslationEngine.values.where((e) => e.online))
      e: TextEditingController(text: _initial.apiKeys[e] ?? ''),
  };
  late final _models = {
    for (final e in TranslationEngine.values.where((e) => e.hasModel))
      e: TextEditingController(text: _initial.aiModels[e] ?? ''),
  };

  /// Engines whose fields are unlocked: those without a saved key, plus any
  /// the user tapped "Ubah" on.
  late final _editing = {
    for (final e in _keys.keys)
      if ((_initial.apiKeys[e] ?? '').isEmpty) e,
  };
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [..._keys.values, ..._models.values]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final editing = _editing.contains(_engine);
    final key = editing ? _keys[_engine]?.text.trim() : null;
    final model = editing ? _models[_engine]?.text.trim() : null;
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
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      showAppToast(messenger, Strings.engineSaved(_engine.label));
    } on InvalidValueException {
      setState(() => _error = Strings.settingsSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppBottomSheet(
      icon: Icons.auto_awesome_rounded,
      iconColors: AppPastels.purple,
      title: Strings.engineSection,
      subtitle: Strings.engineSheetSubtitle,
      closeLabel: Strings.close,
      actions: [
        if (_error != null)
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: context.colors.error),
          ),
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
            for (final group in EngineGroup.values) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(group.title, style: textTheme.labelLarge),
              ),
              for (final e in TranslationEngine.values.where(
                (e) => e.group == group,
              ))
                ..._engineCard(e),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _engineCard(TranslationEngine e) => [
    SelectableCard(
      title: e.label,
      subtitle: e.note,
      selected: e == _engine,
      onTap: () => setState(() {
        _engine = e;
        _error = null;
      }),
    ),
    // The fields unfold under the chosen card and fold away from the old one.
    AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.reveal),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      child: e == _engine && e.online
          ? Padding(
              key: ValueKey(e),
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: EngineFields(
                engine: e,
                apiKey: _keys[e]!,
                model: _models[e],
                editing: _editing.contains(e),
                onEdit: () => setState(() => _editing.add(e)),
                onOpenUrl: ref
                    .read(settingsControllerProvider.notifier)
                    .openUrl,
              ),
            )
          : const SizedBox(key: ValueKey('none'), width: double.infinity),
    ),
    const SizedBox(height: AppSpacing.sm),
  ];
}
