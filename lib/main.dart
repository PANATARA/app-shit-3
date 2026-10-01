import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/routing/app_router.dart';
import 'core/swr/swr.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);
  await Swr.init();
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('app_theme') ?? 'warm';
  AppColors.applyTheme(savedTheme);

  runApp(
    const ProviderScope(
      child: HouseholdApp(),
    ),
  );
}

class HouseholdApp extends ConsumerWidget {
  const HouseholdApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(appThemeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'HOUSEHOLD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(currentTheme),
      routerConfig: router,
    );
  }
}
