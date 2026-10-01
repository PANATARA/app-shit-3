import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepository(dio: dio, tokenStorage: tokenStorage);
});

class AuthRepository {
  final Dio dio;
  final TokenStorage tokenStorage;

  AuthRepository({
    required this.dio,
    required this.tokenStorage,
  });

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      debugPrint('[AuthRepo] Attempting login for $username to ${dio.options.baseUrl}${ApiEndpoints.login}');
      final response = await dio.post(
        ApiEndpoints.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String;

      await tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      return await getProfile();
    } on DioException catch (e) {
      debugPrint('[AuthRepo] Login DioException: ${e.message}, response: ${e.response?.data}');
      throw formatDioError(e);
    } catch (e) {
      debugPrint('[AuthRepo] Login error: $e');
      rethrow;
    }
  }

  Future<UserModel> register({
    required String username,
    required String password,
    String? name,
  }) async {
    try {
      debugPrint('[AuthRepo] Attempting register for $username to ${dio.options.baseUrl}${ApiEndpoints.register}');
      final response = await dio.post(
        ApiEndpoints.register,
        data: {
          'username': username,
          'password': password,
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String;

      await tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      return await getProfile();
    } on DioException catch (e) {
      debugPrint('[AuthRepo] Register DioException: ${e.message}, response: ${e.response?.data}');
      throw formatDioError(e);
    } catch (e) {
      debugPrint('[AuthRepo] Register error: $e');
      rethrow;
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await dio.get(ApiEndpoints.profile);
      final data = response.data as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('[AuthRepo] getProfile DioException: ${e.message}');
      throw formatDioError(e);
    }
  }

  Future<UserModel> updateProfile({
    String? name,
    String? icon,
    String? iconColor,
    String? iconBg,
  }) async {
    try {
      final response = await dio.patch(
        ApiEndpoints.profile,
        data: {
          if (name != null) 'name': name.trim(),
          'icon': ?icon,
          'icon_color': ?iconColor,
          'icon_bg': ?iconBg,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('[AuthRepo] updateProfile DioException: ${e.message}');
      throw formatDioError(e);
    }
  }

  Future<void> logout() async {
    await tokenStorage.clearTokens();
  }

  static String formatDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        if (data['detail'] is String) {
          return data['detail'] as String;
        } else if (data['serviceError'] is String) {
          return data['serviceError'] as String;
        } else if (data['detail'] is List) {
          final first = data['detail'][0];
          if (first is Map && first['msg'] != null) {
            final loc = first['loc'] is List ? (first['loc'] as List).last : '';
            return '$loc: ${first['msg']}';
          }
        }
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) return 'Неверный логин или пароль';
      if (statusCode == 403) return 'Доступ запрещен';
      if (statusCode == 404) return 'Запрашиваемый ресурс не найден (404)';
      if (statusCode == 405) return 'Метод не поддерживается (405)';
      if (statusCode == 409) return 'Пользователь уже существует';
      if (statusCode == 422) return 'Неверный формат данных (422)';
      return 'Ошибка сервера ($statusCode)';
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Таймаут подключения к серверу (${e.requestOptions.uri})';
      case DioExceptionType.sendTimeout:
        return 'Таймаут отправки данных';
      case DioExceptionType.receiveTimeout:
        return 'Таймаут ожидания ответа сервера';
      case DioExceptionType.connectionError:
        return 'Не удалось подключиться к серверу (${e.requestOptions.uri.origin}). Проверьте Wi-Fi и адрес сервера.';
      case DioExceptionType.badCertificate:
        return 'Ошибка проверки SSL-сертификата';
      case DioExceptionType.cancel:
        return 'Запрос отменен';
      default:
        return e.message ?? 'Ошибка сетевого соединения';
    }
  }
}
