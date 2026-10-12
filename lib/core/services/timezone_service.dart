import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../constants/api_endpoints.dart';
import '../storage/token_storage.dart';

/// Service responsible for detecting the device's IANA timezone
/// and synchronizing it with the backend.
class TimezoneService {
  TimezoneService._();

  static String _currentTimezone = 'UTC';

  /// The currently detected device timezone (e.g. 'Europe/Moscow').
  static String get currentTimezone => _currentTimezone;

  /// Initializes device timezone detection. Safe to call multiple times.
  static Future<void> init() async {
    try {
      final detected = await FlutterTimezone.getLocalTimezone();
      final id = detected.identifier;
      if (id.isNotEmpty) {
        _currentTimezone = id;
        debugPrint('[TimezoneService] Detected local timezone: $_currentTimezone');
      }
    } catch (e) {
      debugPrint('[TimezoneService] Error detecting timezone: $e, falling back to UTC');
      _currentTimezone = 'UTC';
    }
  }

  /// Synchronize the detected device timezone with the user's backend profile.
  /// Only performs a network call if a valid access token exists and the
  /// timezone differs from the provided [backendTimezone].
  static Future<bool> syncWithBackend(
    Dio dio,
    TokenStorage tokenStorage, {
    String? backendTimezone,
  }) async {
    try {
      final token = await tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      if (backendTimezone != null &&
          backendTimezone.isNotEmpty &&
          backendTimezone == _currentTimezone) {
        return false;
      }

      final response = await dio.patch(
        ApiEndpoints.settings,
        data: {'timezone': _currentTimezone},
      );

      if (response.statusCode == 200) {
        debugPrint(
          '[TimezoneService] Successfully synced timezone $_currentTimezone with backend',
        );
        return true;
      }
    } catch (e) {
      debugPrint('[TimezoneService] Failed to sync timezone with backend: $e');
    }
    return false;
  }
}
