import 'package:material_ui/material_ui.dart';

/// Spacing scale (4 dp grid) from docs/DESIGN.md §3.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double screenHorizontal = 16;
  static const double maxContentWidth = 600;
}

/// Corner radii from docs/DESIGN.md §3.
abstract final class AppRadius {
  static const double hero = 28;
  static const double card = 24;
  static const double tile = 20;
  static const double tileLarge = 24;
  static const double selectableCard = 20;
  static const double sheet = 32;
  static const double pill = 999;
}

/// Background and icon colors of a pastel icon tile.
class PastelColors {
  const PastelColors(this.background, this.icon);

  final Color background;
  final Color icon;
}

abstract final class AppPastels {
  static const orange = PastelColors(Color(0xFFFDE7DA), Color(0xFFE8590C));
  static const green = PastelColors(Color(0xFFE3F2D3), Color(0xFF3F8600));
  static const pink = PastelColors(Color(0xFFFADADD), Color(0xFFE0245E));
  static const yellow = PastelColors(Color(0xFFFDEBD3), Color(0xFFE8890C));
  static const blue = PastelColors(Color(0xFFDCEEFF), Color(0xFF0A84D6));
  static const purple = PastelColors(Color(0xFFEAE2FF), Color(0xFF6C47FF));
  static const teal = PastelColors(Color(0xFFD5F3EA), Color(0xFF12A38A));
  static const magenta = PastelColors(Color(0xFFF8DAFB), Color(0xFFC026D3));
}

/// Semantic color tokens; read with `Theme.of(context).extension<AppColors>()!`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryDark,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.outline,
    required this.selectedBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.errorBg,
    required this.onPrimary,
  });

  final Color primary;
  final Color primaryDark;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color outline;
  final Color selectedBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color error;
  final Color errorBg;
  final Color onPrimary;

  static const light = AppColors(
    primary: Color(0xFF0047BB),
    primaryDark: Color(0xFF00285F),
    background: Color(0xFFF2F4F9),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFE9EDF5),
    outline: Color(0xFFD5DAE5),
    selectedBg: Color(0xFFE6EBF7),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF55627A),
    success: Color(0xFF0A7A4F),
    warning: Color(0xFFE8890C),
    error: Color(0xFFC62828),
    errorBg: Color(0xFFFDECEC),
    onPrimary: Color(0xFFFFFFFF),
  );

  static const dark = AppColors(
    primary: Color(0xFF0047BB),
    primaryDark: Color(0xFF00285F),
    background: Color(0xFF0B1220),
    surface: Color(0xFF152033),
    surfaceVariant: Color(0xFF1D2A42),
    outline: Color(0xFF2A3752),
    selectedBg: Color(0xFF1B2B4A),
    textPrimary: Color(0xFFE6EAF2),
    textSecondary: Color(0xFF9AA6BD),
    success: Color(0xFF4CC38A),
    warning: Color(0xFFF2A33A),
    error: Color(0xFFFF8A80),
    errorBg: Color(0xFF3A1A1A),
    onPrimary: Color(0xFFFFFFFF),
  );

  @override
  AppColors copyWith({Color? primary}) => AppColors(
    primary: primary ?? this.primary,
    primaryDark: primaryDark,
    background: background,
    surface: surface,
    surfaceVariant: surfaceVariant,
    outline: outline,
    selectedBg: selectedBg,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    success: success,
    warning: warning,
    error: error,
    errorBg: errorBg,
    onPrimary: onPrimary,
  );

  // ponytail: the two palettes never animate into each other; switch is instant.
  @override
  AppColors lerp(AppColors? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

/// Colors the bubble, menu and overlay always use (native side mirrors these).
abstract final class AppOverlayColors {
  static const label = Color(0xFF424242);
}

abstract final class AppTheme {
  static const fontFamily = 'PlusJakartaSans';

  static ThemeData get light => _build(AppColors.light, Brightness.light);

  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.primary,
      onSecondary: c.onPrimary,
      error: c.error,
      onError: c.onPrimary,
      surface: c.surface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      outline: c.outline,
      surfaceContainerHighest: c.surfaceVariant,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      fontFamily: fontFamily,
      textTheme: _textTheme(c),
      extensions: [c],
    );
  }

  // Roles from docs/DESIGN.md §3 "Tipografi".
  static TextTheme _textTheme(AppColors c) {
    TextStyle style(double size, FontWeight weight, Color color) =>
        TextStyle(fontSize: size, fontWeight: weight, color: color);
    return TextTheme(
      headlineLarge: style(36, FontWeight.w700, c.textPrimary), // hero value
      headlineMedium: style(22, FontWeight.w700, c.textPrimary), // screen title
      titleLarge: style(18, FontWeight.w700, c.textPrimary), // section title
      titleMedium: style(
        16,
        FontWeight.w700,
        c.textPrimary,
      ), // card/sheet title
      bodyMedium: style(14, FontWeight.w400, c.textPrimary), // body
      labelLarge: style(
        14,
        FontWeight.w600,
        c.textPrimary,
      ), // tile label, button
      bodySmall: style(12, FontWeight.w400, c.textSecondary), // caption
    );
  }
}
