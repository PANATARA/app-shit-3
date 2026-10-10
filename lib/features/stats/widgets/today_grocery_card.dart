import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../meals/models/grocery_item_model.dart';
import '../../meals/providers/meals_provider.dart';
import '../../meals/widgets/grocery_list_sheet.dart';
import 'ui_card.dart';

class TodayGroceryCard extends ConsumerWidget {
  const TodayGroceryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final groceriesState = ref.watch(familyGroceriesSwr);
    final allItems = groceriesState.data ?? const [];
    // Show unbought items first, then recently checked
    final unboughtItems = allItems.where((i) => !i.checked).toList();
    final boughtItems = allItems.where((i) => i.checked).toList();
    final sortedItems = [...unboughtItems, ...boughtItems];
    final displayItems = sortedItems.take(5).toList();
    final remainingCount = sortedItems.length - displayItems.length;

    return UiCard(
      title: l10n?.statsTodayGrocery ?? 'СПИСОК ПОКУПОК',
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (unboughtItems.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${unboughtItems.length}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              GroceryListSheet.show(context);
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 13, color: AppColors.primary),
                  const SizedBox(width: 3),
                  Text(
                    l10n?.statsGroceryAdd ?? 'Добавить',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: sortedItems.isEmpty
          ? _buildEmptyState(context, l10n)
          : Column(
              children: [
                ...displayItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == displayItems.length - 1 && remainingCount <= 0;

                  return Column(
                    children: [
                      _GroceryRowItem(item: item),
                      if (!isLast)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: AppColors.borderSubtle,
                        ),
                    ],
                  );
                }),
                if (remainingCount > 0) ...[
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: AppColors.borderSubtle,
                  ),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      GroceryListSheet.show(context);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n?.statsMoreGroceries(remainingCount) ??
                                'И ещё $remainingCount ${remainingCount == 1 ? "покупка" : (remainingCount < 5 ? "покупки" : "покупок")}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations? l10n) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        GroceryListSheet.show(context);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 22,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n?.statsGroceryEmpty ?? 'Список покупок пуст',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n?.statsGroceryEmptyHint ?? 'Нажмите «Добавить», чтобы составить список продуктов',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _GroceryRowItem extends ConsumerWidget {
  final GroceryItemModel item;

  const _GroceryRowItem({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(groceriesCoordinatorProvider).toggleItem(item.id, item.checked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
        child: Row(
          children: [
            // Circular outline checkbox (Apple-styled orange circle)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.checked ? AppColors.success : Colors.transparent,
                border: Border.all(
                  color: item.checked ? AppColors.success : const Color(0xFFF59E0B),
                  width: 2.2,
                ),
              ),
              alignment: Alignment.center,
              child: item.checked
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                  : null,
            ),
            const SizedBox(width: 14),

            // Shopping cart line icon (as in reference screenshot)
            Icon(
              Icons.shopping_cart_outlined,
              size: 20,
              color: item.checked ? AppColors.textMuted : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),

            // Title & Amount
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: item.checked ? AppColors.textMuted : AppColors.textPrimary,
                        decoration: item.checked ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.amount != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${item.amount! % 1 == 0 ? item.amount!.toInt() : item.amount} ${item.unit ?? ''}'.trim(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: item.checked ? AppColors.textMuted : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
