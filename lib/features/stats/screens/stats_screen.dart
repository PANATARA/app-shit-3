import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/swr/swr.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../meals/providers/meals_provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/events_card.dart';
import '../widgets/leaders_card.dart';
import '../widgets/stats_skeletons.dart';
import '../widgets/today_grocery_card.dart';
import '../widgets/today_meals_card.dart';
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
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    ref.invalidate(dailyPlannedMealsSwr(todayStr));
    ref.invalidate(familyGroceriesSwr);
    ref.read(homeNotifierProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appThemeProvider);
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
          onRefresh: () async {
            final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
            ref.invalidate(dailyPlannedMealsSwr(todayStr));
            ref.invalidate(familyGroceriesSwr);
            await ref.read(homeNotifierProvider.notifier).refresh();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: [
              // ─── Greeting Header ─────────────────────────────────────
              _GreetingHeader(
                userName: effectiveProfile?.displayName,
                isRevalidating: homeState.isRevalidating,
              ),
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

                // Today Meals Summary Block
                const TodayMealsCard(),
                const SizedBox(height: 16),

                // Today Grocery List Summary Block
                const TodayGroceryCard(),
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
}

class _GreetingHeader extends StatelessWidget {
  final String? userName;
  final bool isRevalidating;

  const _GreetingHeader({this.userName, required this.isRevalidating});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Доброе утро';
    if (hour >= 12 && hour < 17) return 'Добрый день';
    if (hour >= 17 && hour < 22) return 'Добрый вечер';
    return 'Доброй ночи';
  }

  String? _extractFirstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return null;
    return fullName.trim().split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    final firstName = _extractFirstName(userName);
    final fullGreeting = firstName != null && firstName.isNotEmpty
        ? '$greeting, $firstName'
        : greeting;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              fullGreeting,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                height: 1.15,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isRevalidating) ...[
            const SizedBox(width: 12),
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
