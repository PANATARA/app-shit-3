import 'user_short_model.dart';

class FamilyMembersModel {
  final List<UserShort> members;

  const FamilyMembersModel({required this.members});

  factory FamilyMembersModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'];
    if (rawMembers is List) {
      return FamilyMembersModel(
        members: rawMembers
            .map((e) => UserShort.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    return const FamilyMembersModel(members: []);
  }
}
