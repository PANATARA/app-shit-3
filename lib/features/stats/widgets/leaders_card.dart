import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
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

  String _getCurrentWeekRange(String lang) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    final monStr = DateFormat('d MMM', lang).format(monday).replaceAll('.', '');
    final sunStr = DateFormat('d MMM', lang).format(sunday).replaceAll('.', '');
    return '$monStr — $sunStr';
  }

  static String pluralTasks(int count) {
    final rem10 = count % 10;
    final rem100 = count % 100;
    if (rem100 >= 11 && rem100 <= 19) return 'задач';
    if (rem10 == 1) return 'задача';
    if (rem10 >= 2 && rem10 <= 4) return 'задачи';
    return 'задач';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final displayLeaders = leaders.take(5).toList();

    return RepaintBoundary(
      child: UiCard(
        title: l10n?.statsWeeklyLeaders ?? 'ЛИДЕРЫ НЕДЕЛИ',
        action: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.borderSubtle, width: 0.5),
          ),
          child: Text(
            _getCurrentWeekRange(lang),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
        child: isLoading
            ? Column(
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              )
            : leaders.isEmpty
                ? _buildEmptyState()
                : _buildLeadersList(displayLeaders),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              size: 22,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Пока никто не выполнил задачи',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Выполняйте дела по дому, чтобы стать лидером недели',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeadersList(List<FamilyLeaderModel> displayLeaders) {
    return Column(
      children: displayLeaders.asMap().entries.map((entry) {
        final index = entry.key;
        final leader = entry.value;
        final isMe = currentUserId != null && leader.member.id == currentUserId;
        final isLast = index == displayLeaders.length - 1;

        return Column(
          children: [
            _LeaderRow(
              rank: index + 1,
              leader: leader,
              isMe: isMe,
            ),
            if (!isLast)
              Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.borderSubtle,
              ),
          ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        children: [
          // Rank Medal
          _RankBadge(rank: rank),
          const SizedBox(width: 12),

          // Avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rank == 1
                  ? const Color(0xFFFFB52E).withValues(alpha: 0.25)
                  : Colors.transparent,
            ),
            child: UserAvatarWidget(
              user: leader.member,
              size: 38,
            ),
          ),
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
                      fontWeight: isMe ? FontWeight.w800 : FontWeight.w700,
                      letterSpacing: -0.2,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Ты',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Score counter
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${leader.choreCompletionCount}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                Localizations.localeOf(context).languageCode == 'en'
                    ? (leader.choreCompletionCount == 1 ? 'task' : 'tasks')
                    : LeadersCard.pluralTasks(leader.choreCompletionCount),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    if (rank == 1) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFD76A), Color(0xFFFFB52E)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x40FFBE32),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          '1',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.0,
          ),
        ),
      );
    }

    if (rank == 2) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 0.5),
        ),
        alignment: Alignment.center,
        child: const Text(
          '2',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF334155),
            height: 1.0,
          ),
        ),
      );
    }

    if (rank == 3) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFED7AA), Color(0xFFFDBA74)],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 0.5),
        ),
        alignment: Alignment.center,
        child: const Text(
          '3',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF7C2D12),
            height: 1.0,
          ),
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceAlt,
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          height: 1.0,
        ),
      ),
    );
  }
}
