import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class WeekCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const WeekCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  late final PageController _pageController;
  int _currentWeekIndex = 1; // 0 = previous, 1 = current, 2 = next

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _getStartOfWeek(DateTime d) {
    final norm = _normalize(d);
    return norm.subtract(Duration(days: norm.weekday - 1));
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  late final DateTime _today;
  late final List<List<DateTime>> _weeks;

  @override
  void initState() {
    super.initState();
    _today = _normalize(DateTime.now());
    _pageController = PageController(initialPage: 1);

    final currentStart = _getStartOfWeek(_today);
    _weeks = [
      _generateWeek(currentStart.subtract(const Duration(days: 7))),
      _generateWeek(currentStart),
      _generateWeek(currentStart.add(const Duration(days: 7))),
    ];
  }

  List<DateTime> _generateWeek(DateTime startOfWeek) {
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getWeekdayName(DateTime date) {
    const weekdaysRu = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return weekdaysRu[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 68,
          child: PageView.builder(
            controller: _pageController,
            physics: const ClampingScrollPhysics(),
            itemCount: _weeks.length,
            onPageChanged: (index) {
              setState(() => _currentWeekIndex = index);
            },
            itemBuilder: (context, weekIdx) {
              final week = _weeks[weekIdx];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Row(
                  children: week.map((day) {
                    final isSelected = _isSameDay(day, widget.selectedDate);
                    final isToday = _isSameDay(day, _today);

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                        child: _DayButton(
                          weekday: _getWeekdayName(day),
                          dayNumber: day.day.toString(),
                          isSelected: isSelected,
                          isToday: isToday,
                          onTap: () => widget.onDateChanged(day),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final isActive = i == _currentWeekIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: isActive ? 16 : 5,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: isActive
                    ? AppColors.primary
                    : AppColors.border.withValues(alpha: 0.6),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _DayButton extends StatefulWidget {
  final String weekday;
  final String dayNumber;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _DayButton({
    required this.weekday,
    required this.dayNumber,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  State<_DayButton> createState() => _DayButtonState();
}

class _DayButtonState extends State<_DayButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration;
    Color weekdayColor;
    Color dayNumberColor;

    if (widget.isSelected) {
      decoration = BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      );
      weekdayColor = Colors.white.withValues(alpha: 0.88);
      dayNumberColor = Colors.white;
    } else if (widget.isToday) {
      decoration = BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary, width: 1.2),
      );
      weekdayColor = AppColors.primary;
      dayNumberColor = AppColors.primary;
    } else {
      decoration = BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      );
      weekdayColor = AppColors.textMuted;
      dayNumberColor = AppColors.textPrimary;
    }

    return AnimatedScale(
      scale: _isPressed ? 0.93 : 1.0,
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onTap();
          },
          borderRadius: BorderRadius.circular(18),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: decoration,
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.weekday,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                    color: weekdayColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.dayNumber,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: dayNumberColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
