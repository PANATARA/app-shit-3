import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household/core/widgets/app_modal_sheet.dart';

void main() {
  group('AppModalSheetWrapper & showAppModalBottomSheet Tests', () {
    testWidgets('Renders child content properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppModalSheetWrapper(
              child: SizedBox(
                key: const ValueKey('sheet-content'),
                height: 300,
                child: const Text('Modal Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('sheet-content')), findsOneWidget);
      expect(find.text('Modal Content'), findsOneWidget);
    });

    testWidgets('showAppModalBottomSheet opens and displays content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  showAppModalBottomSheet(
                    context: ctx,
                    builder: (modalCtx) => const SizedBox(
                      height: 300,
                      child: Text('Inside App Modal'),
                    ),
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Inside App Modal'), findsOneWidget);
    });

    testWidgets('Dismisses sheet when inner ListView is overscrolled at top', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  showAppModalBottomSheet(
                    context: ctx,
                    builder: (modalCtx) => SizedBox(
                      height: 400,
                      child: ListView.builder(
                        itemCount: 20,
                        itemBuilder: (c, i) => ListTile(title: Text('Item $i')),
                      ),
                    ),
                  );
                },
                child: const Text('Open Scroll Modal'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Scroll Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsOneWidget);

      // Drag down on Item 0 past threshold
      await tester.drag(find.text('Item 0'), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Modal is dismissed
      expect(find.text('Item 0'), findsNothing);
    });

    testWidgets('ModalRoute controller is accessible and drivable', (tester) async {
      AnimationController? routeCtrl;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  showAppModalBottomSheet(
                    context: ctx,
                    builder: (modalCtx) {
                      // ignore: invalid_use_of_protected_member
                      routeCtrl = ModalRoute.of(modalCtx)?.controller;
                      return const SizedBox(height: 300, child: Text('Controller Test'));
                    },
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(routeCtrl, isNotNull);
      expect(routeCtrl!.value, 1.0);

      // Drive controller down
      routeCtrl!.value = 0.5;
      await tester.pump();
      expect(routeCtrl!.value, 0.5);

      // Fling and close
      routeCtrl!.fling(velocity: -1.0);
      Navigator.of(tester.element(find.text('Controller Test'))).pop();
      await tester.pumpAndSettle();

      expect(find.text('Controller Test'), findsNothing);
    });
  });
}
