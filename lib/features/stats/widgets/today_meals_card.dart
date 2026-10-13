import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_modal_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../meals/models/planned_meal_model.dart';
import '../../meals/models/recipe_model.dart';
import '../../meals/providers/meals_provider.dart';
import '../../meals/widgets/add_meal_sheet.dart';
import '../../meals/widgets/recipe_detail_sheet.dart';
import 'ui_card.dart';

class TodayMealsCard extends ConsumerWidget {
  const TodayMealsCard({super.key});

  static const _slots = [
    _SlotConfig(
      id: 'breakfast',
      name: 'Завтрак',
      fallbackEmoji: '🍳',
      lightBgColors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
      darkBgColors: [Color(0xFF451A03), Color(0xFF78350F)],
    ),
    _SlotConfig(
      id: 'lunch',
      name: 'Обед',
      fallbackEmoji: '🍲',
      lightBgColors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
      darkBgColors: [Color(0xFF172554), Color(0xFF1E3A8A)],
    ),
    _SlotConfig(
      id: 'dinner',
      name: 'Ужин',
      fallbackEmoji: '🍝',
      lightBgColors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
      darkBgColors: [Color(0xFF431407), Color(0xFF7C2D12)],
    ),
    _SlotConfig(
      id: 'snack',
      name: 'Перекус',
      fallbackEmoji: '🥪',
      lightBgColors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
      darkBgColors: [Color(0xFF022C22), Color(0xFF064E3B)],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final mealsState = ref.watch(dailyPlannedMealsSwr(todayStr));
    final recipesState = ref.watch(familyRecipesSwr);

    final meals = mealsState.data ?? const [];
    final recipes = recipesState.data ?? const [];

    return UiCard(
      title: l10n?.statsTodayMeals ?? 'ПЛАН ПИТАНИЯ НА СЕГОДНЯ',
      action: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.go('/meals');
        },
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n?.statsAllMenu ?? 'Всё меню',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 3),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SlotItem(
                  config: _slots[0],
                  meals: meals.where((m) => m.slot == 'breakfast').toList(),
                  recipes: recipes,
                  todayStr: todayStr,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SlotItem(
                  config: _slots[1],
                  meals: meals.where((m) => m.slot == 'lunch').toList(),
                  recipes: recipes,
                  todayStr: todayStr,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SlotItem(
                  config: _slots[2],
                  meals: meals.where((m) => m.slot == 'dinner').toList(),
                  recipes: recipes,
                  todayStr: todayStr,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SlotItem(
                  config: _slots[3],
                  meals: meals.where((m) => m.slot == 'snack').toList(),
                  recipes: recipes,
                  todayStr: todayStr,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SlotConfig {
  final String id;
  final String name;
  final String fallbackEmoji;
  final List<Color> lightBgColors;
  final List<Color> darkBgColors;

  const _SlotConfig({
    required this.id,
    required this.name,
    required this.fallbackEmoji,
    required this.lightBgColors,
    required this.darkBgColors,
  });

  String getLocalizedName(AppLocalizations? l10n) {
    switch (id) {
      case 'breakfast':
        return l10n?.slotBreakfast ?? name;
      case 'lunch':
        return l10n?.slotLunch ?? name;
      case 'dinner':
        return l10n?.slotDinner ?? name;
      case 'snack':
        return l10n?.slotSnack ?? name;
      default:
        return name;
    }
  }
}

class _SlotItem extends ConsumerWidget {
  final _SlotConfig config;
  final List<PlannedMealModel> meals;
  final List<RecipeModel> recipes;
  final String todayStr;

  const _SlotItem({
    required this.config,
    required this.meals,
    required this.recipes,
    required this.todayStr,
  });

  RecipeModel? _findRecipe(String? recipeId) {
    if (recipeId == null) return null;
    try {
      return recipes.firstWhere((r) => r.id == recipeId);
    } catch (_) {
      return null;
    }
  }

  String _resolveEmoji(PlannedMealModel? meal, RecipeModel? recipe) {
    if (recipe != null && recipe.emoji.isNotEmpty) {
      return recipe.emoji;
    }
    if (meal != null && meal.title.isNotEmpty) {
      final firstRunes = meal.title.runes.take(2).toList();
      final candidate = String.fromCharCodes(firstRunes);
      if (candidate.contains(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true))) {
        return candidate;
      }
    }
    return config.fallbackEmoji;
  }

  void _onSlotTap(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    if (meals.isEmpty) {
      await AddMealSheet.show(
        context,
        targetDate: todayStr,
        defaultSlot: config.id,
      );
      ref.invalidate(dailyPlannedMealsSwr(todayStr));
    } else {
      final primaryMeal = meals.first;
      final linkedRecipe = _findRecipe(primaryMeal.recipeId);

      if (linkedRecipe != null) {
        RecipeDetailSheet.show(context, recipe: linkedRecipe);
      } else {
        // Show meal sheet or add another dish
        await showAppModalBottomSheet(
          context: context,
          useRootNavigator: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    primaryMeal.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (primaryMeal.prepTimeMinutes > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Время приготовления: ${primaryMeal.prepTimeMinutes} мин',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            context.go('/meals');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(color: AppColors.border),
                          ),
                          child: Text(
                            'В меню',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await AddMealSheet.show(
                              context,
                              targetDate: todayStr,
                              defaultSlot: config.id,
                            );
                            ref.invalidate(dailyPlannedMealsSwr(todayStr));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Добавить ещё',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColors = isDark ? config.darkBgColors : config.lightBgColors;

    final hasMeals = meals.isNotEmpty;
    final primaryMeal = hasMeals ? meals.first : null;
    final linkedRecipe = hasMeals ? _findRecipe(primaryMeal!.recipeId) : null;
    final displayEmoji = _resolveEmoji(primaryMeal, linkedRecipe);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Squircle Box (aspect ratio ~1.3)
        GestureDetector(
          onTap: () => _onSlotTap(context, ref),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 104,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: bgColors,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Subtle plate watermark in background
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Opacity(
                      opacity: isDark ? 0.08 : 0.12,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? Colors.white : Colors.black,
                            width: 8,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Slot content
                  if (!hasMeals)
                    // Empty state: clean circular plus button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: isDark ? 0.85 : 0.95),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_rounded,
                          size: 24,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    )
                  else
                    // Filled state: Dish emoji + small title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            displayEmoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            primaryMeal!.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                              height: 1.15,
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                  // Badge for extra meals if more than 1
                  if (meals.length > 1)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '+${meals.length - 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Slot Label
        Text(
          config.getLocalizedName(l10n),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
