class ChoreItem {
  final String id;
  final String name;
  final String? description;
  final String icon;
  final String iconColor;
  final String iconBg;
  final int valuation;
  final String? defaultChoreId;

  const ChoreItem({
    required this.id,
    required this.name,
    this.description,
    this.icon = 'material-symbols:cleaning-services-rounded',
    this.iconColor = '#ffffff',
    this.iconBg = 'linear-gradient(135deg, #8a7f6e 0%, #6b5f50 100%)',
    this.valuation = 10,
    this.defaultChoreId,
  });

  factory ChoreItem.fromJson(Map<String, dynamic> json) {
    return ChoreItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      icon: json['icon']?.toString() ?? 'material-symbols:cleaning-services-rounded',
      iconColor: json['icon_color']?.toString() ?? '#ffffff',
      iconBg: json['icon_bg']?.toString() ?? '#8a7f6e',
      valuation: (json['valuation'] as num?)?.toInt() ?? 10,
      defaultChoreId: json['default_chore_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'icon_color': iconColor,
      'icon_bg': iconBg,
      'valuation': valuation,
      'default_chore_id': defaultChoreId,
    };
  }
}
