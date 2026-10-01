import 'package:intl/intl.dart';

enum EventDateBadgeType { today, soon, upcoming, past }

class EventDateMeta {
  final String formattedDate;
  final String badgeText;
  final EventDateBadgeType badgeType;
  final int daysDiff;

  const EventDateMeta({
    required this.formattedDate,
    required this.badgeText,
    required this.badgeType,
    required this.daysDiff,
  });
}

class FamilyEventModel {
  final String id;
  final String name;
  final String? description;
  final String icon;
  final String iconColor;
  final String iconBg;
  final String date;

  const FamilyEventModel({
    required this.id,
    required this.name,
    this.description,
    this.icon = 'material-symbols:celebration-rounded',
    this.iconColor = '#ffffff',
    this.iconBg = 'linear-gradient(135deg, #8B5CF6 0%, #6366F1 100%)',
    required this.date,
  });

  factory FamilyEventModel.fromJson(Map<String, dynamic> json) {
    return FamilyEventModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      icon: json['icon']?.toString() ?? 'material-symbols:celebration-rounded',
      iconColor: json['icon_color']?.toString() ?? '#ffffff',
      iconBg: json['icon_bg']?.toString() ?? 'linear-gradient(135deg, #8B5CF6 0%, #6366F1 100%)',
      date: json['date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'icon_color': iconColor,
        'icon_bg': iconBg,
        'date': date,
      };

  DateTime? get dateTime {
    try {
      return DateTime.parse(date);
    } catch (_) {
      return null;
    }
  }

  EventDateMeta getDateMeta() {
    final parsed = dateTime;
    if (parsed == null) {
      return const EventDateMeta(
        formattedDate: '—',
        badgeText: '—',
        badgeType: EventDateBadgeType.past,
        daysDiff: -999,
      );
    }

    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final eventMidnight = DateTime(parsed.year, parsed.month, parsed.day);
    final diff = eventMidnight.difference(todayMidnight).inDays;

    final isCurrentYear = parsed.year == now.year;
    final formattedDate = isCurrentYear
        ? DateFormat('d MMM', 'ru').format(parsed).replaceAll('.', '')
        : DateFormat('d MMM y', 'ru').format(parsed).replaceAll('.', '');

    if (diff == 0) {
      return EventDateMeta(
        formattedDate: formattedDate,
        badgeText: 'Сегодня',
        badgeType: EventDateBadgeType.today,
        daysDiff: diff,
      );
    }
    if (diff == 1) {
      return EventDateMeta(
        formattedDate: formattedDate,
        badgeText: 'Завтра',
        badgeType: EventDateBadgeType.soon,
        daysDiff: diff,
      );
    }
    if (diff == 2) {
      return EventDateMeta(
        formattedDate: formattedDate,
        badgeText: 'Послезавтра',
        badgeType: EventDateBadgeType.soon,
        daysDiff: diff,
      );
    }
    if (diff > 2) {
      return EventDateMeta(
        formattedDate: formattedDate,
        badgeText: 'через $diff дн.',
        badgeType: EventDateBadgeType.upcoming,
        daysDiff: diff,
      );
    }
    if (diff == -1) {
      return EventDateMeta(
        formattedDate: formattedDate,
        badgeText: 'Вчера',
        badgeType: EventDateBadgeType.past,
        daysDiff: diff,
      );
    }

    final absDiff = diff.abs();
    return EventDateMeta(
      formattedDate: formattedDate,
      badgeText: '$absDiff дн. назад',
      badgeType: EventDateBadgeType.past,
      daysDiff: diff,
    );
  }
}
