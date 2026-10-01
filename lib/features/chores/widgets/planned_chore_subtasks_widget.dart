import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../models/subtask_model.dart';
import '../utils/checklist_helper.dart';

class PlannedChoreSubtasksWidget extends StatelessWidget {
  final String? message;
  final bool isChoreDone;
  final void Function(Subtask subtask)? onSubtaskToggled;

  const PlannedChoreSubtasksWidget({
    super.key,
    required this.message,
    this.isChoreDone = false,
    this.onSubtaskToggled,
  });

  @override
  Widget build(BuildContext context) {
    final parsed = ChecklistHelper.parseMessage(message);

    if (parsed.description.isEmpty && parsed.subtasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plain description text
          if (parsed.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                parsed.description,
                style: TextStyle(
                  fontSize: 13,
                  color: isChoreDone ? AppColors.textMuted : AppColors.textSecondary,
                  decoration: isChoreDone ? TextDecoration.lineThrough : null,
                  height: 1.3,
                ),
              ),
            ),

          // Checklist items
          if (parsed.hasSubtasks)
            ...parsed.subtasks.map((subtask) {
              final isDone = subtask.done || isChoreDone;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Subtask checkbox
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onSubtaskToggled?.call(subtask);
                      },
                      child: Container(
                        width: 17,
                        height: 17,
                        margin: const EdgeInsets.only(right: 7),
                        decoration: BoxDecoration(
                          color: subtask.done ? AppColors.success : AppColors.surface,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: subtask.done
                                ? AppColors.success
                                : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: subtask.done
                            ? const Icon(
                                Icons.check_rounded,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),

                    // Subtask text
                    Expanded(
                      child: Text(
                        subtask.text,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
