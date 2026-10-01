import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

final baseUrlProvider = NotifierProvider<BaseUrlNotifier, String>(BaseUrlNotifier.new);

class BaseUrlNotifier extends Notifier<String> {
  static const _storageKey = 'api_base_url';

  @override
  String build() {
    _loadFromStorage();
    return ApiEndpoints.defaultBaseUrl;
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved != null && saved.trim().isNotEmpty && saved != state) {
        state = saved.trim();
      }
    } catch (e) {
      debugPrint('Failed to load saved base URL: $e');
    }
  }

  Future<void> setUrl(String url) async {
    final cleanUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    if (cleanUrl.isNotEmpty) {
      state = cleanUrl;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_storageKey, cleanUrl);
      } catch (e) {
        debugPrint('Failed to persist base URL: $e');
      }
    }
  }
}

final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      tokenStorage: tokenStorage,
      dio: dio,
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('[DIO] $obj'),
      ),
    );
  }

  return dio;
});
