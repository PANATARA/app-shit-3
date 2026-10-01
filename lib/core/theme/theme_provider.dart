import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

class AppThemeNotifier extends Notifier<String> {
  static const _prefKey = 'app_theme';

  @override
  String build() {
    _loadTheme();
    return AppColors.currentPalette.id;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_prefKey) ?? 'warm';
    if (appThemePalettes.containsKey(savedTheme) && savedTheme != state) {
      AppColors.applyTheme(savedTheme);
      state = savedTheme;
    }
  }

  Future<void> setTheme(String themeId) async {
    if (!appThemePalettes.containsKey(themeId)) return;
    AppColors.applyTheme(themeId);
    state = themeId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, themeId);
  }
}

final appThemeProvider = NotifierProvider<AppThemeNotifier, String>(AppThemeNotifier.new);
