import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/swr/swr.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/theme_provider.dart';

class AppScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  int _lastIndex = -1;

  @override
  void initState() {
    super.initState();
    _lastIndex = widget.navigationShell.currentIndex;
  }

  @override
  void didUpdateWidget(covariant AppScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigationShell.currentIndex != _lastIndex) {
      _lastIndex = widget.navigationShell.currentIndex;
      _notifyTabActivated(_lastIndex);
    }
  }

  void _notifyTabActivated(int index) {
    SwrEventBus.instance.emit('app:tab:$index', null);
  }

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    final isCurrent = index == widget.navigationShell.currentIndex;
    widget.navigationShell.goBranch(
      index,
      initialLocation: isCurrent,
    );
    // Always notify tab activation, even when re-tapping current tab
    _notifyTabActivated(index);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appThemeProvider);

    return Scaffold(
      extendBody: true,
      body: RepaintBoundary(
        child: widget.navigationShell,
      ),
      bottomNavigationBar: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.navBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border(
              top: BorderSide(
                color: AppColors.borderSubtle.withValues(alpha: 0.7),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavBarItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'Главная',
                      isActive: widget.navigationShell.currentIndex == 0,
                      onTap: () => _onItemTapped(0),
                    ),
                    _NavBarItem(
                      icon: Icons.checklist_rounded,
                      label: 'Доска',
                      isActive: widget.navigationShell.currentIndex == 1,
                      onTap: () => _onItemTapped(1),
                    ),
                    _NavBarItem(
                      icon: Icons.restaurant_rounded,
                      label: 'Меню',
                      isActive: widget.navigationShell.currentIndex == 2,
                      onTap: () => _onItemTapped(2),
                    ),
                    _NavBarItem(
                      icon: Icons.settings_rounded,
                      label: 'Профиль',
                      isActive: widget.navigationShell.currentIndex == 3,
                      onTap: () => _onItemTapped(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}

class _NavBarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: widget.isActive ? AppColors.navActiveBg : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 24,
                color: widget.isActive ? AppColors.navActive : AppColors.navInactive,
              ),
              const SizedBox(height: 3),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: -0.1,
                  color: widget.isActive ? AppColors.navActive : AppColors.navInactive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
