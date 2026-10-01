class IngredientModel {
  final String id;
  final String name;
  final double amount;
  final String unit;
  final bool checked;

  const IngredientModel({
    required this.id,
    required this.name,
    this.amount = 0.0,
    this.unit = '',
    this.checked = false,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json, [int fallbackIndex = 0]) {
    final rawAmount = json['amount'];
    double parsedAmount = 0.0;
    if (rawAmount is num) {
      parsedAmount = rawAmount.toDouble();
    } else if (rawAmount is String && rawAmount.trim().isNotEmpty) {
      parsedAmount = double.tryParse(rawAmount) ?? 0.0;
    }

    return IngredientModel(
      id: json['id']?.toString() ?? 'ing-$fallbackIndex',
      name: json['name']?.toString() ?? '',
      amount: parsedAmount,
      unit: json['unit']?.toString() ?? '',
      checked: json['checked'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
      'checked': checked,
    };
  }

  IngredientModel copyWith({
    String? id,
    String? name,
    double? amount,
    String? unit,
    bool? checked,
  }) {
    return IngredientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      checked: checked ?? this.checked,
    );
  }
}

class RecipeStepModel {
  final int number;
  final String text;

  const RecipeStepModel({
    required this.number,
    required this.text,
  });

  factory RecipeStepModel.fromJson(dynamic json, [int fallbackIndex = 1]) {
    if (json is String) {
      return RecipeStepModel(number: fallbackIndex, text: json);
    }
    if (json is Map<String, dynamic>) {
      return RecipeStepModel(
        number: (json['number'] as num?)?.toInt() ?? fallbackIndex,
        text: json['text']?.toString() ?? '',
      );
    }
    return RecipeStepModel(number: fallbackIndex, text: '');
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'text': text,
    };
  }
}

class RecipeModel {
  final String id;
  final String title;
  final String description;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int baseServings;
  final String category;
  final List<String> tags;
  final bool isFavorite;
  final bool isCustom;
  final String accentGradient;
  final String emoji;
  final List<IngredientModel> ingredients;
  final List<RecipeStepModel> steps;
  final DateTime? createdAt;

  const RecipeModel({
    required this.id,
    required this.title,
    this.description = '',
    this.prepTimeMinutes = 10,
    this.cookTimeMinutes = 20,
    this.baseServings = 4,
    this.category = 'quick',
    this.tags = const [],
    this.isFavorite = false,
    this.isCustom = false,
    this.accentGradient = 'linear-gradient(135deg, #F97316 0%, #EA580C 100%)',
    this.emoji = '🍲',
    this.ingredients = const [],
    this.steps = const [],
    this.createdAt,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final rawIngredients = json['ingredients'];
    List<IngredientModel> parsedIngredients = [];
    if (rawIngredients is List) {
      for (int i = 0; i < rawIngredients.length; i++) {
        final item = rawIngredients[i];
        if (item is Map<String, dynamic>) {
          parsedIngredients.add(IngredientModel.fromJson(item, i));
        }
      }
    }

    final rawSteps = json['steps'];
    List<RecipeStepModel> parsedSteps = [];
    if (rawSteps is List) {
      for (int i = 0; i < rawSteps.length; i++) {
        parsedSteps.add(RecipeStepModel.fromJson(rawSteps[i], i + 1));
      }
    }

    final rawTags = json['tags'];
    List<String> parsedTags = [];
    if (rawTags is List) {
      parsedTags = rawTags.map((t) => t.toString()).toList();
    }

    DateTime? parsedCreatedAt;
    if (json['created_at'] != null) {
      parsedCreatedAt = DateTime.tryParse(json['created_at'].toString());
    }

    return RecipeModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      prepTimeMinutes: (json['prep_time_minutes'] ?? json['prepTimeMinutes'] as num?)?.toInt() ?? 10,
      cookTimeMinutes: (json['cook_time_minutes'] ?? json['cookTimeMinutes'] as num?)?.toInt() ?? 20,
      baseServings: (json['base_servings'] ?? json['baseServings'] as num?)?.toInt() ?? 4,
      category: json['category']?.toString() ?? 'quick',
      tags: parsedTags,
      isFavorite: json['is_favorite'] == true || json['isFavorite'] == true,
      isCustom: json['is_custom'] == true || json['isCustom'] == true,
      accentGradient: json['accent_gradient']?.toString() ??
          json['accentGradient']?.toString() ??
          'linear-gradient(135deg, #F97316 0%, #EA580C 100%)',
      emoji: json['emoji']?.toString() ?? '🍲',
      ingredients: parsedIngredients,
      steps: parsedSteps,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
      'base_servings': baseServings,
      'category': category,
      'tags': tags,
      'is_favorite': isFavorite,
      'is_custom': isCustom,
      'accent_gradient': accentGradient,
      'emoji': emoji,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'steps': steps.map((s) => s.toJson()).toList(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  RecipeModel copyWith({
    String? id,
    String? title,
    String? description,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? baseServings,
    String? category,
    List<String>? tags,
    bool? isFavorite,
    bool? isCustom,
    String? accentGradient,
    String? emoji,
    List<IngredientModel>? ingredients,
    List<RecipeStepModel>? steps,
    DateTime? createdAt,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      baseServings: baseServings ?? this.baseServings,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isCustom: isCustom ?? this.isCustom,
      accentGradient: accentGradient ?? this.accentGradient,
      emoji: emoji ?? this.emoji,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
