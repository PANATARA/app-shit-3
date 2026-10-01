import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/swr/swr.dart';
import '../models/grocery_item_model.dart';
import '../models/planned_meal_model.dart';
import '../models/recipe_model.dart';
import '../repositories/meals_repository.dart';

// ─── Selected Date for Meal Planner ─────────────────────────────────────────

class SelectedMealDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }

  void setDateString(String dateStr) {
    try {
      final parts = dateStr.split('-').map(int.parse).toList();
      if (parts.length == 3) {
        state = DateTime(parts[0], parts[1], parts[2]);
      }
    } catch (_) {}
  }
}

final selectedMealDateProvider =
    NotifierProvider<SelectedMealDateNotifier, DateTime>(SelectedMealDateNotifier.new);

final selectedMealDateKeyProvider = Provider<String>((ref) {
  final date = ref.watch(selectedMealDateProvider);
  return DateFormat('yyyy-MM-dd').format(date);
});

// ─── SWR Providers ─────────────────────────────────────────────────────────

/// SWR for all family recipes
final familyRecipesSwr = createSwrProvider<List<RecipeModel>>(
  key: 'family-recipes',
  fetcher: (ref) => ref.read(mealsRepositoryProvider).getRecipes(),
  decoder: (json) => (json as List)
      .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  encoder: (data) => data.map((e) => e.toJson()).toList(),
);

CancelToken? _activeMealsCancelToken;

/// SWR family for planned meals on a specific date (e.g. '2026-09-30')
final dailyPlannedMealsSwr = createSwrFamily<List<PlannedMealModel>, String>(
  key: (dateKey) => 'planned-meals:$dateKey',
  fetcher: (ref, dateKey) {
    _activeMealsCancelToken?.cancel('Switched date');
    final cancelToken = CancelToken();
    _activeMealsCancelToken = cancelToken;
    return ref.read(mealsRepositoryProvider).getPlannedMeals(
      dueDate: dateKey,
      cancelToken: cancelToken,
    );
  },
  decoder: (json) => (json as List)
      .map((e) => PlannedMealModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  encoder: (data) => data.map((e) => e.toJson()).toList(),
);

/// SWR family for planned meals in a week date range
class DateRange {
  final String start;
  final String end;

  const DateRange(this.start, this.end);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

final weeklyPlannedMealsSwr = createSwrFamily<List<PlannedMealModel>, DateRange>(
  key: (range) => 'family-planned-meals:${range.start}:${range.end}',
  fetcher: (ref, range) => ref.read(mealsRepositoryProvider).getPlannedMeals(
    startDate: range.start,
    endDate: range.end,
  ),
  decoder: (json) => (json as List)
      .map((e) => PlannedMealModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  encoder: (data) => data.map((e) => e.toJson()).toList(),
);

/// SWR for family grocery items
final familyGroceriesSwr = createSwrProvider<List<GroceryItemModel>>(
  key: 'family-groceries',
  fetcher: (ref) => ref.read(mealsRepositoryProvider).getGroceries(),
  decoder: (json) => (json as List)
      .map((e) => GroceryItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  encoder: (data) => data.map((e) => e.toJson()).toList(),
);

/// Badge counter for unbought groceries
final unboughtGroceriesCountProvider = Provider<int>((ref) {
  final groceriesState = ref.watch(familyGroceriesSwr);
  final items = groceriesState.data ?? [];
  return items.where((i) => !i.checked).length;
});

// ─── Current Week Dates Helper ──────────────────────────────────────────────

List<String> getCurrentWeekDates() {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final formatter = DateFormat('yyyy-MM-dd');
  return List.generate(7, (i) => formatter.format(monday.add(Duration(days: i))));
}

final currentWeekRangeProvider = Provider<DateRange>((ref) {
  final weekDates = getCurrentWeekDates();
  return DateRange(weekDates.first, weekDates.last);
});

// ─── Meal Planner State & Optimistic Coordinator ────────────────────────────

class MealPlannerState {
  final List<PlannedMealModel>? optimisticMeals;
  final bool isMutating;

  const MealPlannerState({
    this.optimisticMeals,
    this.isMutating = false,
  });

  MealPlannerState copyWith({
    List<PlannedMealModel>? optimisticMeals,
    bool clearOptimistic = false,
    bool? isMutating,
  }) {
    return MealPlannerState(
      optimisticMeals: clearOptimistic ? null : (optimisticMeals ?? this.optimisticMeals),
      isMutating: isMutating ?? this.isMutating,
    );
  }
}

class MealPlannerNotifier extends Notifier<MealPlannerState> {
  @override
  MealPlannerState build() {
    // Reset optimistic state when date changes
    ref.listen(selectedMealDateKeyProvider, (prev, next) {
      if (prev != next) {
        state = state.copyWith(clearOptimistic: true);
      }
    });
    return const MealPlannerState();
  }

  void addOptimisticMeal(PlannedMealModel meal) {
    final dateKey = ref.read(selectedMealDateKeyProvider);
    if (meal.date == dateKey) {
      final currentList = state.optimisticMeals ??
          ref.read(dailyPlannedMealsSwr(dateKey)).data ??
          [];
      state = state.copyWith(optimisticMeals: [...currentList, meal]);
    }
  }

  Future<void> toggleMeal(PlannedMealModel meal) async {
    final dateKey = ref.read(selectedMealDateKeyProvider);
    final currentMeals = state.optimisticMeals ??
        ref.read(dailyPlannedMealsSwr(dateKey)).data ??
        [];

    final updated = currentMeals.map((m) {
      if (m.id == meal.id) {
        return m.copyWith(isCompleted: !m.isCompleted);
      }
      return m;
    }).toList();

    state = state.copyWith(optimisticMeals: updated);

    try {
      await ref.read(mealsRepositoryProvider).togglePlannedMeal(meal.id);
      await Swr.mutate('planned-meals:$dateKey');
      await Swr.mutate('family-planned-meals*');
      state = state.copyWith(clearOptimistic: true);
    } catch (e) {
      debugPrint('[MealPlannerNotifier] toggleMeal failed: $e');
      state = state.copyWith(optimisticMeals: currentMeals);
      rethrow;
    }
  }

  Future<void> deleteMeal(PlannedMealModel meal) async {
    final dateKey = ref.read(selectedMealDateKeyProvider);
    final currentMeals = state.optimisticMeals ??
        ref.read(dailyPlannedMealsSwr(dateKey)).data ??
        [];

    final updated = currentMeals.where((m) => m.id != meal.id).toList();
    state = state.copyWith(optimisticMeals: updated);

    try {
      await ref.read(mealsRepositoryProvider).deletePlannedMeal(meal.id);
      await Swr.mutate('planned-meals:$dateKey');
      await Swr.mutate('family-planned-meals*');
      state = state.copyWith(clearOptimistic: true);
    } catch (e) {
      debugPrint('[MealPlannerNotifier] deleteMeal failed: $e');
      state = state.copyWith(optimisticMeals: currentMeals);
      rethrow;
    }
  }

  Future<PlannedMealModel> addMeal({
    required String date,
    required String slot,
    required String title,
    int prepTimeMinutes = 15,
    int servings = 4,
    String? recipeId,
    String? assignedCookId,
    String? note,
  }) async {
    state = state.copyWith(isMutating: true);
    try {
      final payload = <String, dynamic>{
        'date': date,
        'slot': slot,
        'title': title,
        'prep_time_minutes': prepTimeMinutes,
        'servings': servings,
        'recipe_id': ?recipeId,
        'assigned_cook_id': ?assignedCookId,
        if (note != null && note.isNotEmpty) 'note': note,
      };

      final created = await ref.read(mealsRepositoryProvider).createPlannedMeal(payload);
      addOptimisticMeal(created);
      await Swr.mutate('planned-meals:$date');
      await Swr.mutate('family-planned-meals*');
      return created;
    } finally {
      state = state.copyWith(isMutating: false);
    }
  }
}

final mealPlannerNotifierProvider =
    NotifierProvider<MealPlannerNotifier, MealPlannerState>(MealPlannerNotifier.new);

// ─── Recipes Coordinator ───────────────────────────────────────────────────

class RecipesCoordinator {
  final Ref ref;

  RecipesCoordinator(this.ref);

  Future<void> toggleFavorite(String recipeId) async {
    // Optimistic cache update
    final current = ref.read(familyRecipesSwr).data ?? [];
    final updated = current.map((r) {
      if (r.id == recipeId) {
        return r.copyWith(isFavorite: !r.isFavorite);
      }
      return r;
    }).toList();

    await Swr.mutate('family-recipes', updated, (d) => d.map((e) => e.toJson()).toList());

    try {
      await ref.read(mealsRepositoryProvider).toggleRecipeFavorite(recipeId);
      await Swr.mutate('family-recipes');
    } catch (e) {
      debugPrint('[RecipesCoordinator] toggleFavorite failed: $e');
      await Swr.mutate('family-recipes', current, (d) => d.map((e) => e.toJson()).toList());
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    final current = ref.read(familyRecipesSwr).data ?? [];
    final updated = current.where((r) => r.id != recipeId).toList();
    await Swr.mutate('family-recipes', updated, (d) => d.map((e) => e.toJson()).toList());

    try {
      await ref.read(mealsRepositoryProvider).deleteRecipe(recipeId);
      await Swr.mutate('family-recipes');
    } catch (e) {
      debugPrint('[RecipesCoordinator] deleteRecipe failed: $e');
      await Swr.mutate('family-recipes', current, (d) => d.map((e) => e.toJson()).toList());
      rethrow;
    }
  }

  Future<RecipeModel> createRecipe(Map<String, dynamic> data) async {
    final created = await ref.read(mealsRepositoryProvider).createRecipe(data);
    final current = ref.read(familyRecipesSwr).data ?? [];
    final updated = [created, ...current];
    await Swr.mutate('family-recipes', updated, (d) => d.map((e) => e.toJson()).toList());
    await Swr.mutate('family-recipes');
    return created;
  }
}

final recipesCoordinatorProvider = Provider<RecipesCoordinator>((ref) {
  return RecipesCoordinator(ref);
});

// ─── Groceries Coordinator ─────────────────────────────────────────────────

class GroceriesCoordinator {
  final Ref ref;

  GroceriesCoordinator(this.ref);

  Future<GroceryItemModel> addItem({
    required String name,
    double? amount,
    String? unit,
    String? category,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
      'amount': ?amount,
      if (unit != null && unit.isNotEmpty) 'unit': unit.trim(),
      if (category != null && category.isNotEmpty) 'category': category.trim(),
    };

    final created = await ref.read(mealsRepositoryProvider).addGroceryItem(payload);
    final current = ref.read(familyGroceriesSwr).data ?? [];
    final updated = [created, ...current];
    await Swr.mutate('family-groceries', updated, (d) => d.map((e) => e.toJson()).toList());
    await Swr.mutate('family-groceries');
    return created;
  }

  Future<int> addBatch(List<Map<String, dynamic>> items, {String? recipeTitle}) async {
    final batch = items.map((i) => {
      'name': i['name'],
      'amount': i['amount'],
      'unit': i['unit'],
      'category': 'Рецепт',
      'added_from_recipe': recipeTitle,
    }).toList();

    final result = await ref.read(mealsRepositoryProvider).addGroceryBatch(batch);
    await Swr.mutate('family-groceries');
    return result.length;
  }

  Future<void> toggleItem(String id, bool currentChecked) async {
    final current = ref.read(familyGroceriesSwr).data ?? [];
    final updated = current.map((item) {
      if (item.id == id) {
        return item.copyWith(checked: !item.checked);
      }
      return item;
    }).toList();

    await Swr.mutate('family-groceries', updated, (d) => d.map((e) => e.toJson()).toList());

    try {
      await ref.read(mealsRepositoryProvider).updateGroceryItem(
        id,
        {'is_bought': !currentChecked},
      );
      await Swr.mutate('family-groceries');
    } catch (e) {
      debugPrint('[GroceriesCoordinator] toggleItem failed: $e');
      await Swr.mutate('family-groceries', current, (d) => d.map((e) => e.toJson()).toList());
    }
  }

  Future<void> deleteItem(String id) async {
    final current = ref.read(familyGroceriesSwr).data ?? [];
    final updated = current.where((i) => i.id != id).toList();
    await Swr.mutate('family-groceries', updated, (d) => d.map((e) => e.toJson()).toList());

    try {
      await ref.read(mealsRepositoryProvider).deleteGroceryItem(id);
      await Swr.mutate('family-groceries');
    } catch (e) {
      debugPrint('[GroceriesCoordinator] deleteItem failed: $e');
      await Swr.mutate('family-groceries', current, (d) => d.map((e) => e.toJson()).toList());
      rethrow;
    }
  }

  Future<void> clearCompleted() async {
    final current = ref.read(familyGroceriesSwr).data ?? [];
    final updated = current.where((i) => !i.checked).toList();
    await Swr.mutate('family-groceries', updated, (d) => d.map((e) => e.toJson()).toList());

    try {
      await ref.read(mealsRepositoryProvider).clearBoughtGroceries();
      await Swr.mutate('family-groceries');
    } catch (e) {
      debugPrint('[GroceriesCoordinator] clearCompleted failed: $e');
      await Swr.mutate('family-groceries', current, (d) => d.map((e) => e.toJson()).toList());
      rethrow;
    }
  }
}

final groceriesCoordinatorProvider = Provider<GroceriesCoordinator>((ref) {
  return GroceriesCoordinator(ref);
});
