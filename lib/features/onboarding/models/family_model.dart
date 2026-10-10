class FamilyModel {
  final String id;
  final String name;
  final String icon;
  final String iconColor;
  final String iconBg;
  final int experience;
  final int totalCompleted;

  const FamilyModel({
    required this.id,
    required this.name,
    this.icon = 'material-symbols:family-home-rounded',
    this.iconColor = '#ffffff',
    this.iconBg = 'linear-gradient(135deg, #F97316 0%, #FB7185 100%)',
    this.experience = 0,
    this.totalCompleted = 0,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'material-symbols:family-home-rounded',
      iconColor: json['icon_color']?.toString() ?? '#ffffff',
      iconBg: json['icon_bg']?.toString() ?? 'linear-gradient(135deg, #F97316 0%, #FB7185 100%)',
      experience: (json['experience'] as num?)?.toInt() ?? 0,
      totalCompleted: (json['total_completed'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'icon_color': iconColor,
      'icon_bg': iconBg,
      'experience': experience,
      'total_completed': totalCompleted,
    };
  }
}
