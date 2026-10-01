import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/swr/swr.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/board_provider.dart';
import '../widgets/card_planned_chore.dart';
import '../widgets/card_planned_chore_skeleton.dart';
import '../widgets/week_calendar.dart';
import '../screens/create_chore_step_one_screen.dart';
import '../screens/planned_chore_detail_screen.dart';

class BoardScreen extends ConsumerStatefulWidget {
  const BoardScreen({super.key});

  @override
  ConsumerState<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends ConsumerState<BoardScreen>
    with WidgetsBindingObserver, RouteAware, SwrScreenMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isFabPressed = false;

  @override
  int? get swrTabIndex => 1;

  @override
  void onRevalidate() {
    ref.read(boardNotifierProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onDateChanged(DateTime date) {
    final currentDate = ref.read(selectedDateProvider);
    final isSameDate = currentDate.year == date.year &&
        currentDate.month == date.month &&
        currentDate.day == date.day;

    ref.read(selectedDateProvider.notifier).setDate(date);

    if (isSameDate) {
      ref.read(boardNotifierProvider.notifier).refresh();
    }
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final boardState = ref.watch(boardNotifierProvider);
    final boardNotifier = ref.read(boardNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Scrollable List Area
          Positioned.fill(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              edgeOffset: 160,
              onRefresh: () => boardNotifier.refresh(),
              child: ListView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(16, 175, 16, 150),
                children: [
                  if (boardState.isLoading) ...[
                    const CardPlannedChoreSkeleton(count: 3),
                  ] else if (boardState.totalCount == 0) ...[
                    // Absolute Zero Empty State
                    _buildEmptyCard(
                      iconEmoji: '🏕️',
                      title: 'Планы отсутствуют',
                      description:
                          'На этот день пока не запланировано никаких домашних дел. Добавьте задачу с помощью кнопки ниже!',
                      isLarge: true,
                    ),
                  ] else ...[
                    // Active Chores Section
                    _buildSectionHeader(
                      title: 'АКТИВНЫЕ',
                      count: boardState.activeChores.length,
                      isCompleted: false,
                    ),
                    const SizedBox(height: 8),

                    if (boardState.activeChores.isEmpty) ...[
                      // All Done Empty State
                      _buildEmptyCard(
                        iconEmoji: '🎉',
                        title: 'Все дела сделаны!',
                        description:
                            'Отличная работа! Все запланированные задачи на сегодня успешно завершены.',
                        isLarge: false,
                      ),
                    ] else ...[
                      ...boardState.activeChores.map((chore) {
                        return Padding(
                          key: ValueKey(chore.id),
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CardPlannedChore(
                            item: chore,
                            isCompleting: boardState.completingIds.contains(chore.id),
                            onToggle: (item) => boardNotifier.toggleChore(item),
                            onUpdateMessage: (item, msg) =>
                                boardNotifier.updateSubtasks(item, msg),
                            onClick: (item) => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PlannedChoreDetailScreen(chore: item),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],

                    // Completed Chores Section
                    if (boardState.completedChores.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSectionHeader(
                        title: 'ВЫПОЛНЕНО',
                        count: boardState.completedChores.length,
                        isCompleted: true,
                      ),
                      const SizedBox(height: 8),

                      ...boardState.completedChores.map((chore) {
                        return Padding(
                          key: ValueKey(chore.id),
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CardPlannedChore(
                            item: chore,
                            isCompleting: false,
                            onToggle: (item) => boardNotifier.toggleChore(item),
                            onUpdateMessage: (item, msg) =>
                                boardNotifier.updateSubtasks(item, msg),
                            onClick: (item) => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PlannedChoreDetailScreen(chore: item),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ],
              ),
            ),
          ),

          // Translucent Apple Calendar Header Card
          // Translucent Apple Calendar Header Card (collapsible on scroll)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _scrollController,
              builder: (context, _) {
                final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                final progress = (offset / 70.0).clamp(0.0, 1.0);
                final topPadding = lerpDouble(10.0, 4.0, progress)!;
                final bottomPadding = lerpDouble(12.0, 8.0, progress)!;
                final cornerRadius = lerpDouble(26.0, 20.0, progress)!;

                return ClipRRect(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(cornerRadius)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(cornerRadius)),
                        border: Border(
                          bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, topPadding, 16, bottomPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Hub Title & Subtitle (collapses vertically on scroll)
                              ClipRect(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  heightFactor: 1.0 - progress,
                                  child: Opacity(
                                    opacity: (1.0 - progress * 1.5).clamp(0.0, 1.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Доска',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.4,
                                            height: 1.15,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              'Расписание и задачи семьи',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: -0.1,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                            if (boardState.isRevalidating) ...[
                                              const SizedBox(width: 8),
                                              SizedBox(
                                                width: 10,
                                                height: 10,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 1.5,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Swipeable Week Calendar (always visible)
                              WeekCalendar(
                                selectedDate: selectedDate,
                                onDateChanged: _onDateChanged,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Floating Action Button (Apple Thumb Zone)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: _buildFab(selectedDate),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required bool isCompleted,
  }) {
    final badgeColor = isCompleted ? AppColors.success : AppColors.primary;
    final badgeBg = isCompleted ? AppColors.successSoft : AppColors.primarySoft;

    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: -0.05,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: badgeColor.withValues(alpha: 0.25),
                width: 0.5,
              ),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard({
    required String iconEmoji,
    required String title,
    required String description,
    required bool isLarge,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isLarge ? 48 : 36,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            iconEmoji,
            style: TextStyle(fontSize: isLarge ? 42 : 32),
          ),
          SizedBox(height: isLarge ? 10 : 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFab(DateTime selectedDate) {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, _) {
        final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
        final progress = (offset / 70.0).clamp(0.0, 1.0);

        return AnimatedScale(
          scale: _isFabPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryLight, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.38),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTapDown: (_) => setState(() => _isFabPressed = true),
                onTapUp: (_) => setState(() => _isFabPressed = false),
                onTapCancel: () => setState(() => _isFabPressed = false),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateChoreStepOneScreen(selectedDate: selectedDate),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(999),
                splashColor: Colors.white.withValues(alpha: 0.15),
                highlightColor: Colors.transparent,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 52,
                      height: 52,
                      child: Center(
                        child: Icon(
                          Icons.add_rounded,
                          size: 26,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1.0 - progress,
                        child: Opacity(
                          opacity: (1.0 - progress * 1.5).clamp(0.0, 1.0),
                          child: const Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: Text(
                              'Запланировать',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
