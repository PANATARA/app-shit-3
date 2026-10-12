import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../auth/models/user_model.dart';
import '../../chores/models/user_short_model.dart';
import '../models/user_settings_model.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SettingsRepository(dio: dio);
});

class SettingsRepository {
  final Dio dio;

  SettingsRepository({required this.dio});

  /// Получить участников семьи
  Future<List<UserShort>> getFamilyMembers() async {
    try {
      final response = await dio.get(ApiEndpoints.familyMembers);
      if (response.data is Map && response.data['members'] is List) {
        return (response.data['members'] as List)
            .map((e) => UserShort.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (response.data is List) {
        return (response.data as List)
            .map((e) => UserShort.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('[SettingsRepo] getFamilyMembers error: ${e.message}');
      return [];
    }
  }

  /// Получить профиль пользователя по ID
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await dio.get(ApiEndpoints.userById(userId));
      final data = response.data as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('[SettingsRepo] getUserProfile error: ${e.message}');
      return null;
    }
  }

  /// Сгенерировать инвайт-код для приглашения в семью
  Future<Map<String, dynamic>> generateFamilyInvite() async {
    try {
      final response = await dio.post(ApiEndpoints.familyInvite);
      return (response.data as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      debugPrint('[SettingsRepo] generateFamilyInvite error: ${e.message}');
      rethrow;
    }
  }

  /// Исключить участника из семьи (только для админа)
  Future<void> kickFamilyMember(String userId) async {
    try {
      await dio.delete(ApiEndpoints.familyKick(userId));
    } on DioException catch (e) {
      debugPrint('[SettingsRepo] kickFamilyMember error: ${e.message}');
      rethrow;
    }
  }

  /// Передать права администратора семьи
  Future<void> changeFamilyAdmin(String userId) async {
    try {
      await dio.patch(ApiEndpoints.familyChangeAdmin(userId));
    } on DioException catch (e) {
      debugPrint('[SettingsRepo] changeFamilyAdmin error: ${e.message}');
      rethrow;
    }
  }

  /// Выйти из семьи
  Future<void> leaveFamily() async {
    try {
      await dio.patch(ApiEndpoints.familyLogout);
    } on DioException catch (e) {
      debugPrint('[SettingsRepo] leaveFamily error: ${e.message}');
      rethrow;
    }
  }

  /// Отправить тестовое push-уведомление
  Future<Map<String, dynamic>> sendTestNotification() async {
    try {
      final response = await dio.post(ApiEndpoints.notificationTest);
      return (response.data as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      debugPrint('[SettingsRepo] sendTestNotification error: ${e.message}');
      rethrow;
    }
  }

  /// Получить настройки текущего пользователя
  Future<UserSettingsModel> getUserSettings() async {
    try {
      final response = await dio.get(ApiEndpoints.settings);
      final data = response.data as Map<String, dynamic>;
      return UserSettingsModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('[SettingsRepo] getUserSettings error: ${e.message}');
      return const UserSettingsModel();
    }
  }

  /// Обновить настройки текущего пользователя
  Future<UserSettingsModel> updateUserSettings({
    String? appTheme,
    String? language,
    String? dateOfBirth,
    String? timezone,
  }) async {
    final payload = <String, dynamic>{};
    if (appTheme != null) payload['app_theme'] = appTheme;
    if (language != null) payload['language'] = language;
    if (dateOfBirth != null) payload['date_of_birth'] = dateOfBirth;
    if (timezone != null) payload['timezone'] = timezone;

    try {
      final response = await dio.patch(ApiEndpoints.settings, data: payload);
      final data = response.data as Map<String, dynamic>;
      return UserSettingsModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('[SettingsRepo] updateUserSettings error: ${e.message}');
      rethrow;
    }
  }
}

