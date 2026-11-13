import 'package:ambatrans/core/widgets/hero_card.dart';
import 'package:ambatrans/core/widgets/pill_button.dart';
import 'package:ambatrans/core/widgets/status_chip.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

HeroCard _hero() => HeroCard(
  label: 'Layanan terjemahan layar',
  value: 'Aktif',
  chip: const StatusChip('English → Indonesia'),
  action: PillButton(
    label: 'Berhenti',
    variant: PillButtonVariant.tonal,
    expand: true,
    onPressed: () {},
  ),
);

void main() {
  testWidgets('shows label, value, chip and action', (tester) async {
    await pumpApp(tester, _hero());
    expect(find.text('Layanan terjemahan layar'), findsOneWidget);
    expect(find.text('Aktif'), findsOneWidget);
    expect(find.text('English → Indonesia'), findsOneWidget);
    expect(find.text('Berhenti'), findsOneWidget);
  });

  testWidgets('chip and action are optional', (tester) async {
    await pumpApp(
      tester,
      const HeroCard(label: 'Layanan', value: 'Tidak aktif'),
    );
    expect(find.text('Tidak aktif'), findsOneWidget);
  });

  testWidgets('semantic label reads label and value together', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, _hero());
    expect(
      find.bySemanticsLabel('Layanan terjemahan layar, Aktif'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('does not clip at 200% font scale', (tester) async {
    await pumpApp(tester, _hero(), textScale: 2);
    expect(tester.takeException(), isNull);
  });
}
