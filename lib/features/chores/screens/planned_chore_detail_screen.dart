import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../models/planned_chore_model.dart';
import '../models/user_short_model.dart';
import '../providers/board_provider.dart';
import '../repositories/chores_repository.dart';
import '../widgets/chore_icon_widget.dart';
import '../widgets/chore_screen_header.dart';
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

  String _fmt(DateTime? d) => d == null ? '—' : DateFormat('d MMMM yyyy', 'ru').format(d);

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

  Future<void> _delete() async {
    final ok = await _confirm();
    if (!ok || !mounted) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(choresRepositoryProvider);
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
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Удалить задачу?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            content: Text('Это действие нельзя отменить.', style: TextStyle(color: AppColors.textSecondary)),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Отмена', style: TextStyle(color: AppColors.textMuted))),
              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Удалить', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700))),
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
                    _buildSubtasksCard(),
                    const SizedBox(height: 10),
                    _buildDetailsCard(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ─── Fixed action buttons at bottom ───────────────────
            Container(
              padding: EdgeInsets.fromLTRB(14, 12, 14, safeBottom + 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toggle done
                  SizedBox(
                    width: double.infinity,
                    height: 50,
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
                        _chore.isDone ? 'Отменить выполнение' : 'Отметить выполненным',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  // Reschedule — only when date changed
                  if (_dateChanged && !_chore.isDone) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: _loading ? null : _reschedule,
                        icon: const Icon(Icons.calendar_month_rounded, size: 18),
                        label: Text('Перенести на ${_fmt(_newDate)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Delete
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _loading ? null : _delete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Удалить задачу', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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

  // ─── Icon ──────────────────────────────────────────────────────────────────

  Widget _buildIcon() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.09), blurRadius: 28, offset: const Offset(0, 10))],
          ),
          alignment: Alignment.center,
          child: ChoreIconWidget(
            icon: _chore.displayIcon,
            iconBg: _chore.displayIconBg,
            iconColor: _chore.displayIconColor,
            size: 64,
            isQuick: _chore.isQuick,
          ),
        ),
      ),
    );
  }

  // ─── Subtasks card ─────────────────────────────────────────────────────────

  Widget _buildSubtasksCard() {
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
                  child: Text('Подзадачи и заметки', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
                    _editingSubtasks ? 'Сохранить' : 'Изменить',
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
                          hintText: 'Чек-лист: - [ ] пункт\nЗаметка: просто текст',
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
                        'Нет заметок. Нажмите «Изменить» чтобы добавить чек-лист или комментарий.',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
                      ),
          ),
        ],
      ),
    );
  }

  // ─── Details card ──────────────────────────────────────────────────────────

  Widget _buildDetailsCard() {
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
                        Text('Дата', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                        Text(
                          _fmt(_newDate),
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
                      Text('Назначено', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                      _chore.assignedTo != null
                          ? Row(children: [
                              UserAvatarWidget(user: _chore.assignedTo, size: 22),
                              const SizedBox(width: 6),
                              Text(_chore.assignedTo!.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            ])
                          : Text('Никто', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
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
                      Text('Выполнено', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                      _chore.completedBy != null
                          ? Row(children: [
                              UserAvatarWidget(user: _chore.completedBy, size: 22),
                              const SizedBox(width: 6),
                              Text(_chore.completedBy!.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.success)),
                            ])
                          : Text('Ещё нет', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
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
