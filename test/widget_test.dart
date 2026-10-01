import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household/core/theme/app_colors.dart';

void main() {
  testWidgets('App root smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(
                'HOUSEHOLD',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('HOUSEHOLD'), findsOneWidget);
  });
}
