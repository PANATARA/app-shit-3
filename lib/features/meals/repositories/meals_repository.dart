import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/grocery_item_model.dart';
import '../models/planned_meal_model.dart';
import '../models/recipe_model.dart';

final mealsRepositoryProvider = Provider<MealsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MealsRepository(dio: dio);
});

class MealsRepository {
  final Dio dio;

  MealsRepository({required this.dio});

  // ─── RECIPES ─────────────────────────────────────────────────────────────

  Future<List<RecipeModel>> getRecipes({String? category, String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null && category.isNotEmpty && category != 'all') {
        queryParams['category'] = category;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await dio.get(
        ApiEndpoints.recipes,
        queryParameters: queryParams,
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic> && data['recipes'] is List) {
        return (data['recipes'] as List)
            .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is List) {
        return data
            .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[MealsRepo] getRecipes error: $e');
      rethrow;
    }
  }

  Future<RecipeModel> getRecipeById(String id) async {
    try {
      final response = await dio.get(ApiEndpoints.recipeById(id));
      return RecipeModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[MealsRepo] getRecipeById error: $e');
      rethrow;
    }
  }

  Future<RecipeModel> createRecipe(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        ApiEndpoints.recipes,
        data: data,
      );
      return RecipeModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[MealsRepo] createRecipe error: $e');
      rethrow;
    }
  }

  Future<RecipeModel> updateRecipe(String id, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(
        ApiEndpoints.recipeById(id),
        data: data,
      );
      return RecipeModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[MealsRepo] updateRecipe error: $e');
      rethrow;
    }
  }

  Future<RecipeModel> toggleRecipeFavorite(String id) async {
    try {
      final response = await dio.post(ApiEndpoints.recipeFavorite(id));
      return RecipeModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[MealsRepo] toggleRecipeFavorite error: $e');
      rethrow;
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await dio.delete(ApiEndpoints.recipeById(id));
    } catch (e) {
      debugPrint('[MealsRepo] deleteRecipe error: $e');
      rethrow;
    }
  }

  // ─── PLANNER ─────────────────────────────────────────────────────────────

  Future<List<PlannedMealModel>> getPlannedMeals({
    String? dueDate,
    String? startDate,
    String? endDate,
    CancelToken? cancelToken,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (dueDate != null && dueDate.isNotEmpty) {
        queryParams['due_date'] = dueDate;
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }

      final response = await dio.get(
        ApiEndpoints.plannedMeals,
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );

      final dynamic data = response.data;
      if (data is Map<String, dynamic> && data['meals'] is List) {
        return (data['meals'] as List)
            .map((e) => PlannedMealModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is List) {
        return data
            .map((e) => PlannedMealModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) rethrow;
      debugPrint('[MealsRepo] getPlannedMeals error: $e');
      rethrow;
    }
  }

  Future<PlannedMealModel> createPlannedMeal(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        ApiEndpoints.plannedMeals,
        data: data,
      );
      return PlannedMealModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[MealsRepo] createPlannedMeal error: $e');
      rethrow;
    }
  }

  Future<PlannedMealModel> updatePlannedMeal(String id, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(
        ApiEndpoints.plannedMealById(id),
        data: data,
      );
      return PlannedMealModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[MealsRepo] updatePlannedMeal error: $e');
      rethrow;
    }
  }

  Future<PlannedMealModel> togglePlannedMeal(String id) async {
    try {
      final response = await dio.post(ApiEndpoints.plannedMealToggle(id));
      return PlannedMealModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[MealsRepo] togglePlannedMeal error: $e');
      rethrow;
    }
  }

  Future<void> deletePlannedMeal(String id) async {
    try {
      await dio.delete(ApiEndpoints.plannedMealById(id));
    } catch (e) {
      debugPrint('[MealsRepo] deletePlannedMeal error: $e');
      rethrow;
    }
  }

  // ─── GROCERIES ───────────────────────────────────────────────────────────

  Future<List<GroceryItemModel>> getGroceries() async {
    try {
      final response = await dio.get(ApiEndpoints.groceryItems);
      final dynamic data = response.data;
      if (data is Map<String, dynamic> && data['items'] is List) {
        return (data['items'] as List)
            .map((e) => GroceryItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is List) {
        return data
            .map((e) => GroceryItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[MealsRepo] getGroceries error: $e');
      rethrow;
    }
  }

  Future<GroceryItemModel> addGroceryItem(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        ApiEndpoints.groceryItems,
        data: data,
      );
      return GroceryItemModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[MealsRepo] addGroceryItem error: $e');
      rethrow;
    }
  }

  Future<List<GroceryItemModel>> addGroceryBatch(List<Map<String, dynamic>> items) async {
    try {
      final response = await dio.post(
        ApiEndpoints.groceryBatch,
        data: {'items': items},
      );
      final dynamic data = response.data;
      if (data is Map<String, dynamic> && data['items'] is List) {
        return (data['items'] as List)
            .map((e) => GroceryItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[MealsRepo] addGroceryBatch error: $e');
      rethrow;
    }
  }

  Future<GroceryItemModel> updateGroceryItem(String id, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(
        ApiEndpoints.groceryItemById(id),
        data: data,
      );
      return GroceryItemModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[MealsRepo] updateGroceryItem error: $e');
      rethrow;
    }
  }

  Future<void> deleteGroceryItem(String id) async {
    try {
      await dio.delete(ApiEndpoints.groceryItemById(id));
    } catch (e) {
      debugPrint('[MealsRepo] deleteGroceryItem error: $e');
      rethrow;
    }
  }

  Future<void> clearBoughtGroceries() async {
    try {
      await dio.delete(ApiEndpoints.groceryItems);
    } catch (e) {
      debugPrint('[MealsRepo] clearBoughtGroceries error: $e');
      rethrow;
    }
  }
}
