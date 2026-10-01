class RepeatConfig {
  final String frequencyType; // 'none' | 'daily' | 'weekly' | 'monthly'
  final int interval;
  final List<int> daysOfWeek; // 0=Sun, 1=Mon, ..., 6=Sat (matching Svelte)
  final int? dayOfMonth; // 1..31
  final String startsAt; // YYYY-MM-DD
  final String? endsAt; // YYYY-MM-DD

  const RepeatConfig({
    this.frequencyType = 'none',
    this.interval = 1,
    this.daysOfWeek = const [],
    this.dayOfMonth,
    required this.startsAt,
    this.endsAt,
  });

  RepeatConfig copyWith({
    String? frequencyType,
    int? interval,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    String? startsAt,
    String? endsAt,
    bool clearEndsAt = false,
    bool clearDayOfMonth = false,
  }) {
    return RepeatConfig(
      frequencyType: frequencyType ?? this.frequencyType,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      dayOfMonth: clearDayOfMonth ? null : (dayOfMonth ?? this.dayOfMonth),
      startsAt: startsAt ?? this.startsAt,
      endsAt: clearEndsAt ? null : (endsAt ?? this.endsAt),
    );
  }

  /// Converts UI day indices (0=Sun, 1=Mon..6=Sat) into backend bitmask (1=Mon..64=Sun)
  static int daysOfWeekToBitmask(List<int> days) {
    int mask = 0;
    for (final d in days) {
      if (d == 0) {
        mask |= 1 << 6; // Sunday = 64
      } else if (d >= 1 && d <= 6) {
        mask |= 1 << (d - 1); // 1=Mo(1), 2=Tu(2), 3=We(4), 4=Th(8), 5=Fr(16), 6=Sa(32)
      }
    }
    return mask;
  }

  static String getPlural(int n, String one, String two, String five) {
    final absN = n.abs() % 100;
    final n1 = absN % 10;
    if (absN > 10 && absN < 20) return five;
    if (n1 > 1 && n1 < 5) return two;
    if (n1 == 1) return one;
    return five;
  }

  static String getIntervalText(int interval, String frequencyType) {
    if (interval == 1) {
      switch (frequencyType) {
        case 'daily':
          return 'Каждый день';
        case 'weekly':
          return 'Каждую неделю';
        case 'monthly':
          return 'Каждый месяц';
        default:
          return 'Каждый раз';
      }
    }
    switch (frequencyType) {
      case 'daily':
        return 'Каждые $interval ${getPlural(interval, 'день', 'дня', 'дней')}';
      case 'weekly':
        return 'Каждые $interval ${getPlural(interval, 'неделю', 'недели', 'недель')}';
      case 'monthly':
        return 'Каждые $interval ${getPlural(interval, 'месяц', 'месяца', 'месяцев')}';
      default:
        return 'Интервал: $interval';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatConfig &&
          runtimeType == other.runtimeType &&
          frequencyType == other.frequencyType &&
          interval == other.interval &&
          _listEquals(daysOfWeek, other.daysOfWeek) &&
          dayOfMonth == other.dayOfMonth &&
          startsAt == other.startsAt &&
          endsAt == other.endsAt;

  @override
  int get hashCode => Object.hash(
        frequencyType,
        interval,
        Object.hashAll(daysOfWeek),
        dayOfMonth,
        startsAt,
        endsAt,
      );

  static bool _listEquals(List<int> a, List<int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
