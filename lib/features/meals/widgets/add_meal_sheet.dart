import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../chores/models/user_short_model.dart';
import '../../chores/repositories/chores_repository.dart';
import '../../chores/utils/color_helper.dart';
import '../models/planned_meal_model.dart';
import '../models/recipe_model.dart';
import '../providers/meals_provider.dart';

final familyMembersListProvider = FutureProvider<List<UserShort>>((ref) async {
  return ref.read(choresRepositoryProvider).getFamilyMembers();
});

class AddMealSheet extends ConsumerStatefulWidget {
  final String targetDate;
  final String defaultSlot;

  const AddMealSheet({
    super.key,
    required this.targetDate,
    this.defaultSlot = 'dinner',
  });

  static Future<PlannedMealModel?> show(
    BuildContext context, {
    required String targetDate,
    String defaultSlot = 'dinner',
  }) {
    return showModalBottomSheet<PlannedMealModel>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RepaintBoundary(
        child: AddMealSheet(
          targetDate: targetDate,
          defaultSlot: defaultSlot,
        ),
      ),
    );
  }

  @override
  ConsumerState<AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends ConsumerState<AddMealSheet> {
  String _mode = 'recipe'; // 'recipe' | 'manual'
  late String _selectedSlot;
  final TextEditingController _manualTitleController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController(text: '25');
  final TextEditingController _servingsController = TextEditingController(text: '4');

  RecipeModel? _selectedRecipe;
  UserShort? _selectedCook;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedSlot = widget.defaultSlot;
  }

  @override
  void dispose() {
    _manualTitleController.dispose();
    _prepTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _mode == 'recipe' && _selectedRecipe != null
        ? _selectedRecipe!.title
        : _manualTitleController.text.trim();

    if (title.isEmpty || _isSaving) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final prepTime = int.tryParse(_prepTimeController.text) ?? 20;
    final servings = int.tryParse(_servingsController.text) ?? 4;

    try {
      final meal = await ref.read(mealPlannerNotifierProvider.notifier).addMeal(
        date: widget.targetDate,
        slot: _selectedSlot,
        title: title,
        prepTimeMinutes: prepTime,
        servings: servings,
        recipeId: _mode == 'recipe' ? _selectedRecipe?.id : null,
        assignedCookId: _selectedCook?.id,
      );

      if (mounted) {
        Navigator.of(context).pop(meal);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Не удалось добавить блюдо: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recipesState = ref.watch(familyRecipesSwr);
    final recipes = recipesState.data ?? [];
    final membersAsync = ref.watch(familyMembersListProvider);
    final familyMembers = membersAsync.value ?? [];

    if (_selectedCook == null && familyMembers.isNotEmpty) {
      _selectedCook = familyMembers.first;
    }

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final height = MediaQuery.of(context).size.height * 0.88;

    final canSubmit = _mode == 'recipe'
        ? _selectedRecipe != null
        : _manualTitleController.text.trim().isNotEmpty;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset + safeBottom),
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

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n?.mealsAddDish ?? 'Запланировать блюдо',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: AppColors.textMuted),
                  iconSize: 22,
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 13, color: AppColors.error),
                    ),
                  ),

                // Mode Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildModeTab(
                          id: 'recipe',
                          label: '${l10n?.mealsTabRecipe ?? "Из рецептов"} (${recipes.length})',
                          icon: Icons.menu_book_rounded,
                        ),
                      ),
                      Expanded(
                        child: _buildModeTab(
                          id: 'manual',
                          label: l10n?.mealsTabManual ?? 'Быстрая запись',
                          icon: Icons.edit_note_rounded,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Meal Slot Selector (2x2 Grid)
                _buildSectionLabel(l10n?.mealsSectionMealSlot ?? 'ПРИЕМ ПИЩИ'),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: MealSlotDefinition.all.map((slotDef) {
                    final isSelected = _selectedSlot == slotDef.id;
                    final slotName = () {
                      switch (slotDef.id) {
                        case 'breakfast': return l10n?.slotBreakfast ?? slotDef.name;
                        case 'lunch': return l10n?.slotLunch ?? slotDef.name;
                        case 'dinner': return l10n?.slotDinner ?? slotDef.name;
                        case 'snack': return l10n?.slotSnack ?? slotDef.name;
                        default: return slotDef.name;
                      }
                    }();
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _selectedSlot = slotDef.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              slotDef.icon,
                              color: isSelected ? Colors.white : slotDef.color,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              slotName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Mode A or Mode B content
                if (_mode == 'recipe') ...[
                  _buildSectionLabel(l10n?.mealsSectionChooseRecipe ?? 'ВЫБЕРИТЕ РЕЦЕПТ'),
                  const SizedBox(height: 8),
                  if (recipes.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'В книге пока нет рецептов. Добавьте свой рецепт или используйте быструю запись.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = recipes[index];
                          final isSelected = _selectedRecipe?.id == recipe.id;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                _selectedRecipe = recipe;
                                _prepTimeController.text =
                                    (recipe.prepTimeMinutes + recipe.cookTimeMinutes).toString();
                                _servingsController.text = recipe.baseServings.toString();
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(recipe.emoji, style: const TextStyle(fontSize: 24)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recipe.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '⏱ ${recipe.prepTimeMinutes + recipe.cookTimeMinutes} мин • 👥 ${recipe.baseServings} порций',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? AppColors.primary : AppColors.surface,
                                      border: Border.all(
                                        color: isSelected ? AppColors.primary : AppColors.border,
                                        width: 2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: isSelected
                                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ] else ...[
                  _buildSectionLabel(l10n?.mealsSectionDishName ?? 'НАЗВАНИЕ БЛЮДА'),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _manualTitleController,
                      style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: l10n?.mealsDishPlaceholder ?? 'Название блюда, например: Борщ',
                        hintStyle: TextStyle(fontSize: 14, color: AppColors.textMuted),
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Who is cooking?
                if (familyMembers.isNotEmpty) ...[
                  _buildSectionLabel(l10n?.mealsSectionCook ?? 'КТО ГОТОВИТ?'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: familyMembers.map((cook) {
                      final isSelected = _selectedCook?.id == cook.id;
                      final dotColor = ColorHelper.parseHexColor(cook.iconColor, fallback: AppColors.primary);
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _selectedCook = cook),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : AppColors.surfaceAlt,
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

                // Time and Servings Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel(l10n?.mealsSectionTime ?? 'ВРЕМЯ (МИН)'),
                          const SizedBox(height: 6),
                          Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.center,
                            child: TextField(
                              controller: _prepTimeController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                filled: false,
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel(l10n?.mealsSectionServings ?? 'ПОРЦИИ'),
                          const SizedBox(height: 6),
                          Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.center,
                            child: TextField(
                              controller: _servingsController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                filled: false,
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: canSubmit && !_isSaving ? _handleSave : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_task_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              l10n?.mealsAddToMenu ?? 'Добавить в меню',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildModeTab({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final isActive = _mode == id;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _mode = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 38,
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
