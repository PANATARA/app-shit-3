import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/models/user_model.dart';
import '../../chores/models/user_short_model.dart';
import '../../chores/widgets/user_avatar_widget.dart';
import 'ui_card.dart';

class UserInfoCard extends StatelessWidget {
  final UserModel? user;
  final bool hasUnreadNotifications;
  final VoidCallback? onNotificationClick;

  const UserInfoCard({
    super.key,
    required this.user,
    this.hasUnreadNotifications = false,
    this.onNotificationClick,
  });

  @override
  Widget build(BuildContext context) {
    final userShort = user != null
        ? UserShort(
            id: user!.id,
            name: user!.displayName,
            icon: user!.icon,
            iconColor: user!.iconColor,
            iconBg: user!.iconBg,
            experience: user!.experience,
          )
        : null;

    return RepaintBoundary(
      child: UiCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Avatar + Name + Notification Bell
            Row(
              children: [
                // Avatar with accent ring
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.20),
                  ),
                  child: UserAvatarWidget(
                    user: userShort,
                    size: 50,
                  ),
                ),
                const SizedBox(width: 14),

                // Name + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Пользователь',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                          height: 1.15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getLevelLabel(user?.experience ?? 0),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary.withValues(alpha: 0.85),
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),

                // Notification Button
                _NotificationButton(
                  hasUnread: hasUnreadNotifications,
                  onTap: onNotificationClick ?? () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Dual Stats Row: Total & Weekly Completed
            Row(
              children: [
                // Total Completed
                Expanded(
                  child: _StatBox(
                    icon: Icons.task_alt_rounded,
                    iconColor: AppColors.success,
                    iconBg: AppColors.successSoft,
                    value: (user?.totalCompleted ?? 0).toString(),
                    label: 'Всего выполнено',
                  ),
                ),
                const SizedBox(width: 10),

                // This Week
                Expanded(
                  child: _StatBox(
                    icon: Icons.bolt_rounded,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.primarySoft,
                    value: (user?.weekCompleted ?? 0).toString(),
                    label: 'На этой неделе',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLevelLabel(int xp) {
    if (xp < 10) return '✦ Новичок';
    if (xp < 50) return '✦ Помощник';
    if (xp < 150) return '✦ Хранитель дома';
    if (xp < 350) return '✦ Мастер порядка';
    return '✦ Легенда семьи';
  }
}

class _NotificationButton extends StatefulWidget {
  final bool hasUnread;
  final VoidCallback onTap;

  const _NotificationButton({required this.hasUnread, required this.onTap});

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.currentPalette.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              width: 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              if (widget.hasUnread)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  const _StatBox({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.currentPalette.isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 17, color: iconColor),
              ),
              const SizedBox(width: 9),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
