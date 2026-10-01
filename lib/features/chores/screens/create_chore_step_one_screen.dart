import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/chore_item_model.dart';
import '../repositories/chores_repository.dart';
import '../widgets/chore_icon_widget.dart';
import '../widgets/chore_screen_header.dart';
import 'create_chore_step_two_screen.dart';

class CreateChoreStepOneScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const CreateChoreStepOneScreen({super.key, required this.selectedDate});

  @override
  ConsumerState<CreateChoreStepOneScreen> createState() => _CreateChoreStepOneScreenState();
}

class _CreateChoreStepOneScreenState extends ConsumerState<CreateChoreStepOneScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<ChoreItem> _chores = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChores() async {
    try {
      final chores = await ref.read(choresRepositoryProvider).getFamilyChores();
      if (mounted) setState(() { _chores = chores; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  List<ChoreItem> get _filtered {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _chores;
    return _chores.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  bool get _hasExactMatch =>
      _filtered.any((c) => c.name.toLowerCase() == _searchQuery.trim().toLowerCase());

  bool get _showCreateNew => _searchQuery.trim().isNotEmpty && !_hasExactMatch;

  void _goToStepTwo({ChoreItem? chore, bool isQuick = false, String? customName}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CreateChoreStepTwoScreen(
        selectedDate: widget.selectedDate,
        isQuickTask: isQuick,
        selectedChore: chore,
        customName: customName,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ChoreScreenHeader(onBack: () => Navigator.of(context).pop(), title: 'Запланировать задачу'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _SearchBox(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const _SkeletonList();
    if (_error != null) {
      return Center(child: Text('Ошибка загрузки', style: TextStyle(color: AppColors.error)));
    }

    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // Quick task — only when no search
        if (_searchQuery.trim().isEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: _QuickTaskItem(onTap: () => _goToStepTwo(isQuick: true)),
          ),
          _SectionDivider(label: 'или выберите из шаблонов'),
        ],

        // "Create <name>" button
        if (_showCreateNew)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: _CreateNewItem(
              name: _searchQuery.trim(),
              onTap: () => _goToStepTwo(customName: _searchQuery.trim()),
            ),
          ),

        // Chore templates
        if (_filtered.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: _filtered.map((chore) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ChoreListItem(chore: chore, onTap: () => _goToStepTwo(chore: chore)),
              )).toList(),
            ),
          )
        else if (!_showCreateNew)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('Ничего не найдено', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
            ),
          ),
      ],
    );
  }
}

// ─── Search Box ──────────────────────────────────────────────────────────────

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBox({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Поиск задач...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, _) => value.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                    onPressed: () { controller.clear(); onChanged(''); },
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Task Item ─────────────────────────────────────────────────────────

class _QuickTaskItem extends StatelessWidget {
  final VoidCallback onTap;

  const _QuickTaskItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.bolt_rounded, size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Быстрая задача', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    SizedBox(height: 2),
                    Text('Создать разовую задачу без шаблона', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Divider ─────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  final String label;

  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.border, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ),
          Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        ],
      ),
    );
  }
}

// ─── Create New Item ─────────────────────────────────────────────────────────

class _CreateNewItem extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _CreateNewItem({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary.withValues(alpha: 0.14), AppColors.surface],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text('+', style: TextStyle(fontSize: 22, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Создать «$name»',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Chore List Item ─────────────────────────────────────────────────────────

class _ChoreListItem extends StatelessWidget {
  final ChoreItem chore;
  final VoidCallback onTap;

  const _ChoreListItem({required this.chore, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Real icon using ChoreIconWidget — exactly same as in cards
              ChoreIconWidget(
                icon: chore.icon,
                iconBg: chore.iconBg,
                iconColor: chore.iconColor,
                size: 44,
                isQuick: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chore.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    if (chore.description != null && chore.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(chore.description!, style: TextStyle(fontSize: 12.5, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(5, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            height: 68,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          ),
        )),
      ),
    );
  }
}


