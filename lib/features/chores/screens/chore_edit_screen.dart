import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/swr/swr.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/avatar_builder_widget.dart';
import '../models/chore_item_model.dart';
import '../repositories/chores_repository.dart';
import '../widgets/chore_icon_widget.dart';

class ChoreEditScreen extends ConsumerStatefulWidget {
  final ChoreItem chore;

  const ChoreEditScreen({super.key, required this.chore});

  @override
  ConsumerState<ChoreEditScreen> createState() => _ChoreEditScreenState();
}

class _ChoreEditScreenState extends ConsumerState<ChoreEditScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;

  late String _icon;
  late String _iconColor;
  late String _iconBg;

  bool _saving = false;
  bool _deleting = false;

  bool get _isDefaultChore => widget.chore.defaultChoreId != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.chore.name);
    _descCtrl = TextEditingController(text: widget.chore.description ?? '');
    _icon = widget.chore.icon;
    _iconColor = widget.chore.iconColor;
    _iconBg = widget.chore.iconBg;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_saving || _deleting) return;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);

    try {
      await ref.read(choresRepositoryProvider).updateFamilyChore(
        widget.chore.id,
        name: _isDefaultChore ? null : name,
        description: _descCtrl.text.trim(),
        icon: _isDefaultChore ? null : _icon,
        iconColor: _isDefaultChore ? null : _iconColor,
        iconBg: _isDefaultChore ? null : _iconBg,
      );

      // Revalidate family chores
      await Swr.mutate('family-chores');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Изменения сохранены'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при сохранении: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _handleDelete() async {
    if (_saving || _deleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Удалить обязанность?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Вы уверены, что хотите удалить обязанность "${widget.chore.name}"? Это действие необратимо.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Отмена',
              style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Удалить', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _deleting = true);

    try {
      await ref.read(choresRepositoryProvider).deleteFamilyChore(widget.chore.id);

      // Revalidate both family and default chores
      await Future.wait([
        Swr.mutate('family-chores'),
        Swr.mutate('default-chores'),
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Обязанность "${widget.chore.name}" удалена'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при удалении: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            SizedBox(
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 4,
                    child: TextButton.icon(
                      onPressed: (_saving || _deleting) ? null : () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        'Назад',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  Text(
                    'Редактирование',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar display: static ChoreIcon for default chores, AvatarBuilder for custom
                    if (_isDefaultChore)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: ChoreIconWidget(
                            icon: widget.chore.icon,
                            iconBg: widget.chore.iconBg,
                            iconColor: widget.chore.iconColor,
                            size: 80,
                          ),
                        ),
                      )
                    else
                      AvatarBuilderWidget(
                        initialIcon: _icon,
                        initialIconColor: _iconColor,
                        initialBg: _iconBg,
                        onChanged: (val) {
                          setState(() {
                            _icon = val.icon;
                            _iconColor = val.iconColor;
                            _iconBg = val.iconBg;
                          });
                        },
                      ),

                    const SizedBox(height: 20),

                    // Name Field
                    Text(
                      'НАЗВАНИЕ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameCtrl,
                      enabled: !_isDefaultChore && !_deleting && !_saving,
                      style: TextStyle(
                        fontSize: 15,
                        color: _isDefaultChore ? AppColors.textMuted : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Название обязанности',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: _isDefaultChore ? AppColors.surfaceAlt : AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.borderSubtle, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.borderSubtle, width: 1),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.borderSubtle.withValues(alpha: 0.5), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description Field
                    Text(
                      'ОПИСАНИЕ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descCtrl,
                      enabled: !_deleting && !_saving,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Добавьте описание...',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.borderSubtle, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.borderSubtle, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: (_saving || _deleting) ? null : () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                foregroundColor: AppColors.textMuted,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(color: AppColors.borderSubtle),
                                ),
                              ),
                              child: const Text(
                                'Отмена',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: (_saving || _deleting) ? null : _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: _saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Сохранить',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Danger Zone: Delete Button
                    Container(
                      padding: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.borderSubtle, width: 1),
                        ),
                      ),
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: (_saving || _deleting) ? null : _handleDelete,
                          icon: _deleting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Color(0xFFE87C5A)),
                                  ),
                                )
                              : const Icon(
                                  Icons.delete_rounded,
                                  size: 18,
                                  color: Color(0xFFE87C5A),
                                ),
                          label: Text(
                            _deleting ? 'Удаление...' : 'Удалить обязанность',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE87C5A),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFE87C5A).withValues(alpha: 0.08),
                            side: const BorderSide(color: Color(0xFFE87C5A), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
