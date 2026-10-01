import 'chore_item_model.dart';
import 'user_short_model.dart';

class PlannedChoreModel {
  final String id;
  final String? scheduleId;
  final ChoreItem? chore;
  final String? name;
  final String? description;
  final String icon;
  final String iconColor;
  final String iconBg;
  final int valuation;
  final UserShort? completedBy;
  final UserShort? assignedTo;
  final String dueDate;
  final String message;
  final bool isQuick;

  const PlannedChoreModel({
    required this.id,
    this.scheduleId,
    this.chore,
    this.name,
    this.description,
    this.icon = 'material-symbols:cleaning-services-rounded',
    this.iconColor = '#ffffff',
    this.iconBg = 'linear-gradient(135deg, #8a7f6e 0%, #6b5f50 100%)',
    this.valuation = 10,
    this.completedBy,
    this.assignedTo,
    required this.dueDate,
    this.message = '',
    this.isQuick = false,
  });

  bool get isDone => completedBy != null;

  String get displayTitle => isQuick ? (name ?? '') : (chore?.name ?? '');
  String get displayIcon => isQuick ? icon : (chore?.icon ?? icon);
  String get displayIconColor => isQuick ? iconColor : (chore?.iconColor ?? iconColor);
  String get displayIconBg => isQuick ? iconBg : (chore?.iconBg ?? iconBg);
  int get displayValuation => isQuick ? valuation : (chore?.valuation ?? valuation);

  factory PlannedChoreModel.fromPlannedJson(Map<String, dynamic> json) {
    return PlannedChoreModel(
      id: json['id']?.toString() ?? '',
      scheduleId: json['schedule_id']?.toString(),
      chore: json['chore'] != null ? ChoreItem.fromJson(json['chore'] as Map<String, dynamic>) : null,
      completedBy: json['completed_by'] != null
          ? UserShort.fromJson(json['completed_by'] as Map<String, dynamic>)
          : null,
      assignedTo: json['assigned_to'] != null
          ? UserShort.fromJson(json['assigned_to'] as Map<String, dynamic>)
          : null,
      dueDate: json['due_date']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isQuick: false,
    );
  }

  factory PlannedChoreModel.fromQuickJson(Map<String, dynamic> json) {
    return PlannedChoreModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      icon: json['icon']?.toString() ?? 'material-symbols:bolt-rounded',
      iconColor: json['icon_color']?.toString() ?? '#ffffff',
      iconBg: json['icon_bg']?.toString() ?? 'linear-gradient(135deg, #F59E0B 0%, #F97316 100%)',
      valuation: (json['valuation'] as num?)?.toInt() ?? 10,
      completedBy: json['completed_by'] != null
          ? UserShort.fromJson(json['completed_by'] as Map<String, dynamic>)
          : null,
      assignedTo: json['assigned_to'] != null
          ? UserShort.fromJson(json['assigned_to'] as Map<String, dynamic>)
          : null,
      dueDate: json['due_date']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isQuick: true,
    );
  }

  factory PlannedChoreModel.fromJson(Map<String, dynamic> json) {
    if (json['is_quick'] == true) {
      return PlannedChoreModel.fromQuickJson(json);
    }
    return PlannedChoreModel.fromPlannedJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schedule_id': scheduleId,
      'chore': chore?.toJson(),
      'name': name,
      'description': description,
      'icon': icon,
      'icon_color': iconColor,
      'icon_bg': iconBg,
      'valuation': valuation,
      'completed_by': completedBy?.toJson(),
      'assigned_to': assignedTo?.toJson(),
      'due_date': dueDate,
      'message': message,
      'is_quick': isQuick,
    };
  }

  PlannedChoreModel copyWith({
    UserShort? completedBy,
    bool clearCompletedBy = false,
    UserShort? assignedTo,
    String? message,
    String? dueDate,
  }) {
    return PlannedChoreModel(
      id: id,
      scheduleId: scheduleId,
      chore: chore,
      name: name,
      description: description,
      icon: icon,
      iconColor: iconColor,
      iconBg: iconBg,
      valuation: valuation,
      completedBy: clearCompletedBy ? null : (completedBy ?? this.completedBy),
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      message: message ?? this.message,
      isQuick: isQuick,
    );
  }
}
