import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/swr/swr.dart';
import '../../chores/providers/board_provider.dart';
import '../../meals/providers/meals_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../stats/providers/stats_provider.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(() => checkAuth());
    return const AuthState();
  }

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);
  TokenStorage get _tokenStorage => ref.read(tokenStorageProvider);

  Future<void> checkAuth() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      state = state.copyWith(status: AuthStatus.loading);
      final user = await _authRepository.getProfile();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
    } catch (_) {
      await _tokenStorage.clearTokens();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      );
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      final user = await _authRepository.login(
        username: username,
        password: password,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String password,
    String? name,
    String? firstName,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      final user = await _authRepository.register(
        username: username,
        password: password,
        name: name ?? firstName,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? icon,
    String? iconColor,
    String? iconBg,
  }) async {
    try {
      final user = await _authRepository.updateProfile(
        name: name,
        icon: icon,
        iconColor: iconColor,
        iconBg: iconBg,
      );
      state = state.copyWith(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      final user = await _authRepository.getProfile();
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (_) {}
    await _tokenStorage.clearTokens();
    await Swr.clearAll();
    ref.invalidate(boardNotifierProvider);
    ref.invalidate(mealPlannerNotifierProvider);
    ref.invalidate(homeNotifierProvider);
    ref.invalidate(settingsNotifierProvider);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
