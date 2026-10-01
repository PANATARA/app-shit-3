import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../chores/widgets/user_avatar_widget.dart';
import '../models/family_leader_model.dart';
import 'ui_card.dart';

class LeadersCard extends StatelessWidget {
  final List<FamilyLeaderModel> leaders;
  final String? currentUserId;
  final bool isLoading;

  const LeadersCard({
    super.key,
    required this.leaders,
    this.currentUserId,
    this.isLoading = false,
  });

  String _getCurrentWeekRange() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    final monStr = DateFormat('d MMM', 'ru').format(monday).replaceAll('.', '');
    final sunStr = DateFormat('d MMM', 'ru').format(sunday).replaceAll('.', '');
    return '$monStr — $sunStr';
  }

  @override
  Widget build(BuildContext context) {
    return UiCard(
      title: 'ЛИДЕРЫ НЕДЕЛИ',
      action: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        ),
        child: Text(
          _getCurrentWeekRange(),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
        ),
      ),
      child: isLoading
          ? Column(
              children: List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            )
          : leaders.isEmpty
              ? _buildEmptyState()
              : _buildLeadersList(),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Text('🏆', style: TextStyle(fontSize: 36)),
          SizedBox(height: 8),
          Text(
            'Пока никто не выполнил задачи',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          SizedBox(height: 4),
          Text(
            'Будь первым на этой неделе',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadersList() {
    return Column(
      children: leaders.asMap().entries.map((entry) {
        final index = entry.key;
        final leader = entry.value;
        final isMe = currentUserId != null && leader.member.id == currentUserId;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _LeaderRow(
            rank: index + 1,
            leader: leader,
            isMe: isMe,
          ),
        );
      }).toList(),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final int rank;
  final FamilyLeaderModel leader;
  final bool isMe;

  const _LeaderRow({
    required this.rank,
    required this.leader,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    BoxDecoration rowDecor;
    if (rank == 1) {
      rowDecor = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primarySoft,
            AppColors.surfaceAlt,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.28), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } else if (isMe) {
      rowDecor = BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 0.8),
      );
    } else {
      rowDecor = BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      );
    }

    // Rank medal decoration
    BoxDecoration rankDecor;
    Color rankTextColor;
    if (rank == 1) {
      rankDecor = const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD76A), Color(0xFFFFB52E)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x59FFBE32),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      );
      rankTextColor = const Color(0xFF6B4300);
    } else if (rank == 2) {
      rankDecor = BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withValues(alpha: 0.2),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      );
      rankTextColor = AppColors.textPrimary;
    } else if (rank == 3) {
      rankDecor = BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFCD8246).withValues(alpha: 0.2),
        border: Border.all(color: const Color(0xFFCD8246).withValues(alpha: 0.3), width: 0.5),
      );
      rankTextColor = const Color(0xFFD88C50);
    } else {
      rankDecor = BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      );
      rankTextColor = AppColors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: rowDecor,
      child: Row(
        children: [
          // Rank Medal
          Container(
            width: 28,
            height: 28,
            decoration: rankDecor,
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: rankTextColor,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Avatar
          UserAvatarWidget(user: leader.member, size: 40),
          const SizedBox(width: 12),

          // Name + "Ты" badge
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    leader.member.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Ты',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${leader.choreCompletionCount}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: rank == 1 ? AppColors.primary : AppColors.textPrimary,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'задач',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
