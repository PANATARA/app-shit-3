import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household/core/theme/app_colors.dart';
import 'package:household/core/theme/app_theme.dart';
import 'package:household/features/chores/models/chore_item_model.dart';
import 'package:household/features/settings/widgets/theme_modal_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Themes and AppColors tests', () {
    test('All 7 themes from Svelte exist in appThemePalettes', () {
      final expectedThemes = ['warm', 'soft', 'night', 'royal', 'sage', 'midnight', 'amber'];
      for (final t in expectedThemes) {
        expect(appThemePalettes.containsKey(t), isTrue, reason: 'Theme $t should exist');
      }
    });

    test('AppColors.applyTheme switches palette correctly', () {
      AppColors.applyTheme('night');
      expect(AppColors.currentPalette.id, 'night');
      expect(AppColors.currentPalette.isDark, isTrue);

      AppColors.applyTheme('royal');
      expect(AppColors.currentPalette.id, 'royal');
      expect(AppColors.currentPalette.isDark, isFalse);

      // Revert to warm
      AppColors.applyTheme('warm');
      expect(AppColors.currentPalette.id, 'warm');
    });

    test('AppTheme.getTheme generates correct brightness and ColorScheme', () {
      final nightTheme = AppTheme.getTheme('night');
      expect(nightTheme.brightness, Brightness.dark);
      expect(nightTheme.scaffoldBackgroundColor, appThemePalettes['night']!.bg);

      final warmTheme = AppTheme.getTheme('warm');
      expect(warmTheme.brightness, Brightness.light);
      expect(warmTheme.scaffoldBackgroundColor, appThemePalettes['warm']!.bg);
    });

    test('ThemeModalSheet allThemes contains 7 theme options', () {
      expect(allThemes.length, 7);
      final ids = allThemes.map((e) => e.id).toList();
      expect(ids, containsAll(['warm', 'soft', 'night', 'royal', 'sage', 'midnight', 'amber']));
    });
  });

  group('ChoreItem Model tests', () {
    test('ChoreItem fromJson and toJson', () {
      final json = {
        'id': 'test-123',
        'name': 'Помыть посуду',
        'description': 'После ужина',
        'icon': 'material-symbols:dishwasher-gen-rounded',
        'icon_color': '#ffffff',
        'icon_bg': 'linear-gradient(135deg, #8a7f6e 0%, #6b5f50 100%)',
        'valuation': 15,
        'default_chore_id': 'default-1',
      };

      final chore = ChoreItem.fromJson(json);
      expect(chore.id, 'test-123');
      expect(chore.name, 'Помыть посуду');
      expect(chore.description, 'После ужина');
      expect(chore.icon, 'material-symbols:dishwasher-gen-rounded');
      expect(chore.valuation, 15);
      expect(chore.defaultChoreId, 'default-1');

      final serialized = chore.toJson();
      expect(serialized['name'], 'Помыть посуду');
      expect(serialized['default_chore_id'], 'default-1');
    });
  });
}
