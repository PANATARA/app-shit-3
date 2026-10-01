import 'package:flutter/material.dart';

class AppThemePalette {
  final String id;
  final String name;
  final String description;
  final List<String> previewColors;
  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentLight;
  final Color accentSoft;
  final Color border;
  final Color borderSubtle;
  final Color divider;
  final bool isDark;

  const AppThemePalette({
    required this.id,
    required this.name,
    required this.description,
    required this.previewColors,
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentLight,
    required this.accentSoft,
    required this.border,
    required this.borderSubtle,
    required this.divider,
    required this.isDark,
  });
}

final Map<String, AppThemePalette> appThemePalettes = {
  'warm': const AppThemePalette(
    id: 'warm',
    name: 'Тёплый семейный уют',
    description: 'Светлая, тёплая и домашняя атмосфера',
    previewColors: ['#FAF7F2', '#E06A47', '#5A9E6F'],
    bg: Color(0xFFFAF7F2),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF4EFEA),
    textPrimary: Color(0xFF231F20),
    textSecondary: Color(0xFF5D5350),
    textMuted: Color(0xFF938884),
    accent: Color(0xFFE06A47),
    accentLight: Color(0xFFEA8062),
    accentSoft: Color(0x1FE06A47),
    border: Color(0x38938884),
    borderSubtle: Color(0x24938884),
    divider: Color(0x1A938884),
    isDark: false,
  ),
  'soft': const AppThemePalette(
    id: 'soft',
    name: 'Нежность и забота',
    description: 'Пастельные пудровые оттенки и гармония',
    previewColors: ['#FDF7F8', '#E25275', '#6B8AF0'],
    bg: Color(0xFFFDF7F8),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF9ECF0),
    textPrimary: Color(0xFF24181F),
    textSecondary: Color(0xFF684B5B),
    textMuted: Color(0xFF9E8090),
    accent: Color(0xFFE25275),
    accentLight: Color(0xFFF06E8E),
    accentSoft: Color(0x1FE25275),
    border: Color(0x389E8090),
    borderSubtle: Color(0x249E8090),
    divider: Color(0x1A9E8090),
    isDark: false,
  ),
  'night': const AppThemePalette(
    id: 'night',
    name: 'Уютный вечер дома',
    description: 'Мягкая тёмная тема для вечернего комфорта',
    previewColors: ['#17151B', '#221E27', '#FF9A6C'],
    bg: Color(0xFF17151B),
    surface: Color(0xFF221E27),
    surfaceAlt: Color(0xFF2D2734),
    textPrimary: Color(0xFFF5EFEB),
    textSecondary: Color(0xFFB8ADB7),
    textMuted: Color(0xFF827785),
    accent: Color(0xFFFF9A6C),
    accentLight: Color(0xFFFFB28E),
    accentSoft: Color(0x26FF9A6C),
    border: Color(0x26FFFFFF),
    borderSubtle: Color(0x1AFFFFFF),
    divider: Color(0x12FFFFFF),
    isDark: true,
  ),
  'royal': const AppThemePalette(
    id: 'royal',
    name: 'Свежесть и гармония',
    description: 'Чистая прохладная лазурная гамма',
    previewColors: ['#F2F8FC', '#2D72D9', '#0891B2'],
    bg: Color(0xFFF2F8FC),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFE6F1FA),
    textPrimary: Color(0xFF0D1C34),
    textSecondary: Color(0xFF3D5477),
    textMuted: Color(0xFF788EA8),
    accent: Color(0xFF2D72D9),
    accentLight: Color(0xFF4B8CF2),
    accentSoft: Color(0x1F2D72D9),
    border: Color(0x38788EA8),
    borderSubtle: Color(0x24788EA8),
    divider: Color(0x1A788EA8),
    isDark: false,
  ),
  'sage': const AppThemePalette(
    id: 'sage',
    name: 'Лесной оазис',
    description: 'Успокаивающие шалфейные и травяные тона',
    previewColors: ['#F3F6F3', '#2E7D52', '#4E9F6A'],
    bg: Color(0xFFF3F6F3),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFE7EFE8),
    textPrimary: Color(0xFF18241B),
    textSecondary: Color(0xFF495E4D),
    textMuted: Color(0xFF7E9482),
    accent: Color(0xFF2E7D52),
    accentLight: Color(0xFF439969),
    accentSoft: Color(0x1F2E7D52),
    border: Color(0x387E9482),
    borderSubtle: Color(0x247E9482),
    divider: Color(0x1A7E9482),
    isDark: false,
  ),
  'midnight': const AppThemePalette(
    id: 'midnight',
    name: 'Северное сияние',
    description: 'Глубокая ночная гамма с акцентом индиго',
    previewColors: ['#0E121A', '#161C26', '#6366F1'],
    bg: Color(0xFF0E121A),
    surface: Color(0xFF161C26),
    surfaceAlt: Color(0xFF1F2735),
    textPrimary: Color(0xFFF0F4FC),
    textSecondary: Color(0xFFA0B0C6),
    textMuted: Color(0xFF697A92),
    accent: Color(0xFF6366F1),
    accentLight: Color(0xFF818CF8),
    accentSoft: Color(0x266366F1),
    border: Color(0x24FFFFFF),
    borderSubtle: Color(0x18FFFFFF),
    divider: Color(0x10FFFFFF),
    isDark: true,
  ),
  'amber': const AppThemePalette(
    id: 'amber',
    name: 'Медовый полдень',
    description: 'Солнечная золотисто-янтарная гамма и тепло',
    previewColors: ['#FAF7EE', '#D97706', '#F59E0B'],
    bg: Color(0xFFFAF7EE),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF4EEDC),
    textPrimary: Color(0xFF282015),
    textSecondary: Color(0xFF66553B),
    textMuted: Color(0xFF9E8867),
    accent: Color(0xFFD97706),
    accentLight: Color(0xFFF59E0B),
    accentSoft: Color(0x1FD97706),
    border: Color(0x389E8867),
    borderSubtle: Color(0x249E8867),
    divider: Color(0x1A9E8867),
    isDark: false,
  ),
};

class AppColors {
  AppColors._();

  static AppThemePalette currentPalette = appThemePalettes['warm']!;

  static void applyTheme(String themeId) {
    currentPalette = appThemePalettes[themeId] ?? appThemePalettes['warm']!;
  }

  static Color get primary => currentPalette.accent;
  static Color get primaryLight => currentPalette.accentLight;
  static Color get primarySoft => currentPalette.accentSoft;

  static Color get background => currentPalette.bg;
  static Color get surface => currentPalette.surface;
  static Color get surfaceAlt => currentPalette.surfaceAlt;

  static Color get textPrimary => currentPalette.textPrimary;
  static Color get textSecondary => currentPalette.textSecondary;
  static Color get textMuted => currentPalette.textMuted;

  static Color get border => currentPalette.border;
  static Color get borderSubtle => currentPalette.borderSubtle;
  static Color get divider => currentPalette.divider;

  static Color get navBackground => currentPalette.surface;
  static Color get navActive => currentPalette.accent;
  static Color get navInactive => currentPalette.textMuted;
  static Color get navActiveBg => currentPalette.accentSoft;

  static const Color success = Color(0xFF4E9F6A);
  static const Color successSoft = Color(0x244E9F6A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFE25275);

  static const Color member1 = Color(0xFFE06A47);
  static const Color member2 = Color(0xFF4E9F6A);
  static const Color member3 = Color(0xFF3D82C4);
  static const Color member4 = Color(0xFF9A69B5);
  static const Color member5 = Color(0xFFD68A36);
  static const Color member6 = Color(0xFFE25275);
}
