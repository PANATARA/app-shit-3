import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/chore_item_model.dart';
import '../models/repeat_config_model.dart';
import '../models/user_short_model.dart';
import '../providers/board_provider.dart';
import '../repositories/chores_repository.dart';
import '../widgets/chore_icon_widget.dart';
import '../widgets/chore_screen_header.dart';
import '../widgets/repeat_selector_widget.dart';
import '../widgets/user_avatar_widget.dart';
import '../../../widgets/avatar_builder_widget.dart';

class CreateChoreStepTwoScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final bool isQuickTask;
  final ChoreItem? selectedChore;
  final String? customName;

  const CreateChoreStepTwoScreen({
    super.key,
    required this.selectedDate,
    required this.isQuickTask,
    required this.selectedChore,
    this.customName,
  });

  @override
  ConsumerState<CreateChoreStepTwoScreen> createState() => _State();
}

class _State extends ConsumerState<CreateChoreStepTwoScreen> {
  final _nameCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  late DateTime _dueDate;
  late RepeatConfig _repeat;
  String? _assignedToId;
  bool _submitting = false;
  String? _error;

  String _quickIcon = 'material-symbols:bolt-rounded';
  String _quickIconColor = '#ffffff';
  String _quickIconBg = 'linear-gradient(135deg, #F59E0B 0%, #F97316 100%)';

  List<UserShort> _members = [];
  bool _membersLoading = true;

  @override
  void initState() {
    super.initState();
    _dueDate = widget.selectedDate;
    _repeat = RepeatConfig(
      frequencyType: 'none',
      interval: 1,
      daysOfWeek: const [],
      dayOfMonth: null,
      startsAt: DateFormat('yyyy-MM-dd').format(_dueDate),
    );
    if (widget.customName != null) _nameCtrl.text = widget.customName!;
    _loadMembers();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    try {
      final m = await ref.read(choresRepositoryProvider).getFamilyMembers();
      if (mounted) setState(() { _members = m; _membersLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _membersLoading = false);
    }
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (widget.isQuickTask && name.isEmpty) {
      setState(() => _error = 'Введите название задачи');
      return;
    }
    setState(() { _submitting = true; _error = null; });

    final dateStr = DateFormat('yyyy-MM-dd').format(_dueDate);
    final msg = _msgCtrl.text.trim().isEmpty ? null : _msgCtrl.text.trim();
    final repo = ref.read(choresRepositoryProvider);

    try {
      if (widget.isQuickTask) {
        await repo.createQuickChore(
          name: name,
          dueDate: dateStr,
          assignedToId: _assignedToId,
          message: msg,
          icon: _quickIcon,
          iconColor: _quickIconColor,
          iconBg: _quickIconBg,
        );
      } else if (_repeat.frequencyType != 'none') {
        final chore = widget.selectedChore!;
        final currentUserId = ref.read(authProvider).user?.id;
        final finalAssignedTo = _assignedToId ??
            currentUserId ??
            (_members.isNotEmpty ? _members.first.id : null);

        if (finalAssignedTo == null) {
          setState(() => _error = 'Выберите исполнителя для расписания');
          return;
        }

        int? daysOfWeekMask;
        if (_repeat.frequencyType == 'weekly') {
          var mask = RepeatConfig.daysOfWeekToBitmask(_repeat.daysOfWeek);
          if (mask == 0) {
            final jsDay = _dueDate.weekday == 7 ? 0 : _dueDate.weekday;
            mask = 1 << (jsDay == 0 ? 6 : jsDay - 1);
          }
          daysOfWeekMask = mask;
        }

        int? dayOfMonth;
        if (_repeat.frequencyType == 'monthly') {
          dayOfMonth = _repeat.dayOfMonth ?? _dueDate.day;
        }

        await repo.addChoreSchedule(
          choreId: chore.id,
          frequencyType: _repeat.frequencyType,
          interval: _repeat.interval < 1 ? 1 : _repeat.interval,
          startsAt: dateStr,
          assignedToId: finalAssignedTo,
          endsAt: _repeat.endsAt,
          daysOfWeek: daysOfWeekMask,
          dayOfMonth: dayOfMonth,
        );
      } else {
        final chore = widget.selectedChore!;
        if (chore.id.isEmpty) {
          await repo.createQuickChore(
            name: chore.name,
            dueDate: dateStr,
            assignedToId: _assignedToId,
            message: msg,
            icon: chore.icon,
            iconColor: chore.iconColor,
            iconBg: chore.iconBg,
          );
        } else {
          await repo.addPlannedChore(
            choreId: chore.id,
            dueDate: dateStr,
            assignedToId: _assignedToId,
            message: msg,
          );
        }
      }
      if (!mounted) return;
      ref.read(boardNotifierProvider.notifier).refresh();
      Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Не удалось создать: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary, surface: AppColors.surface)),
        child: child!,
      ),
    );
    if (p != null && mounted) {
      setState(() {
        _dueDate = p;
        _repeat = _repeat.copyWith(startsAt: DateFormat('yyyy-MM-dd').format(p));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isQuickTask ? 'Быстрая задача' : (widget.selectedChore?.name ?? '');
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      // No bottomNavigationBar — everything in body Column
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── Header ────────────────────────────────────────
            ChoreScreenHeader(title: title, onBack: () => Navigator.of(context).pop()),

            // ─── Scrollable content ────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildIconSection(),
                    const SizedBox(height: 8),
                    if (widget.isQuickTask) ...[
                      _card('НАЗВАНИЕ', _textField(_nameCtrl, 'Что нужно сделать?', autofocus: false)),
                      const SizedBox(height: 8),
                    ],
                    _card('КОМУ НАЗНАЧИТЬ', _membersPicker()),
                    const SizedBox(height: 8),
                    _card('ДЕТАЛИ', Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _textField(_msgCtrl, 'Добавить заметку или чек-лист...', maxLines: 4),
                        const SizedBox(height: 12),
                        Divider(color: AppColors.border, height: 1),
                        const SizedBox(height: 12),
                        _dateRow(),
                      ],
                    )),
                    if (!widget.isQuickTask) ...[
                      const SizedBox(height: 8),
                      _card(
                        'ПОВТОРЕНИЕ',
                        RepeatSelectorWidget(
                          value: _repeat,
                          onChanged: (val) => setState(() => _repeat = val),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ─── Fixed bottom button ───────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, safeBottom + 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(_error!, style: const TextStyle(fontSize: 13, color: AppColors.error), textAlign: TextAlign.center),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Добавить', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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

  // ─── Icon section ────────────────────────────────────────────────────────────

  Widget _buildIconSection() {
    if (widget.isQuickTask) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: AvatarBuilderWidget(
          initialIcon: _quickIcon,
          initialIconColor: _quickIconColor,
          initialBg: _quickIconBg,
          onChanged: (val) {
            setState(() {
              _quickIcon = val.icon;
              _quickIconColor = val.iconColor;
              _quickIconBg = val.iconBg;
            });
          },
        ),
      );
    }
    final chore = widget.selectedChore;
    if (chore == null) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 28, offset: const Offset(0, 10))],
          ),
          alignment: Alignment.center,
          child: ChoreIconWidget(icon: chore.icon, iconBg: chore.iconBg, iconColor: chore.iconColor, size: 64),
        ),
      ),
    );
  }

  // ─── Section card ────────────────────────────────────────────────────────────

  Widget _card(String label, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.7)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // ─── Text field ──────────────────────────────────────────────────────────────

  Widget _textField(TextEditingController ctrl, String hint, {int maxLines = 1, bool autofocus = false}) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        autofocus: autofocus,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w400, fontSize: 14),
          filled: false,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  // ─── Members picker ──────────────────────────────────────────────────────────

  Widget _membersPicker() {
    if (_membersLoading) {
      return SizedBox(
        height: 60,
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
      );
    }
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _MemberBtn(userId: null, name: 'Никто', user: null, selected: _assignedToId == null, onTap: () => setState(() => _assignedToId = null)),
          ..._members.map((u) => _MemberBtn(userId: u.id, name: u.name, user: u, selected: _assignedToId == u.id, onTap: () => setState(() => _assignedToId = u.id))),
        ],
      ),
    );
  }

  // ─── Date row ───────────────────────────────────────────────────────────────

  Widget _dateRow() {
    final str = DateFormat('d MMMM yyyy', 'ru').format(_dueDate);
    return GestureDetector(
      onTap: _pickDate,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded, size: 17, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Дата выполнения', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                Text(str, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
          Icon(Icons.edit_rounded, size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

// ─── Member avatar button ─────────────────────────────────────────────────────

class _MemberBtn extends StatelessWidget {
  final String? userId;
  final String name;
  final UserShort? user;
  final bool selected;
  final VoidCallback onTap;

  const _MemberBtn({required this.userId, required this.name, required this.user, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 2, bottom: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 2.5),
                boxShadow: selected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: 2)] : null,
              ),
              child: UserAvatarWidget(user: user, size: 44),
            ),
            const SizedBox(height: 5),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? AppColors.primary : AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
