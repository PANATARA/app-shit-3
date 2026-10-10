import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../chores/widgets/chore_icon_widget.dart';
import '../models/family_event_model.dart';
import 'event_create_sheet.dart';
import 'event_detail_sheet.dart';
import 'events_list_sheet.dart';
import 'ui_card.dart';

class EventsCard extends StatelessWidget {
  final List<FamilyEventModel> events;
  final bool isLoading;

  const EventsCard({
    super.key,
    required this.events,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayEvents = events.take(4).toList();
    final remainingCount = events.length - displayEvents.length;

    return UiCard(
      title: l10n?.statsUpcomingEvents ?? 'БЛИЖАЙШИЕ СОБЫТИЯ',
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              EventsListSheet.show(context);
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.borderSubtle,
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n?.statsAllEvents ?? 'Все',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              EventCreateSheet.show(context);
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 13, color: AppColors.primary),
                  const SizedBox(width: 3),
                  Text(
                    l10n?.statsAddEvent ?? 'Добавить',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: isLoading
          ? Column(
              children: List.generate(
                2,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            )
          : events.isEmpty
              ? _buildEmptyState(context, l10n)
              : _buildEventsList(context, l10n, displayEvents, remainingCount),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.celebration_outlined,
              size: 22,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n?.statsNoEvents ?? 'Событий пока нет',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n?.statsNoEventsHint ?? 'Нажмите «Добавить», чтобы запланировать праздник или поездку',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  EventCreateSheet.show(context);
                },
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(
                  l10n?.statsAddEvent ?? 'Добавить',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  EventsListSheet.show(context);
                },
                icon: const Icon(Icons.format_list_bulleted_rounded, size: 16),
                label: Text(
                  l10n?.statsAllEvents ?? 'Все события',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(
    BuildContext context,
    AppLocalizations? l10n,
    List<FamilyEventModel> displayEvents,
    int remainingCount,
  ) {
    return Column(
      children: [
        ...displayEvents.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final isLast = index == displayEvents.length - 1 && remainingCount <= 0;

          return Column(
            children: [
              _EventRowItem(event: event),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppColors.borderSubtle,
                ),
            ],
          );
        }),
        Divider(
          height: 1,
          thickness: 0.5,
          color: AppColors.borderSubtle,
        ),
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            EventsListSheet.show(context);
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  remainingCount > 0
                      ? (l10n?.statsMoreEvents(remainingCount) ??
                          'И ещё $remainingCount ${remainingCount == 1 ? "событие" : (remainingCount < 5 ? "события" : "событий")}')
                      : (l10n?.statsAllEvents ?? 'Все события'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EventRowItem extends StatelessWidget {
  final FamilyEventModel event;

  const _EventRowItem({required this.event});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final meta = event.getDateMeta(lang);

    Color badgeBg;
    Color badgeColor;
    switch (meta.badgeType) {
      case EventDateBadgeType.today:
        badgeBg = const Color(0xFF22C55E).withValues(alpha: 0.16);
        badgeColor = const Color(0xFF16A34A);
        break;
      case EventDateBadgeType.soon:
        badgeBg = const Color(0xFFF59E0B).withValues(alpha: 0.16);
        badgeColor = const Color(0xFFD97706);
        break;
      case EventDateBadgeType.upcoming:
        badgeBg = AppColors.primary.withValues(alpha: 0.14);
        badgeColor = AppColors.primary;
        break;
      case EventDateBadgeType.past:
        badgeBg = AppColors.textMuted.withValues(alpha: 0.14);
        badgeColor = AppColors.textMuted;
        break;
    }

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        EventDetailSheet.show(context, event);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
        child: Row(
          children: [
            ChoreIconWidget(
              icon: event.icon,
              iconBg: event.iconBg,
              iconColor: event.iconColor,
              size: 40,
              isQuick: true,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.description != null && event.description!.trim().isNotEmpty
                        ? '${meta.formattedDate} • ${event.description!.trim()}'
                        : meta.formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                meta.badgeText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textMuted.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
