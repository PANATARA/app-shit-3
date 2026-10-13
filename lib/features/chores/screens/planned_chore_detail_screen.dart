import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_modal_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../models/planned_chore_model.dart';
import '../models/user_short_model.dart';
import '../providers/board_provider.dart';
import '../repositories/chores_repository.dart';
import '../widgets/chore_icon_widget.dart';
import '../widgets/chore_screen_header.dart';
import '../widgets/edit_schedule_sheet.dart';
import '../widgets/planned_chore_subtasks_widget.dart';
import '../widgets/user_avatar_widget.dart';

class PlannedChoreDetailScreen extends ConsumerStatefulWidget {
  final PlannedChoreModel chore;

  const PlannedChoreDetailScreen({super.key, required this.chore});

  @override
  ConsumerState<PlannedChoreDetailScreen> createState() => _State();
}

class _State extends ConsumerState<PlannedChoreDetailScreen> {
  late PlannedChoreModel _chore;
  DateTime? _newDate;
  bool _loading = false;
  bool _editingSubtasks = false;
  String? _subtaskError;
  late TextEditingController _msgCtrl;

  @override
  void initState() {
    super.initState();
    _chore = widget.chore;
    _newDate = _parse(_chore.dueDate);
    _msgCtrl = TextEditingController(text: _chore.message);
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  DateTime? _parse(String? s) {
    if (s == null || s.isEmpty) return null;
    try { return DateTime.parse(s); } catch (_) { return null; }
  }

  String _fmt(DateTime? d, [String? locale]) => d == null ? '—' : DateFormat('d MMMM yyyy', locale ?? 'ru').format(d);

  bool get _dateChanged {
    if (_newDate == null) return false;
    final orig = _parse(_chore.dueDate);
    if (orig == null) return false;
    return !(_newDate!.year == orig.year && _newDate!.month == orig.month && _newDate!.day == orig.day);
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  Future<void> _toggleDone() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(choresRepositoryProvider);
      if (_chore.isDone) {
        await repo.uncompleteChore(_chore);
        setState(() => _chore = _chore.copyWith(clearCompletedBy: true));
      } else {
        await repo.completeChore(_chore);
        setState(() => _chore = _chore.copyWith(completedBy: const UserShort(id: 'me', name: 'Вы')));
      }
      ref.read(boardNotifierProvider.notifier).refresh();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) _snack('Ошибка: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reschedule() async {
    if (!_dateChanged || _loading) return;
    setState(() => _loading = true);
    final newDateStr = DateFormat('yyyy-MM-dd').format(_newDate!);
    try {
      final repo = ref.read(choresRepositoryProvider);
      if (_chore.isQuick) {
        await repo.rescheduleQuickChore(_chore.id, newDateStr);
      } else {
        await repo.reschedulePlannedChore(_chore.id, newDateStr);
      }
      ref.read(boardNotifierProvider.notifier).refresh();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) _snack('Ошибка переноса: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openRepeatSettings() {
    showAppModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditScheduleSheet(
        scheduleId: _chore.scheduleId!,
        choreTitle: _chore.displayTitle,
        onSaved: () {
          ref.read(boardNotifierProvider.notifier).refresh();
        },
      ),
    );
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(choresRepositoryProvider);

    if (!_chore.isQuick && _chore.scheduleId != null) {
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            l10n?.choreDeleteRecurringTitle ?? 'Удаление регулярной задачи',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          content: Text(
            l10n?.choreDeleteRecurringDesc ??
                'Эта задача повторяется по расписанию. Что вы хотите удалить?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error.withValues(alpha: 0.12),
                    foregroundColor: AppColors.error,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(ctx).pop('single'),
                  child: Text(
                    l10n?.choreDeleteOnlyThis ?? 'Только эту задачу',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(ctx).pop('all'),
                  child: Text(
                    l10n?.choreDeleteAllFuture ?? 'Эту и все будущие задачи',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: Text(
                    l10n?.commonCancel ?? 'Отмена',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      if (action == null || !mounted) return;

      setState(() => _loading = true);
      try {
        if (action == 'single') {
          await repo.deletePlannedChore(_chore.id);
        } else if (action == 'all') {
          await repo.deleteChoreSchedule(_chore.scheduleId!);
        }
        ref.read(boardNotifierProvider.notifier).refresh();
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) _snack('Ошибка удаления: $e');
      } finally {
        if (mounted) setState(() => _loading = false);
      }
      return;
    }

    final ok = await _confirm();
    if (!ok || !mounted) return;
    setState(() => _loading = true);
    try {
      if (_chore.isQuick) {
        await repo.deleteQuickChore(_chore.id);
      } else {
        await repo.deletePlannedChore(_chore.id);
      }
      ref.read(boardNotifierProvider.notifier).refresh();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) _snack('Ошибка удаления: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveSubtasks() async {
    setState(() => _subtaskError = null);
    try {
      await ref.read(choresRepositoryProvider).updateMessage(_chore, _msgCtrl.text);
      setState(() {
        _chore = _chore.copyWith(message: _msgCtrl.text);
        _editingSubtasks = false;
      });
      ref.read(boardNotifierProvider.notifier).refresh();
    } catch (e) {
      setState(() => _subtaskError = 'Не удалось сохранить: $e');
    }
  }

  Future<bool> _confirm() async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(l10n?.choreConfirmDeleteTitle ?? 'Удалить задачу?', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            content: Text(l10n?.choreConfirmDeleteDesc ?? 'Это действие нельзя отменить.', style: TextStyle(color: AppColors.textSecondary)),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n?.commonCancel ?? 'Отмена', style: TextStyle(color: AppColors.textMuted))),
              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n?.commonDelete ?? 'Удалить', style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700))),
            ],
          ),
        ) ??
        false;
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _newDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary, surface: AppColors.surface)),
        child: child!,
      ),
    );
    if (p != null && mounted) setState(() => _newDate = p);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ──────────────────────────────────────────
            ChoreScreenHeader(title: _chore.displayTitle, onBack: () => Navigator.of(context).pop()),

            // ─── Scrollable content ───────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildIcon(),
                    const SizedBox(height: 10),
                    _buildSubtasksCard(l10n),
                    const SizedBox(height: 10),
                    _buildDetailsCard(l10n, locale),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ─── Fixed action buttons at bottom ───────────────────
            Container(
              padding: EdgeInsets.fromLTRB(14, 8, 14, safeBottom > 0 ? safeBottom + 2 : 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Reschedule — only when date changed
                  if (_dateChanged && !_chore.isDone) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: _loading ? null : _reschedule,
                        icon: const Icon(Icons.calendar_month_rounded, size: 16),
                        label: Text(
                          l10n?.choreRescheduleTo(_fmt(_newDate, locale)) ?? 'Перенести на ${_fmt(_newDate, locale)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // Toggle done
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _chore.isDone ? AppColors.warning : AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _loading ? null : _toggleDone,
                      icon: Icon(_chore.isDone ? Icons.undo_rounded : Icons.check_rounded, size: 18),
                      label: Text(
                        _chore.isDone
                            ? (l10n?.choreCancelCompleted ?? 'Отменить выполнение')
                            : (l10n?.choreMarkCompleted ?? 'Отметить выполненным'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Bottom secondary buttons: Repeat settings + Delete in a Row
                  Row(
                    children: [
                      if (!_chore.isQuick && _chore.scheduleId != null) ...[
                        Expanded(
                          child: SizedBox(
                            height: 38,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35), width: 1.2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              onPressed: _loading ? null : _openRepeatSettings,
                              icon: const Icon(Icons.repeat_rounded, size: 15),
                              label: Text(
                                l10n?.choreRepeatSettings ?? 'Повторение',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: BorderSide(color: AppColors.error.withValues(alpha: 0.5), width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            onPressed: _loading ? null : _delete,
                            icon: const Icon(Icons.delete_outline_rounded, size: 15),
                            label: Text(
                              l10n?.choreDeleteTask ?? 'Удалить задачу',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Icon ──────────────────────────────────────────────────────────────────

  Widget _buildIcon() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 18, offset: const Offset(0, 6))],
          ),
          alignment: Alignment.center,
          child: ChoreIconWidget(
            icon: _chore.displayIcon,
            iconBg: _chore.displayIconBg,
            iconColor: _chore.displayIconColor,
            size: 48,
            isQuick: _chore.isQuick,
          ),
        ),
      ),
    );
  }

  // ─── Subtasks card ─────────────────────────────────────────────────────────

  // ─── Subtasks card ─────────────────────────────────────────────────────────

  Widget _buildSubtasksCard(AppLocalizations? l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 10, 0),
            child: Row(
              children: [
                Icon(Icons.checklist_rounded, size: 18, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n?.choreSubtasksNotes ?? 'Подзадачи и заметки', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(_editingSubtasks ? Icons.check_rounded : Icons.edit_rounded, size: 14),
                  label: Text(
                    _editingSubtasks ? (l10n?.commonSave ?? 'Сохранить') : (l10n?.commonEdit ?? 'Изменить'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  onPressed: _editingSubtasks ? _saveSubtasks : () => setState(() => _editingSubtasks = true),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: _editingSubtasks
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _msgCtrl,
                        maxLines: 6,
                        style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: l10n?.choreSubtasksHint ?? 'Чек-лист: - [ ] пункт\nЗаметка: просто текст',
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      if (_subtaskError != null) ...[
                        const SizedBox(height: 6),
                        Text(_subtaskError!, style: const TextStyle(fontSize: 12, color: AppColors.error)),
                      ],
                    ],
                  )
                : _chore.message.isNotEmpty
                    ? PlannedChoreSubtasksWidget(message: _chore.message, isChoreDone: _chore.isDone, onSubtaskToggled: (_) {})
                    : Text(
                        l10n?.choreSubtasksEmpty ?? 'Нет заметок. Нажмите «Изменить» чтобы добавить чек-лист или комментарий.',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
                      ),
          ),
        ],
      ),
    );
  }

  // ─── Details card ──────────────────────────────────────────────────────────

  Widget _buildDetailsCard(AppLocalizations? l10n, String locale) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      child: Column(
        children: [
          // Date row
          InkWell(
            onTap: _pickDate,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  _DetailIcon(icon: Icons.calendar_today_rounded, color: _dateChanged ? AppColors.primary : AppColors.textMuted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n?.choreDateLabel ?? 'Дата', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                        Text(
                          _fmt(_newDate, locale),
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _dateChanged ? AppColors.primary : AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_rounded, size: 14, color: AppColors.textMuted),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16),

          // Repeat row (if recurring)
          if (!_chore.isQuick && _chore.scheduleId != null) ...[
            InkWell(
              onTap: _openRepeatSettings,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    _DetailIcon(icon: Icons.repeat_rounded, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n?.choreSectionRepeat ?? 'ПОВТОРЕНИЕ', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                          Text(
                            l10n?.choreRepeatSettings ?? 'Настройки повторения',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit_rounded, size: 14, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
          ],

          // Assigned to
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const _DetailIcon(icon: Icons.person_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n?.choreAssignedLabel ?? 'Назначено', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                      _chore.assignedTo != null
                          ? Row(children: [
                              UserAvatarWidget(user: _chore.assignedTo, size: 22),
                              const SizedBox(width: 6),
                              Text(_chore.assignedTo!.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            ])
                          : Text(l10n?.choreUnassigned ?? 'Никто', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16),

          // Completed by
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _DetailIcon(icon: Icons.check_circle_rounded, color: _chore.isDone ? AppColors.success : AppColors.textMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n?.choreCompletedLabel ?? 'Выполнено', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                      _chore.completedBy != null
                          ? Row(children: [
                              UserAvatarWidget(user: _chore.completedBy, size: 22),
                              const SizedBox(width: 6),
                              Text(_chore.completedBy!.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.success)),
                            ])
                          : Text(l10n?.choreNotDoneYet ?? 'Ещё нет', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Detail icon helper ───────────────────────────────────────────────────────

class _DetailIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;

  const _DetailIcon({required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textMuted;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: effectiveColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
      alignment: Alignment.center,
      child: Icon(icon, size: 17, color: effectiveColor),
    );
  }
}
