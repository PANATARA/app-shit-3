import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household/core/api/auth_interceptor.dart';
import 'package:household/core/localization/locale_provider.dart';
import 'package:household/core/storage/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeTokenStorage implements TokenStorage {
  @override
  Future<void> clearTokens() async {}

  @override
  Future<String?> getAccessToken() async => 'fake_token';

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'app_language': 'en'});
    AppLocaleNotifier.init('en');
  });

  test('AppLocaleNotifier updates currentLanguage and reflects in AuthInterceptor', () async {
    expect(AppLocaleNotifier.currentLanguage, 'en');

    final dio = Dio();
    final interceptor = AuthInterceptor(
      tokenStorage: _FakeTokenStorage(),
      dio: dio,
    );

    final options = RequestOptions(path: '/api/chores');
    await interceptor.onRequest(options, RequestInterceptorHandler());

    expect(options.headers['Accept-Language'], 'en');
    expect(options.headers['Authorization'], 'Bearer fake_token');

    // Switch to Russian
    AppLocaleNotifier.init('ru');
    expect(AppLocaleNotifier.currentLanguage, 'ru');

    final optionsRu = RequestOptions(path: '/api/chores');
    await interceptor.onRequest(optionsRu, RequestInterceptorHandler());
    expect(optionsRu.headers['Accept-Language'], 'ru');
  });
}
