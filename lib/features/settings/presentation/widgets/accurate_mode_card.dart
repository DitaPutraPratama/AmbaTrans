import 'package:material_ui/material_ui.dart';

import '../../../../core/strings.dart';
import 'switch_card.dart';

/// "Mode akurat" switch with a short description.
class AccurateModeCard extends StatelessWidget {
  const AccurateModeCard({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchCard(
    title: Strings.accurateMode,
    description: Strings.accurateModeDescription,
    value: enabled,
    onChanged: onChanged,
  );
}
