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

    return UiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar + Name + Notification Bell
          Row(
            children: [
              // Avatar with accent glow ring
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.16),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: UserAvatarWidget(
                  user: userShort,
                  size: 52,
                ),
              ),
              const SizedBox(width: 14),

              // Name
              Expanded(
                child: Text(
                  user?.displayName ?? 'Пользователь',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Notification Button
              InkWell(
                onTap: onNotificationClick ?? () {},
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSubtle, width: 0.5),
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        size: 22,
                        color: AppColors.textSecondary,
                      ),
                      if (hasUnreadNotifications)
                        Positioned(
                          top: -1,
                          right: -1,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: AppColors.textPrimary,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
