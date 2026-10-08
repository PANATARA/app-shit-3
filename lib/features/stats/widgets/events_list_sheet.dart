import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../chores/widgets/chore_icon_widget.dart';
import '../models/family_event_model.dart';
import '../repositories/stats_repository.dart';
import 'event_create_sheet.dart';
import 'event_detail_sheet.dart';

class EventsListSheet extends ConsumerStatefulWidget {
  const EventsListSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RepaintBoundary(child: EventsListSheet()),
    );
  }

  @override
  ConsumerState<EventsListSheet> createState() => _EventsListSheetState();
}

class _EventsListSheetState extends ConsumerState<EventsListSheet> {
  List<FamilyEventModel> _events = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final res = await ref.read(statsRepositoryProvider).getAllEvents();
      if (mounted) setState(() { _events = res; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final height = MediaQuery.of(context).size.height * 0.82;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Все события', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                IconButton(
                  icon: Icon(Icons.add_rounded, color: AppColors.primary, size: 26),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await EventCreateSheet.show(context);
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _error != null
                    ? Center(child: Text('Ошибка загрузки: $_error', style: const TextStyle(color: AppColors.error)))
                    : _events.isEmpty
                        ? Center(child: Text('Событий пока нет', style: TextStyle(color: AppColors.textMuted)))
                        : ListView.separated(
                            padding: EdgeInsets.fromLTRB(16, 12, 16, safeBottom + 16),
                            itemCount: _events.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final event = _events[index];
                              final meta = event.getDateMeta();
                              return _EventTile(
                                event: event,
                                meta: meta,
                                onTap: () async {
                                  await EventDetailSheet.show(context, event);
                                  _loadEvents();
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final FamilyEventModel event;
  final EventDateMeta meta;
  final VoidCallback onTap;

  const _EventTile({required this.event, required this.meta, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
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
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.2),
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
                  Text(meta.formattedDate, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(999)),
              child: Text(meta.badgeText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor)),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
