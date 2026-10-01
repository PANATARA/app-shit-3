class GroceryItemModel {
  final String id;
  final String name;
  final double? amount;
  final String? unit;
  final String? category;
  final bool checked;
  final String? addedFromRecipe;
  final DateTime? createdAt;

  const GroceryItemModel({
    required this.id,
    required this.name,
    this.amount,
    this.unit,
    this.category,
    this.checked = false,
    this.addedFromRecipe,
    this.createdAt,
  });

  factory GroceryItemModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    double? parsedAmount;
    if (rawAmount is num) {
      parsedAmount = rawAmount.toDouble();
    } else if (rawAmount is String && rawAmount.trim().isNotEmpty) {
      parsedAmount = double.tryParse(rawAmount);
    }

    DateTime? parsedCreatedAt;
    if (json['created_at'] != null) {
      parsedCreatedAt = DateTime.tryParse(json['created_at'].toString());
    }

    return GroceryItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: parsedAmount,
      unit: json['unit']?.toString(),
      category: json['category']?.toString(),
      checked: json['is_bought'] == true || json['checked'] == true,
      addedFromRecipe: json['added_from_recipe']?.toString() ?? json['addedFromRecipe']?.toString(),
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
      'category': category,
      'is_bought': checked,
      'added_from_recipe': addedFromRecipe,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  GroceryItemModel copyWith({
    String? id,
    String? name,
    double? amount,
    String? unit,
    String? category,
    bool? checked,
    String? addedFromRecipe,
    DateTime? createdAt,
  }) {
    return GroceryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      checked: checked ?? this.checked,
      addedFromRecipe: addedFromRecipe ?? this.addedFromRecipe,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
