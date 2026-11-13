import 'package:ambatrans/app/theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  const palettes = {'light': AppColors.light, 'dark': AppColors.dark};

  palettes.forEach((name, c) {
    group('$name palette contrast', () {
      test(
        'primary and secondary text are >= 4.5:1 on background and surface',
        () {
          for (final text in [c.textPrimary, c.textSecondary]) {
            for (final bg in [c.background, c.surface]) {
              expect(_contrast(text, bg), greaterThanOrEqualTo(4.5));
            }
          }
        },
      );

      test('white on primary is >= 7:1', () {
        expect(_contrast(c.onPrimary, c.primary), greaterThanOrEqualTo(7));
      });

      test('status text is >= 4.5:1 on its surface', () {
        expect(_contrast(c.success, c.surface), greaterThanOrEqualTo(4.5));
        expect(_contrast(c.error, c.errorBg), greaterThanOrEqualTo(4.5));
      });
    });
  });

  test('light and dark ThemeData carry their palette', () {
    expect(AppTheme.light.extension<AppColors>(), AppColors.light);
    expect(AppTheme.dark.extension<AppColors>(), AppColors.dark);
    expect(AppTheme.dark.brightness, Brightness.dark);
  });
}
