import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../chores/utils/color_helper.dart';

class ThemeOption {
  final String id;
  final String name;
  final String description;
  final List<String> colors;

  const ThemeOption({
    required this.id,
    required this.name,
    required this.description,
    required this.colors,
  });
}

const List<ThemeOption> allThemes = [
  ThemeOption(
    id: 'warm',
    name: 'Тёплый семейный уют',
    description: 'Светлая, тёплая и домашняя атмосфера',
    colors: ['#FAF7F2', '#E06A47', '#5A9E6F'],
  ),
  ThemeOption(
    id: 'soft',
    name: 'Нежность и забота',
    description: 'Пастельные пудровые оттенки и гармония',
    colors: ['#FDF7F8', '#E25275', '#6B8AF0'],
  ),
  ThemeOption(
    id: 'night',
    name: 'Уютный вечер дома',
    description: 'Мягкая тёмная тема для вечернего комфорта',
    colors: ['#17151B', '#221E27', '#FF9A6C'],
  ),
  ThemeOption(
    id: 'royal',
    name: 'Свежесть и гармония',
    description: 'Чистая прохладная лазурная гамма',
    colors: ['#F2F8FC', '#2D72D9', '#0891B2'],
  ),
  ThemeOption(
    id: 'sage',
    name: 'Лесной оазис',
    description: 'Успокаивающие шалфейные и травяные тона',
    colors: ['#F3F6F3', '#2E7D52', '#4E9F6A'],
  ),
  ThemeOption(
    id: 'midnight',
    name: 'Северное сияние',
    description: 'Глубокая ночная гамма с акцентом индиго',
    colors: ['#0E121A', '#161C26', '#6366F1'],
  ),
  ThemeOption(
    id: 'amber',
    name: 'Медовый полдень',
    description: 'Солнечная золотисто-янтарная гамма и тепло',
    colors: ['#FAF7EE', '#D97706', '#F59E0B'],
  ),
];

class ThemeModalSheet extends StatefulWidget {
  final String currentThemeId;
  final ValueChanged<String>? onThemeSelected;

  const ThemeModalSheet({
    super.key,
    this.currentThemeId = 'warm',
    this.onThemeSelected,
  });

  static Future<String?> show(BuildContext context, {String currentThemeId = 'warm'}) {
    return showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RepaintBoundary(child: ThemeModalSheet(currentThemeId: currentThemeId)),
    );
  }

  @override
  State<ThemeModalSheet> createState() => _ThemeModalSheetState();
}

class _ThemeModalSheetState extends State<ThemeModalSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentThemeId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Выбор темы оформления',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close_rounded, color: AppColors.textMuted),
                visualDensity: VisualDensity.compact,
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Themes list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: allThemes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = allThemes[index];
                final isSelected = item.id == _selected;

                return GestureDetector(
                  onTap: () => setState(() => _selected = item.id),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceAlt : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Colors preview
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: item.colors.map((c) {
                              return Container(
                                width: 10,
                                height: 26,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: ColorHelper.parseHexColor(c),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title & Description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Radio / check indicator
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: isSelected
                              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Apply button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.onThemeSelected?.call(_selected);
                Navigator.of(context).pop(_selected);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                'Применить тему',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
