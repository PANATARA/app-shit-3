import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:household/features/auth/models/user_model.dart';
import 'package:household/features/auth/providers/auth_provider.dart';
import 'package:household/features/auth/repositories/auth_repository.dart';
import 'package:household/core/storage/token_storage.dart';
import 'package:dio/dio.dart';

class FakeTokenStorage implements TokenStorage {
  String? access;
  String? refresh;

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => access;

  @override
  Future<String?> getRefreshToken() async => refresh;

  @override
  Future<void> clearTokens() async {
    access = null;
    refresh = null;
  }
}

class FakeAuthRepository extends AuthRepository {
  UserModel? mockUser;
  UserModel? updateResult;

  FakeAuthRepository({required super.dio, required super.tokenStorage});

  @override
  Future<UserModel> getProfile() async {
    return mockUser ??
        const UserModel(
          id: 'user-1',
          username: 'alice',
          name: 'Alice',
          isFamilyMember: true,
          familyId: 'fam-123',
        );
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? icon,
    String? iconColor,
    String? iconBg,
  }) async {
    return updateResult ??
        UserModel(
          id: 'user-1',
          username: 'alice',
          name: name ?? 'Alice',
          icon: icon,
          iconColor: iconColor,
          iconBg: iconBg,
          // Simulating old buggy backend response that omitted family fields:
          isFamilyMember: false,
          familyId: null,
        );
  }
}

void main() {
  group('UserModel & Profile Update tests', () {
    test('UserModel.copyWith preserves fields and updates specific ones', () {
      const original = UserModel(
        id: '1',
        username: 'john',
        name: 'John Doe',
        icon: 'smile',
        iconColor: '#ffffff',
        iconBg: '#ff0000',
        level: 5,
        experience: 120,
        isFamilyMember: true,
        isFamilyAdmin: true,
        familyId: 'fam-1',
      );

      final updated = original.copyWith(
        icon: 'cat',
        iconBg: '#00ff00',
      );

      expect(updated.id, '1');
      expect(updated.username, 'john');
      expect(updated.name, 'John Doe');
      expect(updated.icon, 'cat');
      expect(updated.iconBg, '#00ff00');
      expect(updated.iconColor, '#ffffff');
      expect(updated.level, 5);
      expect(updated.isFamilyMember, true);
      expect(updated.familyId, 'fam-1');
      expect(updated.isInFamily, true);
    });

    test('updateProfile does not lose family membership even if response omits family info', () async {
      final fakeStorage = FakeTokenStorage();
      await fakeStorage.saveTokens(accessToken: 'token', refreshToken: 'refresh');

      final fakeRepo = FakeAuthRepository(
        dio: Dio(),
        tokenStorage: fakeStorage,
      );

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(fakeStorage),
          authRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );

      // Initialize state with an authenticated user who is in a family
      final notifier = container.read(authProvider.notifier);
      await notifier.checkAuth();

      expect(container.read(authProvider).isAuthenticated, true);
      expect(container.read(authProvider).user?.isInFamily, true);
      expect(container.read(authProvider).user?.familyId, 'fam-123');

      // Update avatar: backend returns response without family fields
      final success = await notifier.updateProfile(
        icon: 'new-icon',
        iconColor: '#000000',
        iconBg: '#ffffff',
      );

      expect(success, true);
      final currentUser = container.read(authProvider).user;
      expect(currentUser, isNotNull);
      expect(currentUser!.icon, 'new-icon');
      // Verify family membership is preserved!
      expect(currentUser.isInFamily, true);
      expect(currentUser.isFamilyMember, true);
      expect(currentUser.familyId, 'fam-123');

      container.dispose();
    });
  });
}
