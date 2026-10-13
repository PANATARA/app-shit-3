import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../models/repeat_config_model.dart';
import '../repositories/chores_repository.dart';
import 'repeat_selector_widget.dart';

class EditScheduleSheet extends ConsumerStatefulWidget {
  final String scheduleId;
  final String choreTitle;
  final VoidCallback onSaved;

  const EditScheduleSheet({
    super.key,
    required this.scheduleId,
    required this.choreTitle,
    required this.onSaved,
  });

  @override
  ConsumerState<EditScheduleSheet> createState() => _EditScheduleSheetState();
}

class _EditScheduleSheetState extends ConsumerState<EditScheduleSheet> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  late RepeatConfig _config;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    try {
      final repo = ref.read(choresRepositoryProvider);
      final loaded = await repo.getChoreSchedule(widget.scheduleId);
      if (mounted) {
        setState(() {
          _config = loaded ??
              RepeatConfig(
                frequencyType: 'weekly',
                interval: 1,
                daysOfWeek: [DateTime.now().weekday == 7 ? 0 : DateTime.now().weekday],
                startsAt: DateTime.now().toIso8601String().substring(0, 10),
              );
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось загрузить расписание: $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });

    final repo = ref.read(choresRepositoryProvider);

    try {
      if (_config.frequencyType == 'none') {
        // User turned off repeat -> delete the schedule
        await repo.deleteChoreSchedule(widget.scheduleId);
      } else {
        int? daysOfWeekMask;
        if (_config.frequencyType == 'weekly') {
          var mask = RepeatConfig.daysOfWeekToBitmask(_config.daysOfWeek);
          if (mask == 0) {
            final now = DateTime.now();
            final jsDay = now.weekday == 7 ? 0 : now.weekday;
            mask = 1 << (jsDay == 0 ? 6 : jsDay - 1);
          }
          daysOfWeekMask = mask;
        }

        int? dayOfMonth;
        if (_config.frequencyType == 'monthly') {
          dayOfMonth = _config.dayOfMonth ?? DateTime.now().day;
        }

        await repo.updateChoreSchedule(
          scheduleId: widget.scheduleId,
          frequencyType: _config.frequencyType,
          interval: _config.interval < 1 ? 1 : _config.interval,
          daysOfWeek: daysOfWeekMask,
          dayOfMonth: dayOfMonth,
          endsAt: _config.endsAt,
        );
      }

      widget.onSaved();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _config.frequencyType == 'none'
                  ? (l10n?.choreScheduleDeleted ?? 'Расписание удалено')
                  : (l10n?.choreScheduleUpdated ?? 'Расписание обновлено'),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Ошибка сохранения: $e';
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + safeBottom + 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.repeat_rounded, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.choreEditScheduleTitle ?? 'Редактировать расписание',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.choreTitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close_rounded, color: AppColors.textMuted),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RepeatSelectorWidget(
                      value: _config,
                      onChanged: (newVal) => setState(() => _config = newVal),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(fontSize: 13, color: AppColors.error),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Save button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        l10n?.commonSave ?? 'Сохранить',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
