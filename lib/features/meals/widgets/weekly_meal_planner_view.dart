import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../chores/utils/color_helper.dart';
import '../../chores/widgets/week_calendar.dart';
import '../models/planned_meal_model.dart';
import '../models/recipe_model.dart';
import '../providers/meals_provider.dart';
import 'add_meal_sheet.dart';
import 'meals_skeletons.dart';
import 'recipe_detail_sheet.dart';

class WeeklyMealPlannerView extends ConsumerWidget {
  final ValueChanged<String>? onToast;

  const WeeklyMealPlannerView({
    super.key,
    this.onToast,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appThemeProvider);
    final selectedDate = ref.watch(selectedMealDateProvider);
    final selectedDateKey = ref.watch(selectedMealDateKeyProvider);

    final plannerState = ref.watch(mealPlannerNotifierProvider);
    final dailySwr = ref.watch(dailyPlannedMealsSwr(selectedDateKey));
    final recipesSwr = ref.watch(familyRecipesSwr);

    final allRecipes = recipesSwr.data ?? [];
    final fetchedMeals = dailySwr.data ?? [];
    final plannedMeals = plannerState.optimisticMeals ?? fetchedMeals;
    final isLoading = dailySwr.isLoading && plannedMeals.isEmpty;

    final dayFormatter = DateFormat('EEEE, d MMMM', 'ru');
    final formattedDayName = dayFormatter.format(selectedDate);
    final capitalizedDayName = formattedDayName.isNotEmpty
        ? formattedDayName[0].toUpperCase() + formattedDayName.substring(1)
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week Calendar Card
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: WeekCalendar(
            selectedDate: selectedDate,
            onDateChanged: (d) {
              ref.read(selectedMealDateProvider.notifier).setDate(d);
            },
          ),
        ),
        const SizedBox(height: 14),

        // Day Header Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capitalizedDayName,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plannedMeals.isEmpty
                        ? 'Меню не запланировано'
                        : 'Запланировано блюд: ${plannedMeals.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),

              // Quick Add "+ Блюдо" Button
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final meal = await AddMealSheet.show(
                    context,
                    targetDate: selectedDateKey,
                    defaultSlot: 'dinner',
                  );
                  if (meal != null && context.mounted) {
                    onToast?.call('Блюдо добавлено в меню');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Блюдо',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Slots or Skeletons
        if (isLoading)
          const MealPlannerSkeleton(slotsCount: 3)
        else
          ...MealSlotDefinition.all.map((slotDef) {
            final slotMeals = plannedMeals.where((m) => m.slot == slotDef.id).toList();
            return _buildSlotCard(
              context: context,
              ref: ref,
              slotDef: slotDef,
              meals: slotMeals,
              allRecipes: allRecipes,
              dateKey: selectedDateKey,
            );
          }),
      ],
    );
  }

  Widget _buildSlotCard({
    required BuildContext context,
    required WidgetRef ref,
    required MealSlotDefinition slotDef,
    required List<PlannedMealModel> meals,
    required List<RecipeModel> allRecipes,
    required String dateKey,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slot Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: slotDef.bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(slotDef.icon, size: 16, color: slotDef.color),
                    const SizedBox(width: 6),
                    Text(
                      slotDef.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: slotDef.color,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Plus trigger
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final meal = await AddMealSheet.show(
                    context,
                    targetDate: dateKey,
                    defaultSlot: slotDef.id,
                  );
                  if (meal != null && context.mounted) {
                    onToast?.call('Блюдо добавлено в меню');
                  }
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.add_rounded, size: 18, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Slot Items or Empty Placeholder
          if (meals.isNotEmpty)
            Column(
              children: meals.map((meal) {
                return _buildMealItem(
                  context: context,
                  ref: ref,
                  meal: meal,
                  allRecipes: allRecipes,
                );
              }).toList(),
            )
          else
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final meal = await AddMealSheet.show(
                  context,
                  targetDate: dateKey,
                  defaultSlot: slotDef.id,
                );
                if (meal != null && context.mounted) {
                  onToast?.call('Блюдо добавлено в меню');
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.border,
                    style: BorderStyle.solid,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Text(
                      'Нажмите, чтобы запланировать ${slotDef.name.toLowerCase()}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMealItem({
    required BuildContext context,
    required WidgetRef ref,
    required PlannedMealModel meal,
    required List<RecipeModel> allRecipes,
  }) {
    RecipeModel? recipe;
    if (meal.recipeId != null) {
      for (final r in allRecipes) {
        if (r.id == meal.recipeId) {
          recipe = r;
          break;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: meal.isCompleted
            ? AppColors.surfaceAlt.withValues(alpha: 0.6)
            : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Completed checkbox
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ref.read(mealPlannerNotifierProvider.notifier).toggleMeal(meal);
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                meal.isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: meal.isCompleted ? AppColors.success : AppColors.textMuted,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Main info
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: recipe != null
                  ? () {
                      final r = recipe;
                      if (r != null) {
                        RecipeDetailSheet.show(
                          context,
                          recipe: r,
                          onToast: onToast,
                        );
                      }
                    }
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          meal.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: meal.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                            decoration: meal.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (meal.recipeId != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.menu_book_rounded, size: 12, color: AppColors.primary),
                              SizedBox(width: 3),
                              Text(
                                'Рецепт',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      if (meal.prepTimeMinutes > 0) ...[
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 3),
                            Text(
                              '${meal.prepTimeMinutes} мин',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                      ],

                      if (meal.cook != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: ColorHelper.parseHexColor(
                                    meal.cook!.iconColor,
                                    fallback: AppColors.primary,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                meal.cook!.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Delete button
          IconButton(
            onPressed: () {
              ref.read(mealPlannerNotifierProvider.notifier).deleteMeal(meal);
            },
            icon: Icon(Icons.delete_outline_rounded, size: 19, color: AppColors.textMuted),
            splashRadius: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
