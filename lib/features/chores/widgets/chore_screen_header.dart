import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Shared header for chore creation/detail screens.
class ChoreScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const ChoreScreenHeader({super.key, required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Text(
              title,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
