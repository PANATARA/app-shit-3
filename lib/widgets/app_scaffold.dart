import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/swr/swr.dart';
import '../core/theme/app_colors.dart';

class AppScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
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
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.navBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
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
    );
  }
}

class _NavBarItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.navActiveBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.navActive : AppColors.navInactive,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.navActive : AppColors.navInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
