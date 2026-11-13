import 'package:ambatrans/app/theme.dart';
import 'package:ambatrans/core/widgets/pastel_icon_tile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  for (final size in PastelTileSize.values) {
    testWidgets('$size is ${size.dimension} dp square', (tester) async {
      await pumpApp(
        tester,
        PastelIconTile(
          icon: Icons.translate_rounded,
          colors: AppPastels.blue,
          size: size,
        ),
      );
      final box = tester.getSize(find.byType(PastelIconTile));
      expect(box, Size.square(size.dimension));
    });
  }

  testWidgets('badge shows check for ok and exclamation for warning', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const Column(
        children: [
          PastelIconTile(
            icon: Icons.layers_rounded,
            colors: AppPastels.green,
            badge: PastelBadge.ok,
          ),
          PastelIconTile(
            icon: Icons.layers_rounded,
            colors: AppPastels.orange,
            badge: PastelBadge.warning,
          ),
          PastelIconTile(icon: Icons.layers_rounded, colors: AppPastels.teal),
        ],
      ),
    );
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.priority_high_rounded), findsOneWidget);
  });
}
