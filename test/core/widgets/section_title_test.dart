import 'package:ambatrans/core/widgets/section_title.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('shows text as a semantic header', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, const SectionTitle('Perlu diperhatikan'));
    expect(find.text('Perlu diperhatikan'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Perlu diperhatikan')),
      matchesSemantics(label: 'Perlu diperhatikan', isHeader: true),
    );
    handle.dispose();
  });

  testWidgets('wraps at 200% font scale without overflow', (tester) async {
    await pumpApp(
      tester,
      const SectionTitle('Judul bagian yang cukup panjang untuk membungkus'),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
