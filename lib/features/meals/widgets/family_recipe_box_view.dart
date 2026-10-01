import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../chores/utils/color_helper.dart';
import '../models/recipe_model.dart';
import '../providers/meals_provider.dart';
import 'add_custom_recipe_sheet.dart';
import 'meals_skeletons.dart';
import 'recipe_detail_sheet.dart';

class FamilyRecipeBoxView extends ConsumerStatefulWidget {
  final ValueChanged<String>? onToast;

  const FamilyRecipeBoxView({
    super.key,
    this.onToast,
  });

  @override
  ConsumerState<FamilyRecipeBoxView> createState() => _FamilyRecipeBoxViewState();
}

class _FamilyRecipeBoxViewState extends ConsumerState<FamilyRecipeBoxView> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'all';

  static const _filters = [
    {'id': 'all', 'label': 'Все блюда', 'icon': Icons.restaurant_rounded},
    {'id': 'quick', 'label': 'Быстрые', 'icon': Icons.bolt_rounded},
    {'id': 'favorites', 'label': 'Избранное', 'icon': Icons.favorite_rounded},
    {'id': 'kids', 'label': 'Детям', 'icon': Icons.child_care_rounded},
    {'id': 'dinner', 'label': 'Ужин', 'icon': Icons.dinner_dining_rounded},
    {'id': 'desserts', 'label': 'Десерты', 'icon': Icons.cake_rounded},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddCustomRecipe() async {
    final created = await AddCustomRecipeSheet.show(context);
    if (created != null && mounted) {
      widget.onToast?.call('Рецепт "${created.title}" добавлен');
      RecipeDetailSheet.show(context, recipe: created, onToast: widget.onToast);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipesState = ref.watch(familyRecipesSwr);
    final allRecipes = recipesState.data ?? [];
    final isLoading = recipesState.isLoading && allRecipes.isEmpty;

    final weekRange = ref.watch(currentWeekRangeProvider);
    final weeklyMealsState = ref.watch(weeklyPlannedMealsSwr(weekRange));
    final weeklyMeals = weeklyMealsState.data ?? [];

    final query = _searchController.text.trim().toLowerCase();

    final filteredRecipes = allRecipes.where((r) {
      if (query.isNotEmpty) {
        final matchTitle = r.title.toLowerCase().contains(query);
        final matchTags = r.tags.any((t) => t.toLowerCase().contains(query));
        final matchIng = r.ingredients.any((i) => i.name.toLowerCase().contains(query));
        if (!matchTitle && !matchTags && !matchIng) return false;
      }

      if (_activeFilter == 'favorites') return r.isFavorite;
      if (_activeFilter == 'quick') {
        return (r.prepTimeMinutes + r.cookTimeMinutes) <= 25 || r.category == 'quick';
      }
      if (_activeFilter == 'kids') {
        return r.category == 'kids' || r.tags.contains('Детям');
      }
      if (_activeFilter == 'dinner') {
        return r.category == 'dinner' || r.tags.contains('Ужин');
      }
      if (_activeFilter == 'desserts') {
        return r.category == 'desserts' || r.tags.contains('Десерт');
      }

      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search & Add Button Row
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Поиск блюда или ингредиента...',
                          hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      InkWell(
                        onTap: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        child: Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // "+ Свой рецепт" Button
            InkWell(
              onTap: _openAddCustomRecipe,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.add_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Свой рецепт',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters.map((f) {
              final isSelected = _activeFilter == f['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () => setState(() => _activeFilter = f['id'] as String),
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          f['icon'] as IconData,
                          size: 15,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          f['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Recipe Grid or Empty State or Skeletons
        if (isLoading)
          const RecipeGridSkeleton(count: 4)
        else if (allRecipes.isEmpty)
          _buildEmptyBookState()
        else if (filteredRecipes.isEmpty)
          _buildNotFoundState()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = filteredRecipes[index];
              final isPlanned = weeklyMeals.any((m) => m.recipeId == recipe.id);
              return _buildRecipeCard(recipe, isPlanned);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyBookState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          children: [
            const Text('📖', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 10),
            Text(
              'Книга рецептов пуста',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Добавьте любимые семейные блюда, чтобы планировать меню в один клик',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openAddCustomRecipe,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Добавить первый рецепт'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          children: [
            Text('🍳', style: TextStyle(fontSize: 44)),
            SizedBox(height: 10),
            Text(
              'Ничего не найдено',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Попробуйте изменить запрос или сбросить фильтры',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(RecipeModel recipe, bool isPlannedThisWeek) {
    final bgDec = ColorHelper.parseBgDecoration(
      recipe.accentGradient,
      borderRadius: 0,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        RecipeDetailSheet.show(
          context,
          recipe: recipe,
          onToast: widget.onToast,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Thumbnail
            Container(
              height: 100,
              decoration: bgDec,
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      recipe.emoji,
                      style: const TextStyle(fontSize: 42),
                    ),
                  ),

                  // Favorite Heart Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        ref.read(recipesCoordinatorProvider).toggleFavorite(recipe.id);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: recipe.isFavorite
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.28),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          recipe.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: recipe.isFavorite ? AppColors.error : Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  // "В меню недели" ribbon
                  if (isPlannedThisWeek)
                    Positioned(
                      bottom: 6,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.calendar_month_rounded, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'В меню',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Card Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recipe.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 3),
                            Text(
                              '${recipe.prepTimeMinutes + recipe.cookTimeMinutes} мин',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.group_rounded, size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 3),
                            Text(
                              '${recipe.baseServings}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
