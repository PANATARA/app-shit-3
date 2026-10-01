import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/avatar_builder_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../../chores/models/user_short_model.dart';
import '../../chores/screens/chore_list_screen.dart';
import '../../chores/widgets/user_avatar_widget.dart';
import '../../stats/widgets/ui_card.dart';
import '../../../core/theme/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/invite_modal_sheet.dart';
import '../widgets/lang_modal_sheet.dart';
import '../widgets/theme_modal_sheet.dart';
import '../widgets/user_profile_modal_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Edit mode state
  bool _isEditing = false;
  final _editNameCtrl = TextEditingController();
  String _editIcon = '';
  String _editIconColor = '#ffffff';
  String _editBg = '';

  // Local settings
  String _currentLang = 'ru';

  final String _appVersion = '1.0.0';

  @override
  void dispose() {
    _editNameCtrl.dispose();
    super.dispose();
  }

  void _openEdit() {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    _editNameCtrl.text = user.name ?? '';
    _editIcon = user.icon ?? 'emojione:dog-face';
    _editIconColor = user.iconColor ?? '#ffffff';
    _editBg = user.iconBg ?? 'linear-gradient(135deg, #F97316 0%, #FB7185 100%)';
    setState(() => _isEditing = true);
  }

  void _cancelEdit() {
    setState(() => _isEditing = false);
  }

  Future<void> _saveEdit() async {
    final name = _editNameCtrl.text.trim();
    final success = await ref.read(authProvider.notifier).updateProfile(
      name: name,
      icon: _editIcon,
      iconColor: _editIconColor,
      iconBg: _editBg,
    );
    if (success && mounted) {
      ref.read(settingsNotifierProvider.notifier).loadFamilyMembers();
      setState(() => _isEditing = false);
    }
  }

  Future<void> _handleLeaveFamily() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Покинуть семью?'),
        content: const Text('Вы действительно хотите покинуть текущую семью?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Покинуть'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ref.read(settingsNotifierProvider.notifier).leaveFamily();
      if (!mounted) return;
      ref.read(authProvider.notifier).refreshProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы покинули семью')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Вы уверены, что хотите выйти из приложения?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    ref.read(authProvider.notifier).logout();
  }

  void _showChangeServerDialog() {
    final currentUrl = ref.read(baseUrlProvider);
    final controller = TextEditingController(text: currentUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Адрес бэкенда'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'http://192.168.1.192:8000',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                ref.read(baseUrlProvider.notifier).setUrl(newUrl);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final settingsState = ref.watch(settingsNotifierProvider);
    final baseUrl = ref.watch(baseUrlProvider);

    final userShort = user != null
        ? UserShort(
            id: user.id,
            name: user.displayName,
            icon: user.icon,
            iconColor: user.iconColor,
            iconBg: user.iconBg,
            experience: user.experience,
          )
        : null;

    final activeTheme = ref.watch(appThemeProvider);
    final themeTitle = _getThemeTitle(activeTheme);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.wait([
              ref.read(authProvider.notifier).refreshProfile(),
              ref.read(settingsNotifierProvider.notifier).loadFamilyMembers(),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
            children: [
              // ─── Header ──────────────────────────────────────────────
              _buildHeader(),
              const SizedBox(height: 14),

              // ─── Profile Card (View or Edit) ─────────────────────────
              if (_isEditing)
                _buildEditProfileCard()
              else
                _buildViewProfileCard(userShort, user?.displayName ?? ''),
              const SizedBox(height: 16),

              // ─── Family Members ──────────────────────────────────────
              _sectionLabel('УЧАСТНИКИ СЕМЬИ'),
              _buildFamilyMembersBlock(settingsState, user?.id),
              const SizedBox(height: 16),

              // ─── Family Chores ───────────────────────────────────────
              _sectionLabel('ОБЯЗАННОСТИ'),
              _SettingsBlock(
                children: [
                  _SettingsRow(
                    icon: Icons.format_list_bulleted_rounded,
                    title: 'Управление обязанностями',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChoreListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── Language & Theme ────────────────────────────────────
              _sectionLabel('ЯЗЫК И ТЕМА'),
              _SettingsBlock(
                children: [
                  _SettingsRow(
                    icon: Icons.language_rounded,
                    title: 'Язык',
                    value: _currentLang == 'ru' ? 'Русский' : 'English',
                    onTap: () async {
                      final code = await LangModalSheet.show(context, currentCode: _currentLang);
                      if (code != null && mounted) {
                        setState(() => _currentLang = code);
                      }
                    },
                  ),
                  _SettingsRow(
                    icon: Icons.palette_rounded,
                    title: 'Тема',
                    value: themeTitle,
                    onTap: () async {
                      final themeId = await ThemeModalSheet.show(context, currentThemeId: activeTheme);
                      if (themeId != null && mounted) {
                        await ref.read(appThemeProvider.notifier).setTheme(themeId);
                      }
                    },
                  ),
                  _SettingsRow(
                    icon: Icons.info_rounded,
                    title: 'Версия',
                    value: _appVersion,
                    showArrow: false,
                  ),
                  _SettingsRow(
                    icon: Icons.dns_rounded,
                    title: 'Сервер бэкенда',
                    value: baseUrl,
                    onTap: _showChangeServerDialog,
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── Dev Notifications Test ──────────────────────────────
              _sectionLabel('ТЕСТ УВЕДОМЛЕНИЙ'),
              _buildPushTestBlock(settingsState),
              const SizedBox(height: 16),

              // ─── Account ─────────────────────────────────────────────
              _sectionLabel('АККАУНТ'),
              _SettingsBlock(
                padding: const EdgeInsets.all(12),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Leave family button
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _handleLeaveFamily,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(color: AppColors.error.withValues(alpha: 0.35)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            'Покинуть семью',
                            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Logout button
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _handleLogout,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(color: AppColors.error.withValues(alpha: 0.35)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            'Выйти из аккаунта',
                            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Профиль',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Семья, профиль и настройки',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  // ─── Section Label ───────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  // ─── Profile Card: View Mode ─────────────────────────────────────────────────

  Widget _buildViewProfileCard(UserShort? userShort, String displayName) {
    return UiCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Column(
          children: [
            // Avatar with edit button
            Stack(
              clipBehavior: Clip.none,
              children: [
                UserAvatarWidget(user: userShort, size: 100),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: GestureDetector(
                    onTap: _openEdit,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF97316), Color(0xFFFB7185)],
                        ),
                        border: Border.all(color: AppColors.surface, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.edit_square,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Profile Name
            Text(
              displayName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Profile Card: Edit Mode ─────────────────────────────────────────────────

  Widget _buildEditProfileCard() {
    return UiCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Avatar Builder for Profile
          AvatarBuilderWidget(
            initialIcon: _editIcon,
            initialIconColor: _editIconColor,
            initialBg: _editBg,
            allowIconColor: false,
            iconCategories: const ['pets'],
            onChanged: (val) {
              _editIcon = val.icon;
              _editIconColor = val.iconColor;
              _editBg = val.iconBg;
            },
          ),
          const SizedBox(height: 14),

          // Name field
          Text(
            'ИМЯ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: TextField(
              controller: _editNameCtrl,
              maxLength: 50,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: InputBorder.none,
                counterText: '',
                hintText: 'Ваше имя',
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Actions
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _cancelEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceAlt,
                      foregroundColor: AppColors.textMuted,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                        side: BorderSide(color: AppColors.borderSubtle),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Отмена',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _saveEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Сохранить',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Family Members Block ────────────────────────────────────────────────────

  Widget _buildFamilyMembersBlock(SettingsState settingsState, String? currentUserId) {
    if (settingsState.loadingMembers && settingsState.familyMembers.isEmpty) {
      return _SettingsBlock(
        padding: EdgeInsets.symmetric(vertical: 24),
        children: [
          Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        ],
      );
    }

    final members = settingsState.familyMembers;

    return _SettingsBlock(
      children: [
        // Member rows
        ...members.map((member) {
          final isYou = member.id == currentUserId;

          return _SettingsRow(
            customLeading: UserAvatarWidget(user: member, size: 30),
            titleWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member.name,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isYou)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ты',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
            onTap: () => UserProfileModalSheet.show(context, member.id),
          );
        }),

        // Invite row
        _SettingsRow(
          customLeading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.22),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '+',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                height: 1.0,
              ),
            ),
          ),
          title: 'Пригласить участника',
          titleColor: AppColors.primary,
          arrowColor: AppColors.primary,
          isLast: true,
          onTap: () => InviteModalSheet.show(context),
        ),
      ],
    );
  }

  // ─── Push Test Block ─────────────────────────────────────────────────────────

  Widget _buildPushTestBlock(SettingsState settingsState) {
    return _SettingsBlock(
      padding: const EdgeInsets.all(12),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Button row
            GestureDetector(
              onTap: settingsState.isSendingPush
                  ? null
                  : () => ref.read(settingsNotifierProvider.notifier).sendTestNotification(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.22),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.notifications_active_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        settingsState.isSendingPush
                            ? 'Отправка уведомления...'
                            : 'Отправить тестовое уведомление',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (settingsState.isSendingPush)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    else
                      Text(
                        '›',
                        style: TextStyle(fontSize: 20, color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
            ),

            // Result status card
            if (settingsState.pushResult != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: settingsState.pushResult!.success
                      ? const Color(0x1810B981)
                      : const Color(0x18F59E0B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: settingsState.pushResult!.success
                        ? const Color(0x4010B981)
                        : const Color(0x40F59E0B),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      settingsState.pushResult!.success
                          ? Icons.check_circle_rounded
                          : Icons.info_rounded,
                      size: 18,
                      color: settingsState.pushResult!.success
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        settingsState.pushResult!.message,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: settingsState.pushResult!.success
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _getThemeTitle(String id) {
    switch (id) {
      case 'soft':
        return 'Нежность';
      case 'night':
        return 'Вечер';
      case 'royal':
        return 'Свежесть';
      case 'sage':
        return 'Лесной';
      case 'midnight':
        return 'Северный';
      case 'amber':
        return 'Медовый';
      case 'warm':
      default:
        return 'Тёплая';
    }
  }
}

// ─── Settings Block Container ─────────────────────────────────────────────────

class _SettingsBlock extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const _SettingsBlock({
    required this.children,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

// ─── Settings Row ─────────────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  final IconData? icon;
  final Widget? customLeading;
  final String? title;
  final Widget? titleWidget;
  final String? value;
  final Color? titleColor;
  final Color? arrowColor;
  final bool showArrow;
  final bool isLast;
  final VoidCallback? onTap;

  const _SettingsRow({
    this.icon,
    this.customLeading,
    this.title,
    this.titleWidget,
    this.value,
    this.titleColor,
    this.arrowColor,
    this.showArrow = true,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget leadingWidget;
    if (customLeading != null) {
      leadingWidget = customLeading!;
    } else {
      leadingWidget = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: AppColors.primary),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                leadingWidget,
                const SizedBox(width: 12),

                // Title
                Expanded(
                  child: titleWidget ??
                      Text(
                        title ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: titleColor ?? AppColors.textPrimary,
                        ),
                      ),
                ),

                // Right value
                if (value != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    value!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Arrow
                if (showArrow) ...[
                  const SizedBox(width: 6),
                  Text(
                    '›',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: arrowColor ?? AppColors.textMuted.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 0.5,
            thickness: 0.5,
            indent: 14,
            endIndent: 14,
            color: AppColors.borderSubtle,
          ),
      ],
    );
  }
}
