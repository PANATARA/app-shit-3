import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => getTheme('warm');

  static ThemeData getTheme(String themeId) {
    final palette = appThemePalettes[themeId] ?? appThemePalettes['warm']!;
    AppColors.applyTheme(palette.id);

    final baseTextTheme = GoogleFonts.interTextTheme();
    final brightness = palette.isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.bg,
      colorScheme: palette.isDark
          ? ColorScheme.dark(
              primary: palette.accent,
              onPrimary: Colors.white,
              secondary: palette.accentLight,
              onSecondary: Colors.white,
              surface: palette.surface,
              onSurface: palette.textPrimary,
              error: AppColors.error,
              onError: Colors.white,
            )
          : ColorScheme.light(
              primary: palette.accent,
              onPrimary: Colors.white,
              secondary: palette.accentLight,
              onSecondary: Colors.white,
              surface: palette.surface,
              onSurface: palette.textPrimary,
              error: AppColors.error,
              onError: Colors.white,
            ),
      splashColor: palette.accent.withValues(alpha: 0.08),
      highlightColor: palette.accent.withValues(alpha: 0.04),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        clipBehavior: Clip.none,
        showDragHandle: false,
      ),
      dividerTheme: DividerThemeData(
        color: palette.borderSubtle,
        thickness: 0.5,
        space: 0.5,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: palette.textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: palette.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: -0.4,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: palette.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: -0.3,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          color: palette.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: -0.2,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: palette.textPrimary,
          fontSize: 16,
          letterSpacing: -0.15,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: palette.textSecondary,
          fontSize: 14,
          letterSpacing: -0.1,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: palette.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          color: palette.textMuted,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: palette.borderSubtle, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: GoogleFonts.inter(
          color: palette.textMuted,
          fontSize: 14,
        ),
      ),
    );
  }
}
