import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
    return UiCard(
      title: 'БЛИЖАЙШИЕ СОБЫТИЯ',
      action: InkWell(
        onTap: () => EventCreateSheet.show(context),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.20),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'Добавить',
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
      child: isLoading
          ? Column(
              children: List.generate(
                2,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            )
          : events.isEmpty
              ? _buildEmptyState(context)
              : _buildEventsList(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.celebration_outlined,
            size: 30,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Событий пока нет',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Добавьте поездку или праздник',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                elevation: 0,
              ),
              onPressed: () => EventCreateSheet.show(context),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Добавить', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                side: BorderSide(
                  color: AppColors.currentPalette.isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.10),
                  width: 1,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () => EventsListSheet.show(context),
              child: const Text('Все', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildEventsList(BuildContext context) {
    return Column(
      children: [
        ...events.map(
          (event) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _EventRow(
              event: event,
              onTap: () => EventDetailSheet.show(context, event),
            ),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => EventsListSheet.show(context),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Все события',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 15, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  final FamilyEventModel event;
  final VoidCallback onTap;

  const _EventRow({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final meta = event.getDateMeta();

    Color badgeBg;
    Color badgeColor;
    switch (meta.badgeType) {
      case EventDateBadgeType.today:
        badgeBg = const Color(0xFF22C55E).withValues(alpha: 0.18);
        badgeColor = const Color(0xFF16A34A);
        break;
      case EventDateBadgeType.soon:
        badgeBg = const Color(0xFFF59E0B).withValues(alpha: 0.18);
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.currentPalette.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            ChoreIconWidget(
              icon: event.icon,
              iconBg: event.iconBg,
              iconColor: event.iconColor,
              size: 44,
              isQuick: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (event.description != null && event.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.description!,
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    meta.formattedDate,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
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
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
