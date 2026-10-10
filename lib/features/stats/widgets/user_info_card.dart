import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            // Top Row: Avatar + Name & XP + Notification Bell
            Row(
              children: [
                // Avatar with accent ring
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.16),
                  ),
                  child: UserAvatarWidget(
                    user: userShort,
                    size: 48,
                  ),
                ),
                const SizedBox(width: 14),

                // Name & XP subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user?.displayName ?? 'Пользователь',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user != null ? '${user!.experience} XP' : 'Участник семьи',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          letterSpacing: -0.1,
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

            const SizedBox(height: 14),

            // Dual Stats Row: Total & Weekly Completed (matching TodayMealsCard squircle geometry)
            Row(
              children: [
                // Total Completed
                Expanded(
                  child: _StatBox(
                    icon: Icons.check_rounded,
                    watermarkIcon: Icons.check_circle_rounded,
                    value: (user?.totalCompleted ?? 0).toString(),
                    label: 'Всего выполнено',
                  ),
                ),
                const SizedBox(width: 12),

                // This Week
                Expanded(
                  child: _StatBox(
                    icon: Icons.bolt_rounded,
                    watermarkIcon: Icons.bolt_rounded,
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
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            shape: BoxShape.circle,
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
  final IconData watermarkIcon;
  final String value;
  final String label;

  const _StatBox({
    required this.icon,
    required this.watermarkIcon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.currentPalette.isDark;

    return Container(
      height: 104,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceAlt,
            AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.primary.withValues(alpha: 0.15),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Watermark in bottom-right corner (matches TodayMealsCard plate watermark)
            Positioned(
              right: -8,
              bottom: -8,
              child: Opacity(
                opacity: isDark ? 0.08 : 0.10,
                child: Icon(
                  watermarkIcon,
                  size: 74,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
            ),

            // Foreground content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // White circular icon badge (matches TodayMealsCard circular button)
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: isDark ? 0.22 : 0.95),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          icon,
                          size: 22,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          color: AppColors.textPrimary,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
