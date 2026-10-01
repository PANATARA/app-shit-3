import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household/core/theme/app_theme.dart';
import 'package:household/features/chores/widgets/week_calendar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Apple Design System & HIG Tests', () {
    test('AppTheme includes CupertinoPageTransitionsBuilder and optical tracking', () {
      final theme = AppTheme.lightTheme;

      // Cupertino page transitions across platforms
      final builders = theme.pageTransitionsTheme.builders;
      expect(builders[TargetPlatform.android], isA<CupertinoPageTransitionsBuilder>());
      expect(builders[TargetPlatform.iOS], isA<CupertinoPageTransitionsBuilder>());

      // Typography optical tracking
      expect(theme.textTheme.titleLarge?.letterSpacing, lessThan(0.0));
      expect(theme.textTheme.labelSmall?.letterSpacing, greaterThan(0.5));

      // Apple Modal Sheet Theme
      expect(theme.bottomSheetTheme.showDragHandle, isTrue);
      expect(theme.bottomSheetTheme.dragHandleSize, const Size(36, 5));
    });

    testWidgets('WeekCalendar DayButton responds with AnimatedScale', (tester) async {
      DateTime selected = DateTime(2026, 10, 1);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WeekCalendar(
              selectedDate: selected,
              onDateChanged: (d) => selected = d,
            ),
          ),
        ),
      );

      // Verify PageView uses BouncingScrollPhysics
      final pageViewFinder = find.byType(PageView);
      expect(pageViewFinder, findsOneWidget);
      final pageView = tester.widget<PageView>(pageViewFinder);
      expect(pageView.physics, isA<BouncingScrollPhysics>());

      // Find first day button and press down
      final inkWellFinder = find.byType(InkWell).first;
      final gesture = await tester.startGesture(tester.getCenter(inkWellFinder));
      await tester.pump(const Duration(milliseconds: 50));

      // Verify scale down feedback exists
      final animatedScaleFinder = find.ancestor(
        of: inkWellFinder,
        matching: find.byType(AnimatedScale),
      );
      expect(animatedScaleFinder, findsWidgets);

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });
}
