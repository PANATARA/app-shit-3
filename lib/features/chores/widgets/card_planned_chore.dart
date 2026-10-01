import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../models/planned_chore_model.dart';
import '../models/subtask_model.dart';
import '../utils/checklist_helper.dart';
import 'chore_icon_widget.dart';
import 'planned_chore_subtasks_widget.dart';
import 'user_avatar_widget.dart';

class CardPlannedChore extends StatefulWidget {
  final PlannedChoreModel item;
  final bool isCompleting;
  final ValueChanged<PlannedChoreModel> onToggle;
  final ValueChanged<PlannedChoreModel>? onClick;
  final void Function(PlannedChoreModel item, String newMessage)? onUpdateMessage;

  const CardPlannedChore({
    super.key,
    required this.item,
    this.isCompleting = false,
    required this.onToggle,
    this.onClick,
    this.onUpdateMessage,
  });

  @override
  State<CardPlannedChore> createState() => _CardPlannedChoreState();
}

class _CardPlannedChoreState extends State<CardPlannedChore>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _particleAnimation;
  bool _isPressed = false;
  bool _localCompleted = false;

  @override
  void initState() {
    super.initState();
    _localCompleted = widget.item.isDone;
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.82), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.82, end: 1.18), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(CardPlannedChore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.isDone != oldWidget.item.isDone) {
      _localCompleted = widget.item.isDone;
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    HapticFeedback.mediumImpact();
    if (!widget.item.isDone) {
      setState(() => _localCompleted = true);
      _confettiController.forward(from: 0.0);
    } else {
      setState(() => _localCompleted = false);
    }
    widget.onToggle(widget.item);
  }

  void _handleSubtaskToggled(Subtask subtask) {
    final parsed = ChecklistHelper.parseMessage(widget.item.message);
    final updatedSubtasks = parsed.subtasks.map((st) {
      if (st.id == subtask.id) {
        return st.copyWith(done: !st.done);
      }
      return st;
    }).toList();

    final newMessage = ChecklistHelper.serializeMessage(parsed.description, updatedSubtasks);
    widget.onUpdateMessage?.call(widget.item, newMessage);
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.item.isDone || widget.isCompleting || _localCompleted;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => widget.onClick?.call(widget.item),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: isDone ? AppColors.surfaceAlt : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDone ? Colors.transparent : AppColors.borderSubtle,
              width: 0.5,
            ),
            boxShadow: isDone
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: AnimatedOpacity(
            opacity: isDone ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 220),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Chore icon
                ChoreIconWidget(
                  icon: widget.item.displayIcon,
                  iconBg: widget.item.displayIconBg,
                  iconColor: widget.item.displayIconColor,
                  size: widget.item.isQuick ? 42 : 44,
                  isQuick: widget.item.isQuick,
                ),
                const SizedBox(width: 14),

                // Center content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title row
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.item.displayTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.25,
                                color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (!widget.item.isQuick && widget.item.scheduleId != null) ...[
                            const SizedBox(width: 5),
                            Icon(
                              Icons.repeat_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ],
                      ),

                      // Description and subtasks
                      if (widget.item.message.isNotEmpty)
                        PlannedChoreSubtasksWidget(
                          message: widget.item.message,
                          isChoreDone: isDone,
                          onSubtaskToggled: _handleSubtaskToggled,
                        ),

                      // Assignee or Completed Badge
                      if (widget.item.assignedTo != null && !isDone) ...[
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.borderSubtle, width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              UserAvatarWidget(user: widget.item.assignedTo, size: 16),
                              const SizedBox(width: 5),
                              Text(
                                widget.item.assignedTo!.name,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (widget.item.completedBy != null) ...[
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.successSoft,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.25),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              UserAvatarWidget(user: widget.item.completedBy, size: 16),
                              const SizedBox(width: 5),
                              Text(
                                widget.item.completedBy!.name,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Right checkbox button with confetti
                GestureDetector(
                  onTap: _handleToggle,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Confetti particles
                        AnimatedBuilder(
                          animation: _confettiController,
                          builder: (context, _) {
                            if (!_confettiController.isAnimating) {
                              return const SizedBox.shrink();
                            }
                            return CustomPaint(
                              size: const Size(60, 60),
                              painter: _ConfettiPainter(progress: _particleAnimation.value),
                            );
                          },
                        ),

                        // Checkbox circle
                        AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _confettiController.isAnimating
                                  ? _scaleAnimation.value
                                  : 1.0,
                              child: child,
                            );
                          },
                          child: ClipOval(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone
                                    ? AppColors.success
                                    : AppColors.surface,
                                border: Border.all(
                                  color: isDone
                                      ? AppColors.success
                                      : AppColors.border,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: AnimatedScale(
                                scale: isDone ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOutBack,
                                child: AnimatedOpacity(
                                  opacity: isDone ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 140),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter({required this.progress});

  static const List<Color> _colors = [
    Color(0xFF34C759),
    Color(0xFFFF9500),
    Color(0xFF5856D6),
    Color(0xFF007AFF),
    Color(0xFFFF2D55),
    Color(0xFF30D158),
    Color(0xFFFFCC00),
    Color(0xFFAF52DE),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    // Expanding ring
    final ringPaint = Paint()
      ..color = AppColors.success.withValues(alpha: opacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, 14.0 + progress * 20.0, ringPaint);

    // 8 flying particles
    final particleRadius = 2.5 * (1.0 - progress * 0.4);
    final distance = 16.0 + progress * 24.0;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * math.pi / 180;
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      final paint = Paint()
        ..color = _colors[i % _colors.length].withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
