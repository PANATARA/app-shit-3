import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chores/models/user_short_model.dart';
import '../repositories/settings_repository.dart';

class SettingsState {
  final List<UserShort> familyMembers;
  final bool loadingMembers;
  final bool isSendingPush;
  final ({bool success, String message})? pushResult;
  final String? error;

  const SettingsState({
    this.familyMembers = const [],
    this.loadingMembers = false,
    this.isSendingPush = false,
    this.pushResult,
    this.error,
  });

  SettingsState copyWith({
    List<UserShort>? familyMembers,
    bool? loadingMembers,
    bool? isSendingPush,
    ({bool success, String message})? pushResult,
    bool clearPushResult = false,
    String? error,
  }) {
    return SettingsState(
      familyMembers: familyMembers ?? this.familyMembers,
      loadingMembers: loadingMembers ?? this.loadingMembers,
      isSendingPush: isSendingPush ?? this.isSendingPush,
      pushResult: clearPushResult ? null : (pushResult ?? this.pushResult),
      error: error,
    );
  }
}

final settingsNotifierProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    Future.microtask(() => loadFamilyMembers());
    return const SettingsState();
  }

  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  Future<void> loadFamilyMembers() async {
    state = state.copyWith(loadingMembers: true);
    try {
      final members = await _repo.getFamilyMembers();
      state = state.copyWith(familyMembers: members, loadingMembers: false);
    } catch (e) {
      state = state.copyWith(loadingMembers: false, error: e.toString());
    }
  }

  Future<void> sendTestNotification() async {
    if (state.isSendingPush) return;
    state = state.copyWith(isSendingPush: true, clearPushResult: true);
    try {
      final res = await _repo.sendTestNotification();
      final delivery = res['delivery'] as Map<String, dynamic>?;
      final fcmAvailable = res['fcm_available'] == true;
      final successCount = (delivery?['success'] as num?)?.toInt() ?? 0;
      final totalCount = (delivery?['total'] as num?)?.toInt() ?? 0;
      final failCount = (delivery?['failure'] as num?)?.toInt() ?? 0;

      if (fcmAvailable && successCount > 0) {
        state = state.copyWith(
          isSendingPush: false,
          pushResult: (
            success: true,
            message: 'Тестовое уведомление доставлено ($successCount/$totalCount)',
          ),
        );
      } else if (!fcmAvailable) {
        state = state.copyWith(
          isSendingPush: false,
          pushResult: (
            success: false,
            message: 'FCM не настроен на сервере',
          ),
        );
      } else if (totalCount == 0) {
        state = state.copyWith(
          isSendingPush: false,
          pushResult: (
            success: false,
            message: 'Нет зарегистрированных устройств',
          ),
        );
      } else {
        state = state.copyWith(
          isSendingPush: false,
          pushResult: (
            success: false,
            message: 'Ошибка доставки ($failCount не доставлено)',
          ),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSendingPush: false,
        pushResult: (
          success: false,
          message: 'Не удалось отправить уведомление: $e',
        ),
      );
    }
  }

  Future<void> kickMember(String userId) async {
    await _repo.kickFamilyMember(userId);
    await loadFamilyMembers();
  }

  Future<void> transferAdmin(String userId) async {
    await _repo.changeFamilyAdmin(userId);
    await loadFamilyMembers();
  }

  Future<void> leaveFamily() async {
    await _repo.leaveFamily();
    await loadFamilyMembers();
  }
}
