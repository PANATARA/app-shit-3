import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../auth/models/user_model.dart';
import '../models/family_event_model.dart';
import '../models/family_leader_model.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return StatsRepository(dio: dio);
});

class StatsRepository {
  final Dio dio;

  StatsRepository({required this.dio});

  // ─── Profile ───────────────────────────────────────────────────────────────

  Future<UserModel> getProfile({CancelToken? cancelToken}) async {
    final response = await dio.get(
      ApiEndpoints.profile,
      cancelToken: cancelToken,
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ─── Family Leaders ────────────────────────────────────────────────────────

  Future<WeeklyLeadersResponseModel> getFamilyLeaders({CancelToken? cancelToken}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.familyLeader,
        cancelToken: cancelToken,
      );
      if (response.data is Map<String, dynamic>) {
        return WeeklyLeadersResponseModel.fromJson(response.data as Map<String, dynamic>);
      }
      return const WeeklyLeadersResponseModel(leaders: []);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) rethrow;
      debugPrint('[StatsRepo] getFamilyLeaders error: $e');
      rethrow;
    }
  }

  // ─── Events ────────────────────────────────────────────────────────────────

  Future<List<FamilyEventModel>> getUpcomingEvents({CancelToken? cancelToken}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.upcomingEvents,
        cancelToken: cancelToken,
      );
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => FamilyEventModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) rethrow;
      debugPrint('[StatsRepo] getUpcomingEvents error: $e');
      rethrow;
    }
  }

  Future<List<FamilyEventModel>> getAllEvents({int limit = 50, int offset = 0, CancelToken? cancelToken}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.events,
        queryParameters: {'limit': limit, 'offset': offset},
        cancelToken: cancelToken,
      );
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => FamilyEventModel.fromJson(e))
            .toList();
      } else if (response.data is Map && response.data['items'] is List) {
        return (response.data['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => FamilyEventModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) rethrow;
      debugPrint('[StatsRepo] getAllEvents error: $e');
      rethrow;
    }
  }

  Future<FamilyEventModel> createEvent({
    required String name,
    required String date,
    String? description,
    String icon = 'material-symbols:celebration-rounded',
    String iconColor = '#ffffff',
    String iconBg = 'linear-gradient(135deg, #8B5CF6 0%, #6366F1 100%)',
  }) async {
    final response = await dio.post(
      ApiEndpoints.events,
      data: {
        'name': name.trim(),
        'date': date,
        if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
        'icon': icon,
        'icon_color': iconColor,
        'icon_bg': iconBg,
      },
    );
    return FamilyEventModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> updateEvent({
    required String id,
    String? name,
    String? date,
    String? description,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name.trim();
    if (date != null) data['date'] = date;
    if (description != null) data['description'] = description.trim();

    await dio.patch('${ApiEndpoints.events}/$id', data: data);
  }

  Future<void> deleteEvent(String id) async {
    await dio.delete('${ApiEndpoints.events}/$id');
  }
}
