import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/planned_chore_model.dart';
import '../models/chore_item_model.dart';
import '../models/family_members_model.dart';
import '../models/user_short_model.dart';

final choresRepositoryProvider = Provider<ChoresRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ChoresRepository(dio: dio);
});

class ChoresRepository {
  final Dio dio;

  ChoresRepository({required this.dio});

  // ─── Board Chores ──────────────────────────────────────────────────────────

  Future<List<PlannedChoreModel>> getPlannedChores(String dueDate, {CancelToken? cancelToken}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.plannedChores,
        queryParameters: {'due_date': dueDate},
        cancelToken: cancelToken,
      );
      if (response.data is List) {
        return (response.data as List)
            .map((item) => PlannedChoreModel.fromPlannedJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) rethrow;
      debugPrint('[ChoresRepo] getPlannedChores error: $e');
      rethrow;
    }
  }

  Future<List<PlannedChoreModel>> getQuickPlannedChores(String dueDate, {CancelToken? cancelToken}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.quickChores,
        queryParameters: {
          'date_from': dueDate,
          'date_to': dueDate,
        },
        cancelToken: cancelToken,
      );
      if (response.data is List) {
        return (response.data as List)
            .map((item) => PlannedChoreModel.fromQuickJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) rethrow;
      debugPrint('[ChoresRepo] getQuickPlannedChores error: $e');
      rethrow;
    }
  }

  Future<List<PlannedChoreModel>> getBoardChores(String dueDate, {CancelToken? cancelToken}) async {
    final results = await Future.wait([
      getPlannedChores(dueDate, cancelToken: cancelToken),
      getQuickPlannedChores(dueDate, cancelToken: cancelToken),
    ]);

    final regular = results[0];
    final quick = results[1];

    final merged = [...regular, ...quick];
    merged.sort((a, b) => (a.isQuick ? 1 : 0).compareTo(b.isQuick ? 1 : 0));
    return merged;
  }

  // ─── Toggle / Update ───────────────────────────────────────────────────────

  Future<void> completeChore(PlannedChoreModel chore) async {
    if (chore.isQuick) {
      await dio.patch('${ApiEndpoints.quickChores}/${chore.id}/complete');
    } else {
      await dio.patch('${ApiEndpoints.plannedChores}/${chore.id}/complete');
    }
  }

  Future<void> uncompleteChore(PlannedChoreModel chore) async {
    if (chore.isQuick) {
      await dio.patch('${ApiEndpoints.quickChores}/${chore.id}/uncomplete');
    } else {
      await dio.patch('${ApiEndpoints.plannedChores}/${chore.id}/uncomplete');
    }
  }

  Future<void> updateMessage(PlannedChoreModel chore, String newMessage) async {
    if (chore.isQuick) {
      await dio.patch(
        '${ApiEndpoints.quickChores}/${chore.id}',
        data: {'message': newMessage},
      );
    } else {
      await dio.patch(
        '${ApiEndpoints.plannedChores}/${chore.id}/message',
        data: {'message': newMessage},
      );
    }
  }

  // ─── Reschedule ────────────────────────────────────────────────────────────

  Future<void> reschedulePlannedChore(String id, String newDueDate) async {
    await dio.patch(
      '${ApiEndpoints.plannedChores}/$id',
      data: {'due_date': newDueDate},
    );
  }

  Future<void> rescheduleQuickChore(String id, String newDueDate) async {
    await dio.patch(
      '${ApiEndpoints.quickChores}/$id',
      data: {'due_date': newDueDate},
    );
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  Future<void> deletePlannedChore(String id) async {
    await dio.delete('${ApiEndpoints.plannedChores}/$id');
  }

  Future<void> deleteQuickChore(String id) async {
    await dio.delete('${ApiEndpoints.quickChores}/$id');
  }

  // ─── Create PlannedChore from template ────────────────────────────────────

  /// Creates a planned chore from an existing chore template (chore_id)
  Future<void> addPlannedChore({
    required String choreId,
    required String dueDate,
    String? assignedToId,
    String? message,
  }) async {
    await dio.post(
      ApiEndpoints.plannedChores,
      data: {
        'chore_id': choreId,
        'due_date': dueDate,
        'assigned_to_id': ?assignedToId,
        if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
      },
    );
  }

  // ─── Create QuickChore ─────────────────────────────────────────────────────

  Future<void> createQuickChore({
    required String name,
    required String dueDate,
    String? assignedToId,
    String? message,
    int valuation = 5,
    String icon = 'material-symbols:bolt-rounded',
    String iconColor = '#ffffff',
    String iconBg = 'linear-gradient(135deg, #F59E0B 0%, #F97316 100%)',
  }) async {
    await dio.post(
      ApiEndpoints.quickChores,
      data: {
        'name': name.trim(),
        'due_date': dueDate,
        'valuation': valuation,
        'icon': icon,
        'icon_color': iconColor,
        'icon_bg': iconBg,
        'assigned_to_id': ?assignedToId,
        if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
      },
    );
  }

  // ─── Family Chore Templates & CRUD ────────────────────────────────────────

  Future<List<ChoreItem>> getFamilyChores() async {
    final response = await dio.get(ApiEndpoints.chores);
    if (response.data is Map && response.data['chores'] is List) {
      return (response.data['chores'] as List)
          .map((e) => ChoreItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (response.data is List) {
      return (response.data as List)
          .map((e) => ChoreItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<ChoreItem>> getDefaultChores() async {
    final response = await dio.get(ApiEndpoints.defaultChores);
    if (response.data is List) {
      return (response.data as List)
          .map((e) => ChoreItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> addChoresFromDefault({
    required List<String> defaultChoreIds,
    String language = 'ru',
  }) async {
    await dio.post(
      ApiEndpoints.choresFromDefaults,
      data: {
        'default_chore_ids': defaultChoreIds,
        'language': language,
      },
    );
  }

  Future<ChoreItem> createFamilyChore({
    required String name,
    String? description,
    String icon = 'material-symbols:home-rounded',
    String iconColor = '#ffffff',
    String iconBg = 'linear-gradient(135deg, #8a7f6e 0%, #6b5f50 100%)',
    int valuation = 10,
  }) async {
    final response = await dio.post(
      ApiEndpoints.chores,
      data: {
        'name': name.trim(),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        'icon': icon,
        'icon_color': iconColor,
        'icon_bg': iconBg,
        'valuation': valuation,
      },
    );
    return ChoreItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ChoreItem> updateFamilyChore(
    String choreId, {
    String? name,
    String? description,
    String? icon,
    String? iconColor,
    String? iconBg,
  }) async {
    final data = <String, dynamic>{
      if (name != null) 'name': name.trim(),
      if (description != null) 'description': description.trim(),
      'icon': ?icon,
      'icon_color': ?iconColor,
      'icon_bg': ?iconBg,
    };
    final response = await dio.patch(
      '${ApiEndpoints.chores}/$choreId',
      data: data,
    );
    return ChoreItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteFamilyChore(String choreId) async {
    await dio.delete('${ApiEndpoints.chores}/$choreId');
  }

  // ─── Family Members ────────────────────────────────────────────────────────

  Future<List<UserShort>> getFamilyMembers() async {
    final response = await dio.get(ApiEndpoints.familyMembers);
    if (response.data is Map) {
      final model = FamilyMembersModel.fromJson(response.data as Map<String, dynamic>);
      return model.members;
    }
    if (response.data is List) {
      return (response.data as List)
          .map((e) => UserShort.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ─── Schedules ────────────────────────────────────────────────────────────

  Future<void> addChoreSchedule({
    required String choreId,
    required String frequencyType,
    required int interval,
    required String startsAt,
    required String assignedToId,
    String? endsAt,
    int? daysOfWeek,
    int? dayOfMonth,
  }) async {
    final data = <String, dynamic>{
      'frequency_type': frequencyType,
      'interval': interval,
      'starts_at': startsAt,
      'assigned_to_id': assignedToId,
      'ends_at': ?endsAt,
      'days_of_week': ?daysOfWeek,
      'day_of_month': ?dayOfMonth,
    };
    await dio.post('${ApiEndpoints.chores}/$choreId/schedules', data: data);
  }
}
