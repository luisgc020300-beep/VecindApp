// lib/theme/design_tokens.dart
//
// Identidad visual de VecindApp -- limpia y neutra, pensada para un público
// amplio (desde un vecino de 70 años hasta un administrador de fincas).
// Fuente nativa del sistema (SF Pro en iPhone, Roboto en Android) desde el
// principio -- nunca una fuente descargada: así se siente "de app", no de
// página web (lección de Repara, octubre 2026).
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

class VecindColors extends ThemeExtension<VecindColors> {
  const VecindColors({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.brand,
    required this.brandStrong,
    required this.brandOn,
    required this.brandTint,
    required this.success,
    required this.warning,
    required this.warningText,
    required this.error,
  });

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color ink;
  final Color inkMuted;
  final Color inkFaint;
  final Color brand;
  final Color brandStrong;
  final Color brandOn;
  final Color brandTint;
  final Color success;
  final Color warning;
  final Color warningText;
  final Color error;

  static const light = VecindColors(
    background: Color(0xFFF5F6F8),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEDEFF3),
    ink: Color(0xFF1C1E21),
    inkMuted: Color(0xFF6B7280),
    inkFaint: Color(0xFF9CA3AF),
    brand: Color(0xFF2563EB),
    brandStrong: Color(0xFF1E4FC4),
    brandOn: Color(0xFFFFFFFF),
    brandTint: Color(0x1F2563EB),
    success: Color(0xFF2E7D4F),
    warning: Color(0xFFB8842E),
    warningText: Color(0xFF8A6220),
    error: Color(0xFFC03B3B),
  );

  static const dark = VecindColors(
    background: Color(0xFF15171A),
    surface: Color(0xFF1E2024),
    surfaceMuted: Color(0xFF26292E),
    ink: Color(0xFFF2F3F5),
    inkMuted: Color(0xFFA3A8B0),
    inkFaint: Color(0xFF7A7F88),
    brand: Color(0xFF5B8DEF),
    brandStrong: Color(0xFF7FA4F3),
    brandOn: Color(0xFF0B1220),
    brandTint: Color(0x265B8DEF),
    success: Color(0xFF5CB885),
    warning: Color(0xFFD9A548),
    warningText: Color(0xFFF0C07A),
    error: Color(0xFFE0776A),
  );

  @override
  VecindColors copyWith({
    Color? background, Color? surface, Color? surfaceMuted,
    Color? ink, Color? inkMuted, Color? inkFaint,
    Color? brand, Color? brandStrong, Color? brandOn, Color? brandTint,
    Color? success, Color? warning, Color? warningText, Color? error,
  }) {
    return VecindColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkFaint: inkFaint ?? this.inkFaint,
      brand: brand ?? this.brand,
      brandStrong: brandStrong ?? this.brandStrong,
      brandOn: brandOn ?? this.brandOn,
      brandTint: brandTint ?? this.brandTint,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      warningText: warningText ?? this.warningText,
      error: error ?? this.error,
    );
  }

  @override
  VecindColors lerp(ThemeExtension<VecindColors>? other, double t) {
    if (other is! VecindColors) return this;
    return t < 0.5 ? this : other;
  }
}

class VecindRadius {
  VecindRadius._();
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double pill = 999;
}

class VecindSpace {
  VecindSpace._();
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
}

extension VecindThemeContextX on BuildContext {
  VecindColors get colors => Theme.of(this).extension<VecindColors>()!;
}

class VecindText {
  VecindText._();

  static String get fontFamily => defaultTargetPlatform == TargetPlatform.iOS ? '.SF Pro Text' : 'Roboto';

  static TextTheme uiTextTheme(Brightness brightness) {
    final base = brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final palette = brightness == Brightness.dark ? VecindColors.dark : VecindColors.light;
    final sistema = base.apply(fontFamily: fontFamily, bodyColor: palette.ink, displayColor: palette.ink);
    TextStyle display(double size, double height) => TextStyle(
          fontFamily: fontFamily,
          color: palette.ink,
          fontSize: size,
          height: height / size,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        );
    return sistema.copyWith(
      displayMedium: display(28, 34),
      displaySmall: display(22, 28),
      headlineSmall: display(18, 24),
      labelSmall: sistema.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.6),
      bodyLarge: sistema.bodyLarge?.copyWith(fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w400),
      titleMedium: sistema.titleMedium?.copyWith(fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w600),
      bodySmall: sistema.bodySmall?.copyWith(fontSize: 12.5, height: 17 / 12.5, fontWeight: FontWeight.w500, color: palette.inkMuted),
      labelLarge: sistema.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
    );
  }
}

ThemeData _buildVecindTheme(Brightness brightness) {
  final palette = brightness == Brightness.dark ? VecindColors.dark : VecindColors.light;
  final textTheme = VecindText.uiTextTheme(brightness);
  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: palette.background,
    textTheme: textTheme,
    extensions: [palette],
    colorScheme: ColorScheme(
      brightness: brightness,
      surface: palette.surface,
      onSurface: palette.ink,
      primary: palette.brand,
      onPrimary: palette.brandOn,
      secondary: palette.brand,
      onSecondary: palette.brandOn,
      tertiary: palette.success,
      onTertiary: Colors.white,
      error: palette.error,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      foregroundColor: palette.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontFamily: VecindText.fontFamily, color: palette.ink, fontSize: 20, fontWeight: FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      color: palette.surface,
      elevation: 1,
      shadowColor: palette.ink.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VecindRadius.md),
        side: BorderSide(color: palette.ink.withValues(alpha: 0.06)),
      ),
    ),
    dividerColor: palette.inkMuted.withValues(alpha: 0.15),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surfaceMuted,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(VecindRadius.sm), borderSide: BorderSide.none),
      hintStyle: TextStyle(color: palette.inkMuted.withValues(alpha: 0.8)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.brand,
        foregroundColor: palette.brandOn,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(VecindRadius.sm)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.brand,
        side: BorderSide(color: palette.brand.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(VecindRadius.sm)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: palette.brand,
      side: BorderSide(color: palette.ink.withValues(alpha: 0.12)),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(color: palette.ink, fontSize: 13, fontWeight: FontWeight.w500),
      secondaryLabelStyle: TextStyle(color: palette.brandOn, fontSize: 13, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: palette.surface,
      selectedItemColor: palette.brand,
      unselectedItemColor: palette.inkFaint,
      type: BottomNavigationBarType.fixed,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: palette.ink,
      contentTextStyle: TextStyle(color: palette.background),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

ThemeData buildVecindLightTheme() => _buildVecindTheme(Brightness.light);
ThemeData buildVecindDarkTheme() => _buildVecindTheme(Brightness.dark);
