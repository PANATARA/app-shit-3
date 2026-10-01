import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../features/chores/utils/color_helper.dart';
import '../features/chores/utils/icon_mapper.dart';

// ─── Value class ─────────────────────────────────────────────────────────────

class AvatarBuilderValue {
  final String icon;
  final String iconColor;
  final String iconBg;

  const AvatarBuilderValue({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  String toString() => 'AvatarBuilderValue(icon: $icon, iconColor: $iconColor, iconBg: $iconBg)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarBuilderValue &&
          runtimeType == other.runtimeType &&
          icon == other.icon &&
          iconColor == other.iconColor &&
          iconBg == other.iconBg;

  @override
  int get hashCode => icon.hashCode ^ iconColor.hashCode ^ iconBg.hashCode;
}

// ─── Icon Category ───────────────────────────────────────────────────────────

class IconCategory {
  final String id;
  final String labelRu;
  final String labelEn;
  final List<String> icons;

  const IconCategory({
    required this.id,
    required this.labelRu,
    required this.labelEn,
    required this.icons,
  });
}

// ─── Presets ─────────────────────────────────────────────────────────────────

const List<IconCategory> allIconCategories = [
  IconCategory(
    id: 'pets',
    labelRu: 'Питомцы',
    labelEn: 'Pets',
    icons: [
      'emojione:dog-face',
      'emojione:cat-face',
      'emojione:hamster-face',
      'emojione:rabbit-face',
      'emojione:fox-face',
      'emojione:pig-face',
      'emojione:mouse-face',
      'emojione:horse-face',
      'emojione:bird',
      'emojione:duck',
      'emojione:rooster',
      'emojione:chicken',
      'emojione:hatching-chick',
      'emojione:lady-beetle',
      'emojione:snail',
      'emojione:fish',
      'emojione:tropical-fish',
      'emojione:blowfish',
      'emojione:turtle',
      'emojione:crocodile',
      'emojione:snake',
      'emojione:dragon-face',
      'emojione:lizard',
      'emojione:spider',
      'emojione:scorpion',
      'emojione:monkey-face',
      'emojione:elephant',
    ],
  ),
  IconCategory(
    id: 'home',
    labelRu: 'Дом',
    labelEn: 'Home',
    icons: [
      'material-symbols:house-rounded',
      'material-symbols:bed-rounded',
      'material-symbols:ac-unit-rounded',
      'material-symbols:electric-bolt-rounded',
      'material-symbols:chair-rounded',
      'material-symbols:coffee-rounded',
      'material-symbols:checkroom-rounded',
      'material-symbols:mode-fan-rounded',
      'material-symbols:shower-rounded',
      'material-symbols:mop-rounded',
      'material-symbols:thermometer-rounded',
      'material-symbols:kitchen-rounded',
      'material-symbols:styler-rounded',
      'material-symbols:yard-rounded',
      'material-symbols:bathtub-rounded',
      'material-symbols:king-bed-rounded',
      'material-symbols:valve-rounded',
      'material-symbols:window-rounded',
      'material-symbols:cooking-rounded',
      'material-symbols:door-front-rounded',
      'material-symbols:garage-rounded',
      'material-symbols:light-rounded',
      'material-symbols:dining-rounded',
      'material-symbols:hardware-rounded',
      'material-symbols:microwave-rounded',
      'material-symbols:oven-gen-rounded',
      'material-symbols:bathroom-rounded',
      'material-symbols:table-bar-rounded',
      'material-symbols:iron-rounded',
      'material-symbols:dishwasher-gen-rounded',
      'material-symbols:faucet-rounded',
      'material-symbols:dresser-rounded',
      'material-symbols:kettle-rounded',
      'material-symbols:vacuum-rounded',
      'material-symbols:oven-rounded',
      'material-symbols:pets-rounded',
    ],
  ),
  IconCategory(
    id: 'people',
    labelRu: 'Люди',
    labelEn: 'People',
    icons: [
      'material-symbols:person-rounded',
      'material-symbols:face',
      'material-symbols:face-2',
      'material-symbols:face-3',
      'material-symbols:face-4',
      'material-symbols:face-5',
      'material-symbols:face-6',
      'material-symbols:boy-rounded',
      'material-symbols:girl-rounded',
      'material-symbols:elderly-rounded',
      'material-symbols:elderly-woman-rounded',
      'material-symbols:account-circle-rounded',
      'material-symbols:face-2-rounded',
      'material-symbols:face-3-rounded',
      'material-symbols:face-4-rounded',
      'material-symbols:face-5-rounded',
      'material-symbols:face-6-rounded',
      'material-symbols:person-2-rounded',
      'material-symbols:person-3-rounded',
      'material-symbols:person-4-rounded',
    ],
  ),
  IconCategory(
    id: 'nature',
    labelRu: 'Природа',
    labelEn: 'Nature',
    icons: [
      'material-symbols:eco-rounded',
      'material-symbols:local-florist-rounded',
      'material-symbols:forest-rounded',
      'material-symbols:grass-rounded',
      'material-symbols:water-drop-rounded',
      'material-symbols:wb-sunny-rounded',
      'material-symbols:thunderstorm-rounded',
      'material-symbols:local-fire-department-rounded',
      'material-symbols:volcano-rounded',
      'material-symbols:mode-night-rounded',
      'material-symbols:star-rounded',
    ],
  ),
  IconCategory(
    id: 'misc',
    labelRu: 'Разное',
    labelEn: 'Misc',
    icons: [
      'material-symbols:favorite-rounded',
      'material-symbols:bolt-rounded',
      'material-symbols:rocket-launch-rounded',
      'material-symbols:diamond-rounded',
      'material-symbols:emoji-events',
      'material-symbols:auto-awesome-rounded',
      'material-symbols:wb-incandescent-rounded',
      'material-symbols:local-activity-rounded',
      'material-symbols:savings-rounded',
    ],
  ),
];

const List<String> allIconColors = [
  '#FFFFFF',
  '#F5E9DA',
  '#FFD166',
  '#FF6B6B',
  '#FF8A5B',
  '#4CC9F0',
  '#2DD4BF',
  '#C77DFF',
  '#A29BFE',
  '#F472B6',
  '#22C55E',
  '#2F2F2F',
  '#E76F51',
  '#60A5FA',
  '#34D399',
  '#FBBF24',
];

const List<String> allBgOptions = [
  // ── Градиенты тёплые ──
  'linear-gradient(135deg, #F97316 0%, #FB7185 100%)',
  'linear-gradient(135deg, #F59E0B 0%, #F97316 100%)',
  'linear-gradient(135deg, #FBBF24 0%, #FB923C 100%)',
  'linear-gradient(135deg, #FB7185 0%, #F43F5E 100%)',
  'linear-gradient(135deg, #FCA5A5 0%, #F59E0B 100%)',
  'linear-gradient(135deg, #FDE68A 0%, #F59E0B 100%)',
  'linear-gradient(135deg, #FDA4AF 0%, #F43F5E 100%)',
  'linear-gradient(135deg, #FF8C42 0%, #FF3C38 100%)',
  'linear-gradient(135deg, #FDBA74 0%, #FB7185 100%)',

  // ── Градиенты холодные ──
  'linear-gradient(135deg, #60A5FA 0%, #3B82F6 100%)',
  'linear-gradient(135deg, #38BDF8 0%, #0EA5E9 100%)',
  'linear-gradient(135deg, #A5B4FC 0%, #6366F1 100%)',
  'linear-gradient(135deg, #67E8F9 0%, #22D3EE 100%)',
  'linear-gradient(135deg, #34D399 0%, #60A5FA 100%)',
  'linear-gradient(135deg, #6EE7B7 0%, #3B82F6 100%)',
  'linear-gradient(135deg, #C4B5FD 0%, #8B5CF6 100%)',
  'linear-gradient(135deg, #A5F3FC 0%, #6366F1 100%)',
  'linear-gradient(135deg, #5EEAD4 0%, #0EA5E9 100%)',

  // ── Градиенты зелёные ──
  'linear-gradient(135deg, #86EFAC 0%, #22C55E 100%)',
  'linear-gradient(135deg, #4ADE80 0%, #16A34A 100%)',
  'linear-gradient(135deg, #BBF7D0 0%, #34D399 100%)',
  'linear-gradient(135deg, #A7F3D0 0%, #059669 100%)',

  // ── Градиенты тёмные ──
  'linear-gradient(135deg, #0F172A 0%, #1E293B 100%)',
  'linear-gradient(135deg, #111827 0%, #374151 100%)',
  'linear-gradient(135deg, #1C1917 0%, #292524 100%)',
  'linear-gradient(135deg, #1E1B4B 0%, #312E81 100%)',
  'linear-gradient(135deg, #134E4A 0%, #0F172A 100%)',
  'linear-gradient(135deg, #3B0764 0%, #1E1B4B 100%)',

  // ── Базовые цвета ──
  '#F59E0B',
  '#F97316',
  '#EF4444',
  '#FB7185',
  '#F472B6',
  '#A78BFA',
  '#8B5CF6',
  '#6366F1',
  '#60A5FA',
  '#38BDF8',
  '#22D3EE',
  '#34D399',
  '#4ADE80',
  '#22C55E',
  '#84CC16',
  '#FACC15',
  '#94A3B8',
  '#64748B',
  '#1E293B',
  '#0F172A',
  '#FFFFFF',
  '#F8FAFC',
  '#F1F5F9',
  '#FEF9EE',
  '#FFF7ED',
];

enum AvatarBuilderTab { icon, iconColor, bg }

// ─── Widget ──────────────────────────────────────────────────────────────────

class AvatarBuilderWidget extends StatefulWidget {
  final String initialIcon;
  final String initialIconColor;
  final String initialBg;
  final bool allowIcon;
  final bool allowIconColor;
  final bool allowBg;
  final List<String>? iconCategories;
  final ValueChanged<AvatarBuilderValue>? onChanged;

  const AvatarBuilderWidget({
    super.key,
    this.initialIcon = 'material-symbols:person-rounded',
    this.initialIconColor = '#ffffff',
    this.initialBg = 'linear-gradient(135deg, #e8856a 0%, #c17a45 100%)',
    this.allowIcon = true,
    this.allowIconColor = true,
    this.allowBg = true,
    this.iconCategories,
    this.onChanged,
  });

  @override
  State<AvatarBuilderWidget> createState() => _AvatarBuilderWidgetState();
}

class _AvatarBuilderWidgetState extends State<AvatarBuilderWidget> {
  late String _selectedIcon;
  late String _selectedIconColor;
  late String _selectedBg;
  late AvatarBuilderTab _activeTab;
  int _activeCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.initialIcon;
    _selectedIconColor = widget.initialIconColor;
    _selectedBg = widget.initialBg;

    final tabs = _getAvailableTabs();
    _activeTab = tabs.isNotEmpty ? tabs.first : AvatarBuilderTab.icon;
  }

  @override
  void didUpdateWidget(covariant AvatarBuilderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIcon != widget.initialIcon) {
      _selectedIcon = widget.initialIcon;
    }
    if (oldWidget.initialIconColor != widget.initialIconColor) {
      _selectedIconColor = widget.initialIconColor;
    }
    if (oldWidget.initialBg != widget.initialBg) {
      _selectedBg = widget.initialBg;
    }
  }

  List<AvatarBuilderTab> _getAvailableTabs() {
    return [
      if (widget.allowIcon) AvatarBuilderTab.icon,
      if (widget.allowIconColor) AvatarBuilderTab.iconColor,
      if (widget.allowBg) AvatarBuilderTab.bg,
    ];
  }

  List<IconCategory> _getFilteredCategories() {
    if (widget.iconCategories == null || widget.iconCategories!.isEmpty) {
      return allIconCategories;
    }
    final filters = widget.iconCategories!;
    return allIconCategories.where((c) {
      return filters.any((f) =>
          f == c.id ||
          f == c.labelRu ||
          f == c.labelEn ||
          f.toLowerCase() == c.id.toLowerCase());
    }).toList();
  }

  void _notifyChange() {
    widget.onChanged?.call(AvatarBuilderValue(
      icon: _selectedIcon,
      iconColor: _selectedIconColor,
      iconBg: _selectedBg,
    ));
  }

  bool _isLightColor(String color) {
    final up = color.toUpperCase();
    return up == '#FFFFFF' || up == '#F5E9DA' || up == '#FFD166';
  }

  @override
  Widget build(BuildContext context) {
    final availableTabs = _getAvailableTabs();
    if (!availableTabs.contains(_activeTab) && availableTabs.isNotEmpty) {
      _activeTab = availableTabs.first;
    }

    final categories = _getFilteredCategories();
    final safeCatIdx = _activeCategoryIndex < categories.length ? _activeCategoryIndex : 0;
    final currentIcons = categories.isNotEmpty ? categories[safeCatIdx].icons : <String>[];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Preview ──
        _buildPreview(),

        // ── Tabs ──
        if (availableTabs.length > 1) _buildTabs(availableTabs),

        // ── Active tab content ──
        if (_activeTab == AvatarBuilderTab.icon && widget.allowIcon) ...[
          if (categories.length > 1) _buildCategoryScroll(categories, safeCatIdx),
          _buildIconGrid(currentIcons),
        ] else if (_activeTab == AvatarBuilderTab.iconColor && widget.allowIconColor) ...[
          _buildColorGrid(),
        ] else if (_activeTab == AvatarBuilderTab.bg && widget.allowBg) ...[
          _buildBgGrid(),
        ],
      ],
    );
  }

  // ─── Preview ───────────────────────────────────────────────────────────────

  Widget _buildPreview() {
    final emoji = IconMapper.getEmoji(_selectedIcon);
    final iconColor = ColorHelper.parseHexColor(_selectedIconColor, fallback: Colors.white);
    final bgDeco = ColorHelper.parseBgDecoration(_selectedBg, isCircle: true);

    Widget inner;
    if (emoji != null) {
      inner = Text(
        emoji,
        style: const TextStyle(fontSize: 46, height: 1.0),
        textAlign: TextAlign.center,
      );
    } else {
      inner = Icon(
        IconMapper.getIcon(_selectedIcon),
        size: 50,
        color: iconColor,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        child: Container(
          width: 90,
          height: 90,
          decoration: bgDeco,
          alignment: Alignment.center,
          child: inner,
        ),
      ),
    );
  }

  // ─── Tabs ──────────────────────────────────────────────────────────────────

  Widget _buildTabs(List<AvatarBuilderTab> availableTabs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: availableTabs.map((tab) {
          final active = _activeTab == tab;
          final String title;
          switch (tab) {
            case AvatarBuilderTab.icon:
              title = 'Иконка';
              break;
            case AvatarBuilderTab.iconColor:
              title = 'Цвет';
              break;
            case AvatarBuilderTab.bg:
              title = 'Фон';
              break;
          }

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = tab),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Category Scroll ───────────────────────────────────────────────────────

  Widget _buildCategoryScroll(List<IconCategory> categories, int activeIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final active = activeIndex == index;

            return GestureDetector(
              onTap: () => setState(() => _activeCategoryIndex = index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.border,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  cat.labelRu,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Icon Grid ─────────────────────────────────────────────────────────────

  Widget _buildIconGrid(List<String> icons) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.0,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final icon = icons[index];
        final isSelected = _selectedIcon == icon;
        final emoji = IconMapper.getEmoji(icon);

        return GestureDetector(
          onTap: () {
            setState(() => _selectedIcon = icon);
            _notifyChange();
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: emoji != null
                ? Text(
                    emoji,
                    style: const TextStyle(fontSize: 24, height: 1.0),
                    textAlign: TextAlign.center,
                  )
                : Icon(
                    IconMapper.getIcon(icon),
                    size: 26,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                  ),
          ),
        );
      },
    );
  }

  // ─── Color Grid ────────────────────────────────────────────────────────────

  Widget _buildColorGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: allIconColors.length,
      itemBuilder: (context, index) {
        final color = allIconColors[index];
        final isSelected = _selectedIconColor.toUpperCase() == color.toUpperCase();
        final c = ColorHelper.parseHexColor(color);
        final isLight = _isLightColor(color);

        return GestureDetector(
          onTap: () {
            setState(() => _selectedIconColor = color);
            _notifyChange();
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.textPrimary
                    : (color.toUpperCase() == '#FFFFFF'
                        ? const Color(0x20000000)
                        : Colors.transparent),
                width: isSelected ? 2.5 : 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: isSelected
                ? Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: isLight ? const Color(0xFF333333) : Colors.white,
                  )
                : null,
          ),
        );
      },
    );
  }

  // ─── Background Grid ───────────────────────────────────────────────────────

  Widget _buildBgGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: allBgOptions.length,
      itemBuilder: (context, index) {
        final bg = allBgOptions[index];
        final isSelected = _selectedBg == bg;
        final decoration = ColorHelper.parseBgDecoration(bg, borderRadius: 12);

        return GestureDetector(
          onTap: () {
            setState(() => _selectedBg = bg);
            _notifyChange();
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: decoration.copyWith(
              border: Border.all(
                color: isSelected
                    ? AppColors.textPrimary
                    : const Color(0x14000000),
                width: isSelected ? 2.5 : 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: isSelected
                ? const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
        );
      },
    );
  }
}
