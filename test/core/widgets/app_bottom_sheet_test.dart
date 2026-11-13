import 'package:ambatrans/app/theme.dart';
import 'package:ambatrans/core/widgets/app_bottom_sheet.dart';
import 'package:ambatrans/core/widgets/icon_circle_button.dart';
import 'package:ambatrans/core/widgets/pill_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

Widget _opener() => Builder(
  builder: (context) => TextButton(
    onPressed: () => showAppBottomSheet<void>(
      context: context,
      builder: (_) => AppBottomSheet(
        icon: Icons.translate_rounded,
        iconColors: AppPastels.blue,
        title: 'Unduh model bahasa',
        subtitle: 'English dan Indonesia',
        closeLabel: 'Tutup',
        actions: [
          PillButton(label: 'Unduh', expand: true, onPressed: () {}),
          PillButton(
            label: 'Nanti saja',
            variant: PillButtonVariant.text,
            expand: true,
            onPressed: () {},
          ),
        ],
        child: const Text('Isi sheet'),
      ),
    ),
    child: const Text('Buka'),
  ),
);

void main() {
  testWidgets('shows header, body and actions', (tester) async {
    await pumpApp(tester, _opener());
    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    expect(find.text('Unduh model bahasa'), findsOneWidget);
    expect(find.text('English dan Indonesia'), findsOneWidget);
    expect(find.text('Isi sheet'), findsOneWidget);
    expect(find.text('Unduh'), findsOneWidget);
    expect(find.text('Nanti saja'), findsOneWidget);
  });

  testWidgets('close button dismisses the sheet', (tester) async {
    await pumpApp(tester, _opener());
    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Tutup'));
    await tester.pumpAndSettle();
    expect(find.text('Unduh model bahasa'), findsNothing);
  });

  testWidgets('title is a semantic header', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, _opener());
    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Unduh model bahasa')),
      matchesSemantics(label: 'Unduh model bahasa', isHeader: true),
    );
    handle.dispose();
  });

  testWidgets('does not overflow at 200% font scale', (tester) async {
    await pumpApp(tester, _opener(), textScale: 2);
    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('close button can be disabled', (tester) async {
    await pumpApp(
      tester,
      const AppBottomSheet(
        icon: Icons.translate_rounded,
        iconColors: AppPastels.blue,
        title: 'Judul',
        closeLabel: 'Tutup',
        closeEnabled: false,
      ),
    );
    final close = tester.widget<IconCircleButton>(
      find.byType(IconCircleButton),
    );
    expect(close.onPressed, isNull);
  });
}
