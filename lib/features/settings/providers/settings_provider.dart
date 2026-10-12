import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/services/timezone_service.dart';
import '../../../core/swr/swr.dart';
import '../../chores/models/user_short_model.dart';
import '../models/user_settings_model.dart';
import '../repositories/settings_repository.dart';

class SettingsState {
  final List<UserShort> familyMembers;
  final bool loadingMembers;
  final bool isSendingPush;
  final ({bool success, String message})? pushResult;
  final String? error;
  final UserSettingsModel? userSettings;
  final bool loadingSettings;

  const SettingsState({
    this.familyMembers = const [],
    this.loadingMembers = false,
    this.isSendingPush = false,
    this.pushResult,
    this.error,
    this.userSettings,
    this.loadingSettings = false,
  });

  SettingsState copyWith({
    List<UserShort>? familyMembers,
    bool? loadingMembers,
    bool? isSendingPush,
    ({bool success, String message})? pushResult,
    bool clearPushResult = false,
    String? error,
    UserSettingsModel? userSettings,
    bool? loadingSettings,
  }) {
    return SettingsState(
      familyMembers: familyMembers ?? this.familyMembers,
      loadingMembers: loadingMembers ?? this.loadingMembers,
      isSendingPush: isSendingPush ?? this.isSendingPush,
      pushResult: clearPushResult ? null : (pushResult ?? this.pushResult),
      error: error,
      userSettings: userSettings ?? this.userSettings,
      loadingSettings: loadingSettings ?? this.loadingSettings,
    );
  }
}

final familyMembersSwr = createSwrProvider<List<UserShort>>(
  key: 'family-members',
  fetcher: (ref) => ref.read(settingsRepositoryProvider).getFamilyMembers(),
  decoder: (json) => (json as List)
      .map((e) => UserShort.fromJson(e as Map<String, dynamic>))
      .toList(),
  encoder: (data) => data.map((e) => e.toJson()).toList(),
);

final settingsNotifierProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final swr = ref.watch(familyMembersSwr);
    final members = swr.data ?? const [];
    final loading = swr.isLoading && members.isEmpty;

    Future.microtask(() => loadUserSettings());

    return SettingsState(
      familyMembers: members,
      loadingMembers: loading,
      error: swr.error?.toString(),
    );
  }

  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  Future<void> loadUserSettings() async {
    state = state.copyWith(loadingSettings: true);
    try {
      final settings = await _repo.getUserSettings();
      state = state.copyWith(userSettings: settings, loadingSettings: false);

      final localTz = TimezoneService.currentTimezone;
      if (settings.timezone != localTz) {
        debugPrint(
          '[SettingsNotifier] Syncing device timezone $localTz (was ${settings.timezone})',
        );
        final updated = await _repo.updateUserSettings(timezone: localTz);
        state = state.copyWith(userSettings: updated);
      }

      if (settings.language == 'ru' || settings.language == 'en') {
        final currentAppLang = ref.read(appLocaleProvider).languageCode;
        if (settings.language != currentAppLang) {
          debugPrint(
            '[SettingsNotifier] Syncing language from server: ${settings.language} (was $currentAppLang)',
          );
          ref.read(appLocaleProvider.notifier).setLocale(settings.language, syncBackend: false);
        }
      }
    } catch (e) {
      debugPrint('[SettingsNotifier] loadUserSettings error: $e');
      state = state.copyWith(loadingSettings: false);
    }
  }

  Future<void> loadFamilyMembers() async {
    await ref.read(familyMembersSwr.notifier).revalidate();
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
