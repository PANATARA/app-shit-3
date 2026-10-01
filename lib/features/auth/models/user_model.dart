class UserModel {
  final String id;
  final String username;
  final String? email;
  final String? name;
  final String? icon;
  final String? iconColor;
  final String? iconBg;
  final int level;
  final int? expToNextTotal;
  final int progressPercent;
  final int experience;
  final int totalCompleted;
  final int weekCompleted;
  final int monthCompleted;
  final bool isMaxLevel;
  final bool isFamilyMember;
  final bool isFamilyAdmin;
  final String? familyId;

  const UserModel({
    required this.id,
    required this.username,
    this.email,
    this.name,
    this.icon,
    this.iconColor,
    this.iconBg,
    this.level = 1,
    this.expToNextTotal,
    this.progressPercent = 0,
    this.experience = 0,
    this.totalCompleted = 0,
    this.weekCompleted = 0,
    this.monthCompleted = 0,
    this.isMaxLevel = false,
    this.isFamilyMember = false,
    this.isFamilyAdmin = false,
    this.familyId,
  });

  String get displayName {
    if (name != null && name!.trim().isNotEmpty) {
      return name!.trim();
    }
    return username;
  }

  bool get isInFamily => isFamilyMember || (familyId != null && familyId!.isNotEmpty);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString(),
      name: json['name']?.toString() ?? json['first_name']?.toString(),
      icon: json['icon']?.toString(),
      iconColor: json['icon_color']?.toString(),
      iconBg: json['icon_bg']?.toString(),
      level: (json['level'] as num?)?.toInt() ?? 1,
      expToNextTotal: (json['exp_to_next_total'] as num?)?.toInt(),
      progressPercent: (json['progress_percent'] as num?)?.toInt() ?? 0,
      experience: (json['experience'] as num?)?.toInt() ?? 0,
      totalCompleted: (json['total_completed'] as num?)?.toInt() ?? 0,
      weekCompleted: (json['week_completed'] as num?)?.toInt() ?? 0,
      monthCompleted: (json['month_completed'] as num?)?.toInt() ?? 0,
      isMaxLevel: json['is_max_level'] == true,
      isFamilyMember: json['is_family_member'] == true || json['family_id'] != null,
      isFamilyAdmin: json['is_family_admin'] == true,
      familyId: json['family_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'icon': icon,
      'icon_color': iconColor,
      'icon_bg': iconBg,
      'level': level,
      'exp_to_next_total': expToNextTotal,
      'progress_percent': progressPercent,
      'experience': experience,
      'total_completed': totalCompleted,
      'week_completed': weekCompleted,
      'month_completed': monthCompleted,
      'is_max_level': isMaxLevel,
      'is_family_member': isFamilyMember,
      'is_family_admin': isFamilyAdmin,
      'family_id': familyId,
    };
  }
}
