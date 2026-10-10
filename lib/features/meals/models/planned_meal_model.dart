import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../chores/models/user_short_model.dart';

class MealSlotDefinition {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final Color bg;

  const MealSlotDefinition({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.bg,
  });

  String getLocalizedName([AppLocalizations? l10n]) {
    if (l10n == null) return name;
    switch (id) {
      case 'breakfast':
        return l10n.slotBreakfast;
      case 'lunch':
        return l10n.slotLunch;
      case 'dinner':
        return l10n.slotDinner;
      case 'snack':
        return l10n.slotSnack;
      default:
        return name;
    }
  }

  static const List<MealSlotDefinition> all = [
    MealSlotDefinition(
      id: 'breakfast',
      name: 'Завтрак',
      icon: Icons.wb_sunny_rounded,
      color: Color(0xFFD97706),
      bg: Color(0x1FF59E0B),
    ),
    MealSlotDefinition(
      id: 'lunch',
      name: 'Обед',
      icon: Icons.wb_twilight_rounded,
      color: Color(0xFF2563EB),
      bg: Color(0x1F2563EB),
    ),
    MealSlotDefinition(
      id: 'dinner',
      name: 'Ужин',
      icon: Icons.bedtime_rounded,
      color: Color(0xFFE06A47),
      bg: Color(0x1FE06A47),
    ),
    MealSlotDefinition(
      id: 'snack',
      name: 'Перекус',
      icon: Icons.eco_rounded,
      color: Color(0xFF059669),
      bg: Color(0x1F10B981),
    ),
  ];

  static MealSlotDefinition getById(String slotId) {
    return all.firstWhere(
      (s) => s.id == slotId,
      orElse: () => all[2], // dinner by default
    );
  }
}

class PlannedMealModel {
  final String id;
  final String date; // YYYY-MM-DD
  final String slot; // breakfast | lunch | dinner | snack
  final String title;
  final int prepTimeMinutes;
  final String? recipeId;
  final String? assignedCookId;
  final UserShort? cook;
  final int servings;
  final String? note;
  final bool isCompleted;
  final String? completedById;
  final UserShort? completedBy;
  final DateTime? createdAt;

  const PlannedMealModel({
    required this.id,
    required this.date,
    required this.slot,
    required this.title,
    this.prepTimeMinutes = 15,
    this.recipeId,
    this.assignedCookId,
    this.cook,
    this.servings = 4,
    this.note,
    this.isCompleted = false,
    this.completedById,
    this.completedBy,
    this.createdAt,
  });

  factory PlannedMealModel.fromJson(Map<String, dynamic> json) {
    UserShort? parsedCook;
    if (json['cook'] is Map<String, dynamic>) {
      parsedCook = UserShort.fromJson(json['cook'] as Map<String, dynamic>);
    }

    UserShort? parsedCompletedBy;
    if (json['completed_by'] is Map<String, dynamic>) {
      parsedCompletedBy = UserShort.fromJson(json['completed_by'] as Map<String, dynamic>);
    }

    DateTime? parsedCreatedAt;
    if (json['created_at'] != null) {
      parsedCreatedAt = DateTime.tryParse(json['created_at'].toString());
    }

    final rawDate = json['date']?.toString() ?? '';
    final dateStr = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;

    return PlannedMealModel(
      id: json['id']?.toString() ?? '',
      date: dateStr,
      slot: json['slot']?.toString() ?? 'dinner',
      title: json['title']?.toString() ?? '',
      prepTimeMinutes: (json['prep_time_minutes'] ?? json['prepTimeMinutes'] as num?)?.toInt() ?? 15,
      recipeId: json['recipe_id']?.toString() ?? json['recipeId']?.toString(),
      assignedCookId: json['assigned_cook_id']?.toString() ?? json['assignedCookId']?.toString(),
      cook: parsedCook,
      servings: (json['servings'] as num?)?.toInt() ?? 4,
      note: json['note']?.toString(),
      isCompleted: json['is_completed'] == true || json['isCompleted'] == true,
      completedById: json['completed_by_id']?.toString(),
      completedBy: parsedCompletedBy,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'slot': slot,
      'title': title,
      'prep_time_minutes': prepTimeMinutes,
      'recipe_id': recipeId,
      'assigned_cook_id': assignedCookId ?? cook?.id,
      'cook': cook?.toJson(),
      'servings': servings,
      'note': note,
      'is_completed': isCompleted,
      'completed_by_id': completedById,
      'completed_by': completedBy?.toJson(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  PlannedMealModel copyWith({
    String? id,
    String? date,
    String? slot,
    String? title,
    int? prepTimeMinutes,
    String? recipeId,
    String? assignedCookId,
    UserShort? cook,
    int? servings,
    String? note,
    bool? isCompleted,
    String? completedById,
    UserShort? completedBy,
    DateTime? createdAt,
  }) {
    return PlannedMealModel(
      id: id ?? this.id,
      date: date ?? this.date,
      slot: slot ?? this.slot,
      title: title ?? this.title,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      recipeId: recipeId ?? this.recipeId,
      assignedCookId: assignedCookId ?? this.assignedCookId,
      cook: cook ?? this.cook,
      servings: servings ?? this.servings,
      note: note ?? this.note,
      isCompleted: isCompleted ?? this.isCompleted,
      completedById: completedById ?? this.completedById,
      completedBy: completedBy ?? this.completedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
