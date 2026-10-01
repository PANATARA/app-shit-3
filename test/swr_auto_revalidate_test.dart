import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household/core/swr/swr.dart';
import 'package:household/features/chores/providers/board_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestSwrWidget extends StatefulWidget {
  final int tabIndex;
  final VoidCallback onRevalidateCall;

  const _TestSwrWidget({
    required this.tabIndex,
    required this.onRevalidateCall,
  });

  @override
  State<_TestSwrWidget> createState() => _TestSwrWidgetState();
}

class _TestSwrWidgetState extends State<_TestSwrWidget>
    with WidgetsBindingObserver, RouteAware, SwrScreenMixin {
  @override
  int? get swrTabIndex => widget.tabIndex;

  @override
  void onRevalidate() {
    widget.onRevalidateCall();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SwrScreenMixin automatic revalidation tests', () {
    testWidgets('triggers onRevalidate on initial mount', (WidgetTester tester) async {
      int revalidateCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestSwrWidget(
              tabIndex: 1,
              onRevalidateCall: () => revalidateCount++,
            ),
          ),
        ),
      );

      // Post-frame callback runs after first frame
      await tester.pump();
      expect(revalidateCount, 1);
    });

    testWidgets('triggers onRevalidate on tab activation event', (WidgetTester tester) async {
      int revalidateCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestSwrWidget(
              tabIndex: 1,
              onRevalidateCall: () => revalidateCount++,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(revalidateCount, 1);

      // Simulate switching to tab 1 in AppScaffold
      SwrEventBus.instance.emit('app:tab:1', null);
      await tester.pump();

      expect(revalidateCount, 2);

      // Other tab events should NOT trigger tab 1
      SwrEventBus.instance.emit('app:tab:2', null);
      await tester.pump();
      expect(revalidateCount, 2);
    });

    testWidgets('triggers onRevalidate when app resumes from background', (WidgetTester tester) async {
      int revalidateCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestSwrWidget(
              tabIndex: 1,
              onRevalidateCall: () => revalidateCount++,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(revalidateCount, 1);

      // Simulate app resuming from background
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(revalidateCount, 2);
    });
  });

  group('Board date change automatic revalidation', () {
    test('SelectedDateNotifier updates date correctly', () {
      final container = ProviderContainer();
      final initialDate = container.read(selectedDateProvider);
      final initialKey = container.read(selectedDateKeyProvider);

      expect(initialKey, isNotEmpty);

      final tomorrow = initialDate.add(const Duration(days: 1));
      container.read(selectedDateProvider.notifier).setDate(tomorrow);

      final newKey = container.read(selectedDateKeyProvider);
      expect(newKey, isNot(initialKey));
    });
  });
}
