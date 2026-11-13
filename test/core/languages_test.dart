import 'package:ambatrans/core/languages.dart';
import 'package:ambatrans/core/strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('covers the 59 ML Kit translation languages', () {
    expect(Languages.codes.length, 59);
    expect(Languages.codes.toSet().length, 59);
  });

  test('default pair has Indonesian names', () {
    expect(Languages.nameOf('en'), 'Inggris');
    expect(Languages.nameOf('id'), 'Indonesia');
  });

  test('auto maps to the detect-automatically label', () {
    expect(Languages.nameOf(Languages.auto), Strings.autoDetect);
  });

  test('unknown code is returned unchanged', () {
    expect(Languages.nameOf('xx'), 'xx');
  });

  test('every code has a non-empty name different from the code', () {
    for (final code in Languages.codes) {
      final name = Languages.nameOf(code);
      expect(name, isNotEmpty);
      expect(name, isNot(code));
    }
  });
}
