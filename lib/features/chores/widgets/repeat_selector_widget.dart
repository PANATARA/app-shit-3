import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/repeat_config_model.dart';

class RepeatSelectorWidget extends StatelessWidget {
  final RepeatConfig value;
  final ValueChanged<RepeatConfig> onChanged;

  const RepeatSelectorWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  void _update({
    String? frequencyType,
    int? interval,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    bool clearDayOfMonth = false,
  }) {
    var next = value.copyWith(
      frequencyType: frequencyType,
      interval: interval,
      daysOfWeek: daysOfWeek,
      dayOfMonth: dayOfMonth,
      clearDayOfMonth: clearDayOfMonth,
    );

    // Defensive defaults matching Svelte
    if (frequencyType == 'weekly' && next.daysOfWeek.isEmpty) {
      final now = DateTime.now();
      final jsDay = now.weekday == 7 ? 0 : now.weekday;
      next = next.copyWith(daysOfWeek: [jsDay]);
    }
    if (frequencyType == 'monthly' && next.dayOfMonth == null) {
      next = next.copyWith(dayOfMonth: DateTime.now().day);
    }

    onChanged(next);
  }

  void _toggleDay(int id) {
    final current = List<int>.from(value.daysOfWeek);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    _update(daysOfWeek: current);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── 4 Options Grid (2x2) ──────────────────────────────
        _buildFrequencyGrid(),

        // ─── Collapsible / Expandable Settings Panel ──────────
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: value.frequencyType == 'none'
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ─── Interval Stepper ────────────────────
                      _buildIntervalSection(),

                      // ─── Weekly Days Picker ──────────────────
                      if (value.frequencyType == 'weekly') ...[
                        const SizedBox(height: 16),
                        _buildWeeklySection(),
                      ],

                      // ─── Monthly Day Picker ──────────────────
                      if (value.frequencyType == 'monthly') ...[
                        const SizedBox(height: 16),
                        _buildMonthlySection(),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  // ─── Frequency 2x2 Grid ──────────────────────────────────────────────────────

  Widget _buildFrequencyGrid() {
    final options = [
      _RepeatOption(
        type: 'none',
        label: 'Не повторять',
        icon: Icons.block_rounded,
      ),
      _RepeatOption(
        type: 'daily',
        label: 'Ежедневно',
        icon: Icons.today_rounded,
      ),
      _RepeatOption(
        type: 'weekly',
        label: 'Еженедельно',
        icon: Icons.view_week_rounded,
      ),
      _RepeatOption(
        type: 'monthly',
        label: 'Ежемесячно',
        icon: Icons.calendar_month_rounded,
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildOptionCard(options[0])),
            const SizedBox(width: 10),
            Expanded(child: _buildOptionCard(options[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildOptionCard(options[2])),
            const SizedBox(width: 10),
            Expanded(child: _buildOptionCard(options[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionCard(_RepeatOption opt) {
    final isSelected = value.frequencyType == opt.type;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _update(frequencyType: opt.type),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  opt.icon,
                  size: 22,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  opt.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Interval Section ────────────────────────────────────────────────────────

  Widget _buildIntervalSection() {
    final interval = value.interval;
    final text = RepeatConfig.getIntervalText(interval, value.frequencyType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ПЕРИОДИЧНОСТЬ'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _buildStepperButton(
                icon: Icons.remove_rounded,
                enabled: interval > 1,
                onTap: () => _update(interval: max(1, interval - 1)),
              ),
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _buildStepperButton(
                icon: Icons.add_rounded,
                enabled: interval < 99,
                onTap: () => _update(interval: min(99, interval + 1)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Weekly Section ──────────────────────────────────────────────────────────

  Widget _buildWeeklySection() {
    final days = [
      _WeekDay(id: 1, label: 'Пн'),
      _WeekDay(id: 2, label: 'Вт'),
      _WeekDay(id: 3, label: 'Ср'),
      _WeekDay(id: 4, label: 'Чт'),
      _WeekDay(id: 5, label: 'Пт'),
      _WeekDay(id: 6, label: 'Сб'),
      _WeekDay(id: 0, label: 'Вс'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ДНИ НЕДЕЛИ'),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((d) {
            final active = value.daysOfWeek.contains(d.id);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _toggleDay(d.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? AppColors.primary : AppColors.surface,
                    border: Border.all(
                      color: active ? AppColors.primary : AppColors.border,
                      width: 1,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    d.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                      color: active ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        // Shortcuts row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildShortcutBtn(
              'Будни',
              () => _update(daysOfWeek: [1, 2, 3, 4, 5]),
            ),
            _buildShortcutDot(),
            _buildShortcutBtn(
              'Выходные',
              () => _update(daysOfWeek: [6, 0]),
            ),
            _buildShortcutDot(),
            _buildShortcutBtn(
              'Все дни',
              () => _update(daysOfWeek: [1, 2, 3, 4, 5, 6, 0]),
            ),
            _buildShortcutDot(),
            _buildShortcutBtn(
              'Сбросить',
              () => _update(daysOfWeek: []),
              isDanger: true,
            ),
          ],
        ),
      ],
    );
  }

  // ─── Monthly Section ─────────────────────────────────────────────────────────

  Widget _buildMonthlySection() {
    final day = value.dayOfMonth ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ЧИСЛО МЕСЯЦА'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _buildStepperButton(
                icon: Icons.remove_rounded,
                enabled: day > 1,
                onTap: () => _update(dayOfMonth: max(1, day - 1)),
              ),
              Expanded(
                child: Text(
                  '$day-е число месяца',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _buildStepperButton(
                icon: Icons.add_rounded,
                enabled: day < 31,
                onTap: () => _update(dayOfMonth: min(31, day + 1)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Presets row
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildPresetChip(
                label: '1-е число',
                selected: day == 1,
                onTap: () => _update(dayOfMonth: 1),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 5,
              child: _buildPresetChip(
                label: 'В середине (15-е)',
                selected: day == 15,
                onTap: () => _update(dayOfMonth: 15),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 4,
              child: _buildPresetChip(
                label: 'Конец месяца',
                selected: day == 31,
                onTap: () => _update(dayOfMonth: 31),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Common UI Elements ──────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: enabled ? onTap : null,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? AppColors.textPrimary : AppColors.textMuted.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutBtn(String label, VoidCallback onTap, {bool isDanger = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDanger ? AppColors.textMuted : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Text(
        '•',
        style: TextStyle(
          fontSize: 10,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RepeatOption {
  final String type;
  final String label;
  final IconData icon;

  const _RepeatOption({
    required this.type,
    required this.label,
    required this.icon,
  });
}

class _WeekDay {
  final int id;
  final String label;

  const _WeekDay({required this.id, required this.label});
}
