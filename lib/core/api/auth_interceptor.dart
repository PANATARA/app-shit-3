import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../localization/locale_provider.dart';
import '../services/timezone_service.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final Dio dio;

  Future<String?>? _refreshFuture;

  AuthInterceptor({
    required this.tokenStorage,
    required this.dio,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Attach user device timezone and language to all outgoing requests
    options.headers['X-Timezone'] = TimezoneService.currentTimezone;
    options.headers['Accept-Language'] = AppLocaleNotifier.currentLanguage;

    // Skip auth header for login, register, and refresh endpoints
    final isAuthEndpoint = options.path.contains(ApiEndpoints.login) ||
        options.path.contains(ApiEndpoints.register) ||
        options.path.contains(ApiEndpoints.googleAuth) ||
        options.headers['skipAuth'] == true;

    if (!isAuthEndpoint) {
      final token = await tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // If 401 Unauthorized and not already refreshing or logging in
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains(ApiEndpoints.refresh) &&
        !err.requestOptions.path.contains(ApiEndpoints.login)) {
      try {
        final newAccessToken = await (_refreshFuture ??= _refreshToken());
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await dio.fetch(requestOptions);
          return handler.resolve(retryResponse);
        }
      } catch (_) {
        // Refresh failed, tokens cleared in _refreshToken()
      } finally {
        _refreshFuture = null;
      }
    }

    return handler.next(err);
  }

  Future<String?> _refreshToken() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await tokenStorage.clearTokens();
      return null;
    }

    try {
      final refreshResponse = await dio.post(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'skipAuth': true}),
      );

      if (refreshResponse.statusCode == 200 &&
          refreshResponse.data is Map<String, dynamic>) {
        final data = refreshResponse.data as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String;
        final newRefreshToken = (data['refresh_token'] as String?) ?? refreshToken;

        await tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        return newAccessToken;
      }
    } catch (_) {
      await tokenStorage.clearTokens();
    }
    return null;
  }
}
