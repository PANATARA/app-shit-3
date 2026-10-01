import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household/features/chores/models/repeat_config_model.dart';
import 'package:household/features/chores/widgets/repeat_selector_widget.dart';

void main() {
  group('RepeatConfig Model Unit Tests', () {
    test('default configuration has frequencyType none', () {
      final config = RepeatConfig(startsAt: '2026-10-01');
      expect(config.frequencyType, 'none');
      expect(config.interval, 1);
      expect(config.daysOfWeek, isEmpty);
      expect(config.dayOfMonth, isNull);
      expect(config.startsAt, '2026-10-01');
      expect(config.endsAt, isNull);
    });

    test('daysOfWeekToBitmask correctly maps weekdays to backend bitmask', () {
      // 0 = Sunday (bit 6 = 64)
      // 1 = Monday (bit 0 = 1)
      // 2 = Tuesday (bit 1 = 2)
      // 3 = Wednesday (bit 2 = 4)
      // 4 = Thursday (bit 3 = 8)
      // 5 = Friday (bit 4 = 16)
      // 6 = Saturday (bit 5 = 32)
      expect(RepeatConfig.daysOfWeekToBitmask([]), 0);
      expect(RepeatConfig.daysOfWeekToBitmask([1]), 1); // Monday
      expect(RepeatConfig.daysOfWeekToBitmask([2]), 2); // Tuesday
      expect(RepeatConfig.daysOfWeekToBitmask([0]), 64); // Sunday
      expect(RepeatConfig.daysOfWeekToBitmask([6]), 32); // Saturday

      // Workdays: Mon-Fri = 1 + 2 + 4 + 8 + 16 = 31
      expect(RepeatConfig.daysOfWeekToBitmask([1, 2, 3, 4, 5]), 31);

      // Weekends: Sat, Sun = 32 + 64 = 96
      expect(RepeatConfig.daysOfWeekToBitmask([6, 0]), 96);

      // All days: 1 + 2 + 4 + 8 + 16 + 32 + 64 = 127
      expect(RepeatConfig.daysOfWeekToBitmask([1, 2, 3, 4, 5, 6, 0]), 127);
    });

    test('getPlural handles Russian plural forms correctly', () {
      expect(RepeatConfig.getPlural(1, 'день', 'дня', 'дней'), 'день');
      expect(RepeatConfig.getPlural(2, 'день', 'дня', 'дней'), 'дня');
      expect(RepeatConfig.getPlural(4, 'день', 'дня', 'дней'), 'дня');
      expect(RepeatConfig.getPlural(5, 'день', 'дня', 'дней'), 'дней');
      expect(RepeatConfig.getPlural(11, 'день', 'дня', 'дней'), 'дней');
      expect(RepeatConfig.getPlural(21, 'день', 'дня', 'дней'), 'день');
      expect(RepeatConfig.getPlural(22, 'день', 'дня', 'дней'), 'дня');
      expect(RepeatConfig.getPlural(25, 'день', 'дня', 'дней'), 'дней');
    });

    test('getIntervalText formats intervals correctly', () {
      expect(RepeatConfig.getIntervalText(1, 'daily'), 'Каждый день');
      expect(RepeatConfig.getIntervalText(2, 'daily'), 'Каждые 2 дня');
      expect(RepeatConfig.getIntervalText(5, 'daily'), 'Каждые 5 дней');

      expect(RepeatConfig.getIntervalText(1, 'weekly'), 'Каждую неделю');
      expect(RepeatConfig.getIntervalText(2, 'weekly'), 'Каждые 2 недели');
      expect(RepeatConfig.getIntervalText(5, 'weekly'), 'Каждые 5 недель');

      expect(RepeatConfig.getIntervalText(1, 'monthly'), 'Каждый месяц');
      expect(RepeatConfig.getIntervalText(2, 'monthly'), 'Каждые 2 месяца');
      expect(RepeatConfig.getIntervalText(5, 'monthly'), 'Каждые 5 месяцев');
    });

    test('copyWith properly copies and modifies fields', () {
      final config = RepeatConfig(startsAt: '2026-10-01');
      final updated = config.copyWith(
        frequencyType: 'weekly',
        interval: 2,
        daysOfWeek: [1, 3, 5],
        dayOfMonth: 15,
      );
      expect(updated.frequencyType, 'weekly');
      expect(updated.interval, 2);
      expect(updated.daysOfWeek, [1, 3, 5]);
      expect(updated.dayOfMonth, 15);
      expect(updated.startsAt, '2026-10-01');
    });
  });

  group('RepeatSelectorWidget Widget Tests', () {
    testWidgets('renders all 4 frequency options in a 2x2 grid', (tester) async {
      RepeatConfig current = const RepeatConfig(
        frequencyType: 'none',
        interval: 1,
        startsAt: '2026-10-01',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepeatSelectorWidget(
              value: current,
              onChanged: (val) => current = val,
            ),
          ),
        ),
      );

      expect(find.text('Не повторять'), findsOneWidget);
      expect(find.text('Ежедневно'), findsOneWidget);
      expect(find.text('Еженедельно'), findsOneWidget);
      expect(find.text('Ежемесячно'), findsOneWidget);

      // Initially 'none' so no interval stepper is shown
      expect(find.text('ПЕРИОДИЧНОСТЬ'), findsNothing);
    });

    testWidgets('tapping daily reveals interval stepper and allows adjustment', (tester) async {
      RepeatConfig current = const RepeatConfig(
        frequencyType: 'none',
        interval: 1,
        startsAt: '2026-10-01',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (ctx, setState) => RepeatSelectorWidget(
                value: current,
                onChanged: (val) {
                  setState(() => current = val);
                },
              ),
            ),
          ),
        ),
      );

      // Tap 'Ежедневно'
      await tester.tap(find.text('Ежедневно'));
      await tester.pumpAndSettle();

      expect(current.frequencyType, 'daily');
      expect(find.text('ПЕРИОДИЧНОСТЬ'), findsOneWidget);
      expect(find.text('Каждый день'), findsOneWidget);

      // Tap + button on interval stepper
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(current.interval, 2);
      expect(find.text('Каждые 2 дня'), findsOneWidget);

      // Tap - button on interval stepper
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pumpAndSettle();

      expect(current.interval, 1);
      expect(find.text('Каждый день'), findsOneWidget);
    });

    testWidgets('weekly frequency shows weekday circles and shortcuts', (tester) async {
      RepeatConfig current = const RepeatConfig(
        frequencyType: 'weekly',
        interval: 1,
        daysOfWeek: [1, 2], // Mon, Tue
        startsAt: '2026-10-01',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (ctx, setState) => RepeatSelectorWidget(
                value: current,
                onChanged: (val) {
                  setState(() => current = val);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('ДНИ НЕДЕЛИ'), findsOneWidget);
      expect(find.text('Пн'), findsOneWidget);
      expect(find.text('Вт'), findsOneWidget);
      expect(find.text('Ср'), findsOneWidget);
      expect(find.text('Чт'), findsOneWidget);
      expect(find.text('Пт'), findsOneWidget);
      expect(find.text('Сб'), findsOneWidget);
      expect(find.text('Вс'), findsOneWidget);

      // Shortcuts
      expect(find.text('Будни'), findsOneWidget);
      expect(find.text('Выходные'), findsOneWidget);
      expect(find.text('Все дни'), findsOneWidget);
      expect(find.text('Сбросить'), findsOneWidget);

      // Tap 'Будни'
      await tester.tap(find.text('Будни'));
      await tester.pumpAndSettle();
      expect(current.daysOfWeek, [1, 2, 3, 4, 5]);

      // Tap 'Выходные'
      await tester.tap(find.text('Выходные'));
      await tester.pumpAndSettle();
      expect(current.daysOfWeek, [6, 0]);

      // Tap 'Все дни'
      await tester.tap(find.text('Все дни'));
      await tester.pumpAndSettle();
      expect(current.daysOfWeek, [1, 2, 3, 4, 5, 6, 0]);

      // Tap 'Сбросить'
      await tester.tap(find.text('Сбросить'));
      await tester.pumpAndSettle();
      expect(current.daysOfWeek, isEmpty);

      // Toggle 'Пн'
      await tester.tap(find.text('Пн'));
      await tester.pumpAndSettle();
      expect(current.daysOfWeek, [1]);
    });

    testWidgets('monthly frequency shows day stepper and preset chips', (tester) async {
      RepeatConfig current = const RepeatConfig(
        frequencyType: 'monthly',
        interval: 1,
        dayOfMonth: 10,
        startsAt: '2026-10-01',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (ctx, setState) => RepeatSelectorWidget(
                value: current,
                onChanged: (val) {
                  setState(() => current = val);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('ЧИСЛО МЕСЯЦА'), findsOneWidget);
      expect(find.text('10-е число месяца'), findsOneWidget);
      expect(find.text('1-е число'), findsOneWidget);
      expect(find.text('В середине (15-е)'), findsOneWidget);
      expect(find.text('Конец месяца'), findsOneWidget);

      // Tap '1-е число'
      await tester.tap(find.text('1-е число'));
      await tester.pumpAndSettle();
      expect(current.dayOfMonth, 1);
      expect(find.text('1-е число месяца'), findsOneWidget);

      // Tap 'В середине (15-е)'
      await tester.tap(find.text('В середине (15-е)'));
      await tester.pumpAndSettle();
      expect(current.dayOfMonth, 15);
      expect(find.text('15-е число месяца'), findsOneWidget);

      // Tap 'Конец месяца'
      await tester.tap(find.text('Конец месяца'));
      await tester.pumpAndSettle();
      expect(current.dayOfMonth, 31);
      expect(find.text('31-е число месяца'), findsOneWidget);
    });
  });
}
