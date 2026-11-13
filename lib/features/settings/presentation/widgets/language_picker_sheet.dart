import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../../../core/languages.dart';
import '../../../../core/strings.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/selectable_card.dart';
import '../../application/settings_controller.dart';

/// S-04: searchable language list. Pops with the chosen code.
class LanguagePickerSheet extends ConsumerStatefulWidget {
  const LanguagePickerSheet({
    super.key,
    required this.side,
    required this.selected,
    required this.other,
  });

  final LanguageSide side;

  /// Currently selected code for this side.
  final String selected;

  /// Code chosen on the other side; shown disabled.
  final String other;

  @override
  ConsumerState<LanguagePickerSheet> createState() =>
      _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends ConsumerState<LanguagePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isSource = widget.side == LanguageSide.source;
    final languages = ref.watch(supportedLanguagesProvider);
    return AppBottomSheet(
      icon: Icons.translate_rounded,
      iconColors: AppPastels.blue,
      title: isSource ? Strings.sourceLanguage : Strings.targetLanguage,
      subtitle: isSource
          ? Strings.sourceSheetSubtitle
          : Strings.targetSheetSubtitle,
      closeLabel: Strings.close,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: Strings.searchLanguageHint,
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (value) => setState(() => _query = value.trim()),
          ),
          const SizedBox(height: AppSpacing.md),
          Flexible(
            child: languages.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: _list,
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(List<String> codes) {
    final query = _query.toLowerCase();
    final shown = codes
        .where((c) => Languages.nameOf(c).toLowerCase().contains(query))
        .toList();
    if (shown.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Center(
          child: Text(
            Strings.languageNotFound,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
    final otherNote = widget.side == LanguageSide.source
        ? Strings.alreadyChosenAsTarget
        : Strings.alreadyChosenAsSource;
    return ListView.separated(
      shrinkWrap: true,
      itemCount: shown.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final code = shown[index];
        final isOther = code == widget.other;
        return SelectableCard(
          title: Languages.nameOf(code),
          subtitle: isOther ? otherNote : null,
          selected: code == widget.selected,
          enabled: !isOther,
          onTap: () => Navigator.of(context).pop(code),
        );
      },
    );
  }
}
