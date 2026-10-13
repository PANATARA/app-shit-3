import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_modal_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../stats/widgets/user_info_card.dart';
import '../providers/settings_provider.dart';
import '../repositories/settings_repository.dart';

class UserProfileModalSheet extends ConsumerStatefulWidget {
  final String userId;

  const UserProfileModalSheet({super.key, required this.userId});

  static Future<void> show(BuildContext context, String userId) {
    return showAppModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RepaintBoundary(child: UserProfileModalSheet(userId: userId)),
    );
  }

  @override
  ConsumerState<UserProfileModalSheet> createState() => _UserProfileModalSheetState();
}

class _UserProfileModalSheetState extends ConsumerState<UserProfileModalSheet> {
  UserModel? _user;
  bool _loading = true;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    try {
      final u = await ref.read(settingsRepositoryProvider).getUserProfile(widget.userId);
      if (!mounted) return;
      setState(() {
        _user = u;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _handleKickMember() async {
    final l10n = AppLocalizations.of(context);
    final userName = _user?.displayName ?? 'пользователя';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.settingsKickConfirmTitle ?? 'Исключить из семьи?'),
        content: Text(l10n?.settingsKickConfirmContent(userName) ?? 'Вы действительно хотите исключить $userName из семьи?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n?.commonCancel ?? 'Отмена')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.settingsKickAction ?? 'Исключить'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _actionLoading = true);
    try {
      await ref.read(settingsNotifierProvider.notifier).kickMember(widget.userId);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _actionLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  Future<void> _handleChangeAdmin() async {
    final l10n = AppLocalizations.of(context);
    final userName = _user?.displayName ?? 'пользователя';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.settingsTransferAdminTitle ?? 'Передать права администратора?'),
        content: Text(l10n?.settingsTransferAdminContent(userName) ?? 'Сделать $userName администратором семьи?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n?.commonCancel ?? 'Отмена')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.settingsTransferAdminAction ?? 'Передать'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _actionLoading = true);
    try {
      await ref.read(settingsNotifierProvider.notifier).transferAdmin(widget.userId);
      if (!mounted) return;
      ref.read(authProvider.notifier).refreshProfile();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _actionLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(authProvider).user?.id;
    final isFamilyAdmin = ref.watch(authProvider).user?.isFamilyAdmin == true;
    final isOtherMember = currentUserId != widget.userId;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          if (_loading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                ),
              ),
            )
          else ...[
            UserInfoCard(user: _user),
            const SizedBox(height: 16),

            if (isFamilyAdmin && isOtherMember) ...[
              if (_actionLoading)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  ),
                )
              else ...[
                // Transfer admin button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _handleChangeAdmin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.settingsTransferAdminBtn ?? 'Сделать администратором',
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Kick member button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _handleKickMember,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.settingsKickMemberBtn ?? 'Исключить из семьи',
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}
