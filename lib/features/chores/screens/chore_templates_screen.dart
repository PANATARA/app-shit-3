import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/swr/swr.dart';
import '../../../core/theme/app_colors.dart';
import '../models/chore_item_model.dart';
import '../providers/family_chores_provider.dart';
import '../repositories/chores_repository.dart';
import '../widgets/chore_icon_widget.dart';
import 'chore_create_screen.dart';

class ChoreTemplatesScreen extends ConsumerStatefulWidget {
  const ChoreTemplatesScreen({super.key});

  @override
  ConsumerState<ChoreTemplatesScreen> createState() => _ChoreTemplatesScreenState();
}

class _ChoreTemplatesScreenState extends ConsumerState<ChoreTemplatesScreen> {
  final Set<String> _addingIds = {};

  Future<void> _addFromDefault(ChoreItem def) async {
    if (_addingIds.contains(def.id)) return;
    setState(() => _addingIds.add(def.id));

    try {
      final currentLang = ref.read(appLocaleProvider).languageCode;
      await ref.read(choresRepositoryProvider).addChoresFromDefault(
        defaultChoreIds: [def.id],
        language: currentLang,
      );
      // Revalidate family chores and default chores
      await Future.wait([
        Swr.mutate('family-chores'),
        Swr.mutate('default-chores'),
      ]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Обязанность "${def.name}" добавлена'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при добавлении: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _addingIds.remove(def.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultChoresState = ref.watch(defaultChoresSwr);
    final defaultChores = defaultChoresState.data ?? [];
    final isLoading = defaultChoresState.isLoading && defaultChores.isEmpty;

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
                      onPressed: () => Navigator.of(context).pop(),
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
                    'Выбор шаблона',
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
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: () async {
                  await ref.read(defaultChoresSwr.notifier).revalidate();
                },
                child: ListView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [
                    // Create Custom Chore Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ChoreCreateScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1.5,
                                strokeAlign: BorderSide.strokeAlignInside,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            child: Row(
                              children: [
                                const Text('✏️', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 12),
                                Text(
                                  'Создать свою обязанность',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (defaultChores.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Text('📋', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 10),
                            Text(
                              'Нет доступных шаблонов',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: Text(
                          'ТИПОВЫЕ ОБЯЗАННОСТИ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: defaultChores.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final def = defaultChores[index];
                          final isAdding = _addingIds.contains(def.id);

                          return Row(
                            children: [
                              // Info card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.borderSubtle, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      ChoreIconWidget(
                                        icon: def.icon,
                                        iconBg: def.iconBg,
                                        iconColor: def.iconColor,
                                        size: 42,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              def.name,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (def.description != null &&
                                                def.description!.trim().isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                def.description!,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.textMuted,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Quick add button
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: Material(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(21),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(21),
                                    onTap: isAdding ? null : () => _addFromDefault(def),
                                    child: Center(
                                      child: isAdding
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation(Colors.white),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.add_rounded,
                                              size: 24,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
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
