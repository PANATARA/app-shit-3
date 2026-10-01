class UserShort {
  final String id;
  final String name;
  final String? icon;
  final String? iconColor;
  final String? iconBg;
  final int experience;

  const UserShort({
    required this.id,
    required this.name,
    this.icon,
    this.iconColor,
    this.iconBg,
    this.experience = 0,
  });

  factory UserShort.fromJson(Map<String, dynamic> json) {
    return UserShort(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['username']?.toString() ?? '',
      icon: json['icon']?.toString(),
      iconColor: json['icon_color']?.toString(),
      iconBg: json['icon_bg']?.toString(),
      experience: (json['experience'] as num?)?.toInt() ?? 0,
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
    };
  }
}
