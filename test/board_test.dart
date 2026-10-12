import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household/core/swr/swr.dart';
import 'package:household/features/chores/models/planned_chore_model.dart';
import 'package:household/features/chores/models/subtask_model.dart';
import 'package:household/features/chores/models/user_short_model.dart';
import 'package:household/features/chores/utils/checklist_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:household/features/chores/repositories/chores_repository.dart';
import 'package:household/features/chores/screens/board_screen.dart';
import 'package:household/features/chores/widgets/card_planned_chore.dart';
import 'package:household/features/chores/widgets/week_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SWR layer tests', () {
    test('SwrCache stores and retrieves data correctly', () async {
      final cache = SwrCache.instance;
      await cache.init();

      await cache.set('test-key', {'message': 'hello'});
      final retrieved = await cache.get('test-key');

      expect(retrieved, isNotNull);
      expect((retrieved as Map)['message'], 'hello');

      // Test sync retrieval
      final syncData = cache.getSync('test-key');
      expect(syncData, isNotNull);
      expect((syncData as Map)['message'], 'hello');

      // Test prefix clear
      await cache.set('chores:1', 'chore1');
      await cache.set('chores:2', 'chore2');
      await cache.clearPrefix('chores:*');

      expect(cache.getSync('chores:1'), isNull);
      expect(cache.getSync('chores:2'), isNull);
      expect(cache.getSync('test-key'), isNotNull);
    });

    test('SwrEventBus notifies listeners on mutate and wildcards', () {
      final bus = SwrEventBus.instance;
      dynamic receivedData;
      bool wasNotified = false;

      void listener(data) {
        wasNotified = true;
        receivedData = data;
      }

      bus.addListener('planned-chores:2026-09-27', listener);
      bus.emit('planned-chores:*', 'wildcard-data');

      expect(wasNotified, true);
      expect(receivedData, 'wildcard-data');

      bus.removeListener('planned-chores:2026-09-27', listener);
    });
  });

  group('ChecklistHelper tests', () {
    test('parses description and subtasks correctly', () {
      const raw = 'Купить продукты\n- [ ] Хлеб\n- [x] Молоко\n- [ ] Сыр';
      final parsed = ChecklistHelper.parseMessage(raw);

      expect(parsed.description, 'Купить продукты');
      expect(parsed.hasSubtasks, true);
      expect(parsed.subtasks.length, 3);
      expect(parsed.subtasks[0].text, 'Хлеб');
      expect(parsed.subtasks[0].done, false);
      expect(parsed.subtasks[1].text, 'Молоко');
      expect(parsed.subtasks[1].done, true);
      expect(parsed.subtasks[2].text, 'Сыр');
      expect(parsed.subtasks[2].done, false);
    });

    test('serializes description and subtasks back to markdown', () {
      final subtasks = [
        const Subtask(id: '1', text: 'Хлеб', done: true),
        const Subtask(id: '2', text: 'Молоко', done: false),
      ];
      final serialized = ChecklistHelper.serializeMessage('Купить', subtasks);

      expect(serialized, 'Купить\n- [x] Хлеб\n- [ ] Молоко');
    });
  });

  group('WeekCalendar widget test', () {
    testWidgets('renders days and handles date selection', (WidgetTester tester) async {
      DateTime? changedDate;
      final today = DateTime.now();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeekCalendar(
              selectedDate: today,
              onDateChanged: (d) => changedDate = d,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WeekCalendar), findsOneWidget);
      final mondayFinder = find.text('Пн').evaluate().isNotEmpty ? find.text('Пн') : find.text('Mon');
      expect(mondayFinder, findsWidgets);

      // Verify tapping a day invokes callback
      final dayFinder = mondayFinder.first;
      await tester.tap(dayFinder);
      await tester.pump();

      expect(changedDate, isNotNull);
    });
  });

  group('CardPlannedChore widget test', () {
    testWidgets('renders chore title and handles toggle with smooth animation', (WidgetTester tester) async {
      PlannedChoreModel? toggledItem;
      const chore = PlannedChoreModel(
        id: 'test-1',
        name: 'Помыть полы',
        dueDate: '2026-09-27',
        isQuick: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardPlannedChore(
              item: chore,
              onToggle: (item) => toggledItem = item,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Помыть полы'), findsOneWidget);
      expect(find.byType(ClipOval), findsOneWidget);

      final checkFinder = find.byType(GestureDetector).last;
      await tester.tap(checkFinder);
      await tester.pump();

      expect(toggledItem?.id, 'test-1');

      // Step through completion animation ticks
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('renders completed chore with lineThrough text and checkmark', (WidgetTester tester) async {
      const completedChore = PlannedChoreModel(
        id: 'test-2',
        name: 'Купить хлеб',
        dueDate: '2026-09-27',
        isQuick: true,
        completedBy: UserShort(id: 'u1', name: 'Анна'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardPlannedChore(
              item: completedChore,
              onToggle: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Купить хлеб'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.text('Анна'), findsOneWidget);
    });
  });

  group('BoardScreen progressive collapsing on scroll tests', () {
    testWidgets('Header and FAB progressively collapse when scrolled', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            choresRepositoryProvider.overrideWithValue(_MockChoresRepository()),
          ],
          child: const MaterialApp(
            home: BoardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially at top (offset 0): Title 'Доска' and FAB 'Запланировать' are rendered
      expect(find.text('Доска'), findsOneWidget);
      expect(find.text('Запланировать'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Scroll down by 80px
      await tester.drag(find.byType(ListView), const Offset(0, -80));
      await tester.pump();

      // Plus icon remains fully accessible in the compact circular button
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // WeekCalendar remains visible
      expect(find.byType(WeekCalendar), findsOneWidget);

      // Scroll back up to top
      await tester.drag(find.byType(ListView), const Offset(0, 100));
      await tester.pump();

      expect(find.text('Доска'), findsOneWidget);
      expect(find.text('Запланировать'), findsOneWidget);
    });
  });
}

class _MockChoresRepository extends ChoresRepository {
  _MockChoresRepository() : super(dio: Dio());

  @override
  Future<List<PlannedChoreModel>> getBoardChores(String dateKey, {CancelToken? cancelToken}) async => [];

  @override
  Future<List<PlannedChoreModel>> getPlannedChores(String dueDate, {CancelToken? cancelToken}) async => [];

  @override
  Future<List<PlannedChoreModel>> getQuickPlannedChores(String dueDate, {CancelToken? cancelToken}) async => [];
}
