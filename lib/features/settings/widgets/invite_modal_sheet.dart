import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../repositories/settings_repository.dart';

class InviteModalSheet extends ConsumerStatefulWidget {
  const InviteModalSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const InviteModalSheet(),
    );
  }

  @override
  ConsumerState<InviteModalSheet> createState() => _InviteModalSheetState();
}

class _InviteModalSheetState extends ConsumerState<InviteModalSheet> {
  String _code = '';
  int _expiresIn = 0;
  bool _loading = true;
  bool _error = false;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _loadCode();
  }

  Future<void> _loadCode() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final res = await ref.read(settingsRepositoryProvider).generateFamilyInvite();
      if (!mounted) return;
      setState(() {
        _code = res['invite_token']?.toString() ?? '';
        _expiresIn = (res['ttl'] as num?)?.toInt() ?? 3600;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  String _formatCode(String raw) {
    if (raw.length == 6) {
      return '${raw.substring(0, 3)}-${raw.substring(3)}';
    }
    return raw;
  }

  String _formatExpiry(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '$h ч $m мин';
    return '$m мин';
  }

  Future<void> _copyCode() async {
    if (_code.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _formatCode(_code)));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Пригласить участника',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close_rounded, color: AppColors.textMuted),
                visualDensity: VisualDensity.compact,
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_loading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                ),
              ),
            )
          else if (_error)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  Text(
                    'Не удалось получить код',
                    style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            )
          else ...[
            // Illustration
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.person_rounded, size: 36, color: AppColors.primary),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.arrow_forward_rounded, size: 24, color: AppColors.textMuted),
                  ),
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.groups_rounded, size: 36, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Hint
            Text(
              'Отправьте этот код человеку, которого хотите пригласить в семью. Код действует ограниченное время.',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Code button
            GestureDetector(
              onTap: _copyCode,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _copied ? AppColors.success : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _formatCode(_code),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _copied ? '✓ Код скопирован' : 'Нажмите, чтобы скопировать',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _copied ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Expiry row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  'Код истекает через ${_formatExpiry(_expiresIn)}',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
