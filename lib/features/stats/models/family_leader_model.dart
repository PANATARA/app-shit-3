import '../../chores/models/user_short_model.dart';

class FamilyLeaderModel {
  final UserShort member;
  final int choreCompletionCount;

  const FamilyLeaderModel({
    required this.member,
    required this.choreCompletionCount,
  });

  factory FamilyLeaderModel.fromJson(Map<String, dynamic> json) {
    final memberJson = json['member'];
    final member = memberJson is Map<String, dynamic>
        ? UserShort.fromJson(memberJson)
        : const UserShort(id: '', name: 'Участник');

    return FamilyLeaderModel(
      member: member,
      choreCompletionCount: (json['chore_completion_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'member': member.toJson(),
        'chore_completion_count': choreCompletionCount,
      };
}

class WeeklyLeadersResponseModel {
  final List<FamilyLeaderModel> leaders;

  const WeeklyLeadersResponseModel({required this.leaders});

  factory WeeklyLeadersResponseModel.fromJson(Map<String, dynamic> json) {
    final list = json['leaders'];
    if (list is List) {
      return WeeklyLeadersResponseModel(
        leaders: list
            .whereType<Map<String, dynamic>>()
            .map((e) => FamilyLeaderModel.fromJson(e))
            .toList(),
      );
    }
    return const WeeklyLeadersResponseModel(leaders: []);
  }

  Map<String, dynamic> toJson() => {
        'leaders': leaders.map((e) => e.toJson()).toList(),
      };
}
