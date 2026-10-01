import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LanguageOption {
  final String code;
  final String nativeName;
  final String englishName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.flag,
  });
}

const List<LanguageOption> allLanguages = [
  LanguageOption(
    code: 'ru',
    nativeName: 'Русский',
    englishName: 'Russian',
    flag: '🇷🇺',
  ),
  LanguageOption(
    code: 'en',
    nativeName: 'English',
    englishName: 'English',
    flag: '🇬🇧',
  ),
];

class LangModalSheet extends StatefulWidget {
  final String currentCode;
  final ValueChanged<String>? onLanguageSelected;

  const LangModalSheet({
    super.key,
    this.currentCode = 'ru',
    this.onLanguageSelected,
  });

  static Future<String?> show(BuildContext context, {String currentCode = 'ru'}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LangModalSheet(currentCode: currentCode),
    );
  }

  @override
  State<LangModalSheet> createState() => _LangModalSheetState();
}

class _LangModalSheetState extends State<LangModalSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentCode;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                'Выбор языка',
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
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Выберите удобный язык для работы с приложением',
              style: TextStyle(fontSize: 13.5, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 16),

          // Languages list
          ...allLanguages.map((lang) {
            final isSelected = lang.code == _selected;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selected = lang.code);
                  widget.onLanguageSelected?.call(lang.code);
                  Navigator.of(context).pop(lang.code);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(14),
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
                      // Flag
                      Text(lang.flag, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 14),

                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.nativeName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (lang.code != _selected)
                              Text(
                                lang.englishName,
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                          ],
                        ),
                      ),

                      // Radio indicator
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
              ),
            );
          }),
        ],
      ),
    );
  }
}
