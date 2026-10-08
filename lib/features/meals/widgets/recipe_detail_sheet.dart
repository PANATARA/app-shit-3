import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../chores/models/user_short_model.dart';
import '../../chores/utils/color_helper.dart';
import '../models/planned_meal_model.dart';
import '../models/recipe_model.dart';
import '../providers/meals_provider.dart';
import 'add_meal_sheet.dart';

class RecipeDetailSheet extends ConsumerStatefulWidget {
  final RecipeModel recipe;
  final ValueChanged<String>? onToast;
  final void Function(String date, String slot, PlannedMealModel meal)? onScheduled;

  const RecipeDetailSheet({
    super.key,
    required this.recipe,
    this.onToast,
    this.onScheduled,
  });

  static Future<void> show(
    BuildContext context, {
    required RecipeModel recipe,
    ValueChanged<String>? onToast,
    void Function(String date, String slot, PlannedMealModel meal)? onScheduled,
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RepaintBoundary(
        child: RecipeDetailSheet(
          recipe: recipe,
          onToast: onToast,
          onScheduled: onScheduled,
        ),
      ),
    );
  }

  @override
  ConsumerState<RecipeDetailSheet> createState() => _RecipeDetailSheetState();
}

class _RecipeDetailSheetState extends ConsumerState<RecipeDetailSheet> {
  late int _servings;
  final Map<String, bool> _checkedIngredients = {};
  bool _isScheduling = false;
  late String _selectedDateKey;
  String _selectedSlot = 'dinner';
  UserShort? _selectedCook;
  bool _isSubmittingSchedule = false;

  @override
  void initState() {
    super.initState();
    _servings = widget.recipe.baseServings;
    _selectedDateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  double get _scale => _servings / (widget.recipe.baseServings > 0 ? widget.recipe.baseServings : 1);

  String _formatAmount(double baseAmount, double factor) {
    final scaled = baseAmount * factor;
    if (scaled <= 0) return '';
    if (scaled >= 10) return scaled.round().toString();
    if (scaled % 1 == 0) return scaled.toInt().toString();
    return scaled.toStringAsFixed(1).replaceAll('.0', '');
  }

  List<Map<String, String>> _getUpcomingDays() {
    final days = <Map<String, String>>[];
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    final shortFormatter = DateFormat('E, d MMM', 'ru');

    for (int i = 0; i < 7; i++) {
      final d = now.add(Duration(days: i));
      final key = formatter.format(d);
      final label = i == 0 ? 'Сегодня' : i == 1 ? 'Завтра' : shortFormatter.format(d);
      days.add({'key': key, 'label': label});
    }
    return days;
  }

  Future<void> _handleAddMissingToGrocery() async {
    final missing = widget.recipe.ingredients
        .where((ing) => _checkedIngredients[ing.id] != true)
        .map((ing) {
          final amt = ing.amount > 0 ? (ing.amount * _scale).roundToDouble() : null;
          return {
            'name': ing.name,
            'amount': amt,
            'unit': ing.unit,
          };
        })
        .toList();

    if (missing.isEmpty) {
      widget.onToast?.call('Все ингредиенты уже отмечены');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Все ингредиенты уже отмечены')),
      );
      return;
    }

    try {
      final addedCount = await ref
          .read(groceriesCoordinatorProvider)
          .addBatch(missing, recipeTitle: widget.recipe.title);

      final msg = 'Добавлено ингредиентов в список покупок: $addedCount';
      widget.onToast?.call(msg);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при добавлении: $e')),
        );
      }
    }
  }

  Future<void> _handleConfirmSchedule() async {
    setState(() => _isSubmittingSchedule = true);
    try {
      final created = await ref.read(mealPlannerNotifierProvider.notifier).addMeal(
        date: _selectedDateKey,
        slot: _selectedSlot,
        title: widget.recipe.title,
        prepTimeMinutes: widget.recipe.prepTimeMinutes + widget.recipe.cookTimeMinutes,
        servings: _servings,
        recipeId: widget.recipe.id,
        assignedCookId: _selectedCook?.id,
      );

      final msg = 'Блюдо "${widget.recipe.title}" запланировано';
      widget.onToast?.call(msg);
      widget.onScheduled?.call(_selectedDateKey, _selectedSlot, created);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка планирования: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingSchedule = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipesState = ref.watch(familyRecipesSwr);
    // Find live recipe model to track favorite updates
    final currentRecipe = (recipesState.data ?? []).firstWhere(
      (r) => r.id == widget.recipe.id,
      orElse: () => widget.recipe,
    );

    final membersAsync = ref.watch(familyMembersListProvider);
    final familyMembers = membersAsync.value ?? [];
    if (_selectedCook == null && familyMembers.isNotEmpty) {
      _selectedCook = familyMembers.first;
    }

    final safeBottom = MediaQuery.of(context).padding.bottom;
    final height = MediaQuery.of(context).size.height * 0.90;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: safeBottom),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 6),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                // Hero Banner
                _buildHeroBanner(currentRecipe),
                const SizedBox(height: 16),

                // Servings Scaler Bar
                _buildServingsBar(),
                const SizedBox(height: 18),

                // Ingredients Section
                _buildIngredientsSection(currentRecipe),
                const SizedBox(height: 18),

                // Steps Section
                if (currentRecipe.steps.isNotEmpty) ...[
                  _buildStepsSection(currentRecipe),
                  const SizedBox(height: 18),
                ],

                // Scheduling Section
                if (_isScheduling) ...[
                  _buildSchedulePanel(familyMembers),
                ] else ...[
                  ElevatedButton(
                    onPressed: () => setState(() => _isScheduling = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.event_available_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Запланировать в меню недели',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(RecipeModel recipe) {
    final bgDec = ColorHelper.parseBgDecoration(
      recipe.accentGradient,
      borderRadius: 22,
    );

    return Container(
      decoration: bgDec,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  recipe.tags.isNotEmpty ? recipe.tags.first : 'Рецепт',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ref.read(recipesCoordinatorProvider).toggleFavorite(recipe.id);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: recipe.isFavorite
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    recipe.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: recipe.isFavorite ? AppColors.error : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(recipe.emoji, style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 6),
          Text(
            recipe.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          if (recipe.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              recipe.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.white, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.prepTimeMinutes + recipe.cookTimeMinutes} мин',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.ingredients.length} ингред.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServingsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.group_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Порции',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                _buildStepperButton(
                  icon: Icons.remove_rounded,
                  disabled: _servings <= 1,
                  onTap: () {
                    if (_servings > 1) setState(() => _servings--);
                  },
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 26),
                  alignment: Alignment.center,
                  child: Text(
                    '$_servings',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildStepperButton(
                  icon: Icons.add_rounded,
                  disabled: _servings >= 16,
                  onTap: () {
                    if (_servings < 16) setState(() => _servings++);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required bool disabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: disabled ? AppColors.surfaceAlt : AppColors.surfaceAlt,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: disabled ? AppColors.textMuted.withValues(alpha: 0.5) : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildIngredientsSection(RecipeModel recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.format_list_bulleted_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Ингредиенты',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleAddMissingToGrocery,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_shopping_cart_rounded, size: 14, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'В список',
                      style: TextStyle(
                        fontSize: 11,
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
        const SizedBox(height: 10),

        Column(
          children: recipe.ingredients.map((ing) {
            final isChecked = _checkedIngredients[ing.id] == true;
            final formattedAmt = _formatAmount(ing.amount, _scale);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _checkedIngredients[ing.id] = !isChecked;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isChecked
                      ? AppColors.surfaceAlt.withValues(alpha: 0.5)
                      : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isChecked ? AppColors.success : AppColors.surface,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: isChecked ? AppColors.success : AppColors.border,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isChecked
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ing.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isChecked ? AppColors.textMuted : AppColors.textPrimary,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    if (formattedAmt.isNotEmpty || ing.unit.isNotEmpty)
                      Text(
                        '$formattedAmt ${ing.unit}'.trim(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 8),

        OutlinedButton(
          onPressed: _handleAddMissingToGrocery,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primary, style: BorderStyle.solid),
            foregroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.shopping_basket_rounded, size: 18),
              SizedBox(width: 8),
              Text(
                'Добавить недостающее в список покупок',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepsSection(RecipeModel recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.soup_kitchen_rounded, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              'Приготовление',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: recipe.steps.map((step) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${step.number}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step.text,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSchedulePanel(List<UserShort> familyMembers) {
    final upcomingDays = _getUpcomingDays();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Запланировать в меню недели',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Day Selector
          Text(
            'ДЕНЬ НЕДЕЛИ',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: upcomingDays.map((day) {
                final isSelected = _selectedDateKey == day['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _selectedDateKey = day['key']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                        ),
                      ),
                      child: Text(
                        day['label']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // Slot Selector
          Text(
            'ПРИЕМ ПИЩИ',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: MealSlotDefinition.all.map((slotDef) {
              final isSelected = _selectedSlot == slotDef.id;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _selectedSlot = slotDef.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        slotDef.icon,
                        size: 16,
                        color: isSelected ? Colors.white : slotDef.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        slotDef.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // Cook Selector
          if (familyMembers.isNotEmpty) ...[
            Text(
              'КТО ГОТОВИТ?',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: familyMembers.map((cook) {
                final isSelected = _selectedCook?.id == cook.id;
                final dotColor = ColorHelper.parseHexColor(cook.iconColor, fallback: AppColors.primary);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedCook = cook),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cook.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Actions
          ElevatedButton(
            onPressed: _isSubmittingSchedule ? null : _handleConfirmSchedule,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isSubmittingSchedule
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_rounded, size: 20),
                      SizedBox(width: 6),
                      Text('Подтвердить', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
          ),
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _isScheduling = false),
              child: Text('Отмена', style: TextStyle(color: AppColors.textMuted)),
            ),
          ),
        ],
      ),
    );
  }
}
