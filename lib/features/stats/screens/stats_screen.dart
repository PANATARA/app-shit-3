import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/swr/swr.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/events_card.dart';
import '../widgets/leaders_card.dart';
import '../widgets/stats_skeletons.dart';
import '../widgets/user_info_card.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with WidgetsBindingObserver, RouteAware, SwrScreenMixin {
  @override
  int? get swrTabIndex => 0;

  @override
  void onRevalidate() {
    ref.read(homeNotifierProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final authUser = ref.watch(authProvider).user;
    final currentUserId = authUser?.id ?? homeState.profile?.id;
    final effectiveProfile = homeState.profile ?? authUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () => ref.read(homeNotifierProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            children: [
              // ─── Header ──────────────────────────────────────────────
              _buildHeader(homeState.isRevalidating),
              const SizedBox(height: 16),

              // ─── Content or Skeletons ────────────────────────────────
              if (homeState.isLoading && effectiveProfile == null)
                const HomeSkeleton()
              else ...[
                // User Profile & Stats Card
                UserInfoCard(
                  user: effectiveProfile,
                  hasUnreadNotifications: false,
                  onNotificationClick: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Уведомлений пока нет'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Events Card
                EventsCard(
                  events: homeState.events,
                  isLoading: homeState.isLoading,
                ),
                const SizedBox(height: 16),

                // Leaders Card
                LeadersCard(
                  leaders: homeState.leaders?.leaders ?? const [],
                  currentUserId: currentUserId,
                  isLoading: homeState.isLoading,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isRevalidating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Главная',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Семейный очаг, дела и события',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
            if (isRevalidating)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
