import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../swr/swr.dart';
import '../../features/settings/repositories/settings_repository.dart';

class AppLocaleNotifier extends Notifier<Locale> {
  static const _prefKey = 'app_language';
  static String _currentLanguage = 'ru';

  /// The active language code (e.g. 'ru' or 'en') for use in synchronous contexts like HTTP interceptors.
  static String get currentLanguage => _currentLanguage;

  static void init(String lang) {
    if (lang == 'ru' || lang == 'en') {
      _currentLanguage = lang;
    }
  }

  @override
  Locale build() {
    _loadLocale();
    return Locale(_currentLanguage);
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString(_prefKey) ?? 'ru';
      if (savedLang != state.languageCode) {
        _currentLanguage = savedLang;
        state = Locale(savedLang);
      }
    } catch (_) {}
  }

  Future<void> setLocale(String languageCode, {bool syncBackend = true}) async {
    if (languageCode != 'ru' && languageCode != 'en') return;
    _currentLanguage = languageCode;
    state = Locale(languageCode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, languageCode);
    } catch (_) {}

    // Invalidate cached chores so they are re-fetched with the new translation
    try {
      Swr.mutate('family-chores');
      Swr.mutate('default-chores');
      Swr.mutate('board-chores:*');
    } catch (_) {}

    if (syncBackend) {
      try {
        await ref
            .read(settingsRepositoryProvider)
            .updateUserSettings(language: languageCode);
      } catch (e) {
        debugPrint('[AppLocaleNotifier] Failed to sync language with backend: $e');
      }
    }
  }
}

final appLocaleProvider =
    NotifierProvider<AppLocaleNotifier, Locale>(AppLocaleNotifier.new);

