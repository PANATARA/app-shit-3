import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_modal_sheet.dart';
import '../models/recipe_model.dart';
import '../providers/meals_provider.dart';

class AddCustomRecipeSheet extends ConsumerStatefulWidget {
  const AddCustomRecipeSheet({super.key});

  static Future<RecipeModel?> show(BuildContext context) {
    return showAppModalBottomSheet<RecipeModel>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RepaintBoundary(child: AddCustomRecipeSheet()),
    );
  }

  @override
  ConsumerState<AddCustomRecipeSheet> createState() => _AddCustomRecipeSheetState();
}

class _IngredientRowData {
  final TextEditingController nameController;
  final TextEditingController amountController;
  final TextEditingController unitController;

  _IngredientRowData({String name = '', String amount = '', String unit = 'г'})
      : nameController = TextEditingController(text: name),
        amountController = TextEditingController(text: amount),
        unitController = TextEditingController(text: unit);

  void dispose() {
    nameController.dispose();
    amountController.dispose();
    unitController.dispose();
  }
}

class _StepRowData {
  final TextEditingController textController;

  _StepRowData({String text = ''})
      : textController = TextEditingController(text: text);

  void dispose() {
    textController.dispose();
  }
}

class _AddCustomRecipeSheetState extends ConsumerState<AddCustomRecipeSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController(text: '15');
  final TextEditingController _cookTimeController = TextEditingController(text: '20');

  String _selectedCategory = 'dinner';
  int _baseServings = 4;
  String _selectedEmoji = '🍲';
  String _selectedEmojiCat = 'all';

  final List<_IngredientRowData> _ingredients = [];
  final List<_StepRowData> _steps = [];

  bool _isSubmitting = false;
  String? _errorMessage;

  static const _emojiCategories = [
    {'id': 'all', 'label': 'Все'},
    {'id': 'hot', 'label': 'Горячее'},
    {'id': 'meat_fish', 'label': 'Мясо и рыба'},
    {'id': 'pasta_pizza', 'label': 'Паста и пицца'},
    {'id': 'breakfast', 'label': 'Завтрак'},
    {'id': 'fastfood', 'label': 'Фастфуд'},
    {'id': 'salads_veg', 'label': 'Салаты и овощи'},
    {'id': 'fruits', 'label': 'Фрукты'},
    {'id': 'desserts', 'label': 'Десерты'},
    {'id': 'drinks', 'label': 'Напитки'},
  ];

  static const Map<String, List<String>> _categoryEmojis = {
    'hot': ['🍲', '🥣', '🍜', '🥘', '🫕', '🥟', '🍛', '🧆', '🫔'],
    'meat_fish': ['🥩', '🍗', '🍖', '🥓', '🌭', '🍢', '🐟', '🍣', '🍤', '🦞', '🦀', '🦑', '🦪'],
    'pasta_pizza': ['🍝', '🍕', '🍚', '🥔', '🍠', '🌽'],
    'breakfast': ['🍳', '🥚', '🥞', '🧇', '🧀', '🥐', '🥯', '🥑'],
    'fastfood': ['🍔', '🥪', '🌮', '🌯', '🥙', '🍟', '🥨', '🥖', '🍞'],
    'salads_veg': ['🥗', '🥒', '🍅', '🥦', '🥕', '🫑', '🍆', '🧄', '🧅', '🍄'],
    'fruits': ['🍎', '🍏', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🫐', '🍒', '🍑', '🥭', '🍍', '🥝'],
    'desserts': ['🥧', '🍰', '🎂', '🧁', '🍪', '🍩', '🍮', '🍨', '🍦', '🍫', '🍬', '🍭'],
    'drinks': ['☕', '🍵', '🧃', '🥤', '🥛', '🧋', '🫖', '🍹', '🍺'],
  };

  static final List<String> _allEmojis =
      _categoryEmojis.values.expand((list) => list).toSet().toList();

  @override
  void initState() {
    super.initState();
    _ingredients.add(_IngredientRowData());
    _steps.add(_StepRowData());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    for (final i in _ingredients) {
      i.dispose();
    }
    for (final s in _steps) {
      s.dispose();
    }
    super.dispose();
  }

  List<String> get _displayedEmojis {
    if (_selectedEmojiCat == 'all') return _allEmojis;
    return _categoryEmojis[_selectedEmojiCat] ?? _allEmojis;
  }

  void _addIngredientRow() {
    setState(() {
      _ingredients.add(_IngredientRowData());
    });
  }

  void _removeIngredientRow(int index) {
    if (_ingredients.length > 1) {
      setState(() {
        _ingredients.removeAt(index).dispose();
      });
    }
  }

  void _addStepRow() {
    setState(() {
      _steps.add(_StepRowData());
    });
  }

  void _removeStepRow(int index) {
    if (_steps.length > 1) {
      setState(() {
        _steps.removeAt(index).dispose();
      });
    }
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorMessage = 'Введите название блюда');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final validIngredients = _ingredients
        .where((i) => i.nameController.text.trim().isNotEmpty)
        .map((i) {
          final amt = double.tryParse(i.amountController.text.trim());
          return {
            'name': i.nameController.text.trim(),
            'amount': amt,
            'unit': i.unitController.text.trim().isEmpty ? 'шт' : i.unitController.text.trim(),
            'checked': false,
          };
        })
        .toList();

    final validSteps = _steps
        .where((s) => s.textController.text.trim().isNotEmpty)
        .toList()
        .asMap()
        .entries
        .map((e) => {
              'number': e.key + 1,
              'text': e.value.textController.text.trim(),
            })
        .toList();

    final prep = int.tryParse(_prepTimeController.text) ?? 15;
    final cook = int.tryParse(_cookTimeController.text) ?? 20;

    final categoryLabels = {
      'quick': 'Быстрые',
      'dinner': 'Ужин',
      'kids': 'Детям',
      'desserts': 'Десерты',
    };

    final payload = <String, dynamic>{
      'title': title,
      'description': _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      'prep_time_minutes': prep,
      'cook_time_minutes': cook,
      'base_servings': _baseServings,
      'category': _selectedCategory,
      'tags': [categoryLabels[_selectedCategory] ?? 'Свой рецепт'],
      'is_favorite': false,
      'emoji': _selectedEmoji,
      'accent_gradient': 'linear-gradient(135deg, #F97316 0%, #EA580C 100%)',
      'ingredients': validIngredients,
      'steps': validSteps,
    };

    try {
      final created = await ref.read(recipesCoordinatorProvider).createRecipe(payload);
      if (mounted) {
        Navigator.of(context).pop(created);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Ошибка сохранения: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final height = MediaQuery.of(context).size.height * 0.90;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset + safeBottom),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Новое блюдо',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Добавьте рецепт в кулинарную книгу',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: AppColors.textMuted),
                  iconSize: 22,
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 13, color: AppColors.error),
                    ),
                  ),

                // Emoji Selector Section
                _buildEmojiSelector(),
                const SizedBox(height: 16),

                // Title & Description
                _buildLabel('НАЗВАНИЕ БЛЮДА *'),
                const SizedBox(height: 6),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _titleController,
                    style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Например: Домашняя паста с томатами',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _buildLabel('ОПИСАНИЕ БЛЮДА'),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: TextField(
                    controller: _descController,
                    maxLines: 2,
                    style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Коротко о вкусе, подаче или секретах...',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category chips
                _buildLabel('КАТЕГОРИЯ'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildCategoryChip('dinner', 'Ужин'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('quick', 'Быстрые'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('kids', 'Детям'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('desserts', 'Десерты'),
                  ],
                ),
                const SizedBox(height: 16),

                // Servings & Times
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('ПОРЦИИ'),
                          const SizedBox(height: 6),
                          Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (_baseServings > 1) setState(() => _baseServings--);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(Icons.remove, size: 18),
                                  ),
                                ),
                                Text(
                                  '$_baseServings',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setState(() => _baseServings++),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(Icons.add, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('ПОДГОТОВКА'),
                          const SizedBox(height: 6),
                          Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _prepTimeController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                    decoration: const InputDecoration(
                                      filled: false,
                                      fillColor: Colors.transparent,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Text('мин', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('ГОТОВКА'),
                          const SizedBox(height: 6),
                          Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _cookTimeController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                    decoration: const InputDecoration(
                                      filled: false,
                                      fillColor: Colors.transparent,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Text('мин', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Ingredients Builder
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('ИНГРЕДИЕНТЫ'),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _addIngredientRow,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 16, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Добавить',
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
                const SizedBox(height: 8),

                Column(
                  children: _ingredients.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.center,
                              child: TextField(
                                controller: item.nameController,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Ингредиент',
                                  hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              alignment: Alignment.center,
                              child: TextField(
                                controller: item.amountController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Кол-во',
                                  hintStyle: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              alignment: Alignment.center,
                              child: TextField(
                                controller: item.unitController,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Ед.',
                                  hintStyle: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ),
                          if (_ingredients.length > 1) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: () => _removeIngredientRow(index),
                              icon: Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // Steps Builder
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('ШАГИ ПРИГОТОВЛЕНИЯ'),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _addStepRow,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 16, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Шаг',
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
                const SizedBox(height: 8),

                Column(
                  children: _steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: TextField(
                                controller: step.textController,
                                maxLines: 2,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Опишите шаг ${index + 1}...',
                                  hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ),
                          if (_steps.length > 1) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: () => _removeStepRow(index),
                              icon: Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 20),
                              padding: const EdgeInsets.only(top: 8),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Создать рецепт',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildCategoryChip(String id, String label) {
    final isSelected = _selectedCategory == id;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _selectedCategory = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderSubtle,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                alignment: Alignment.center,
                child: Text(_selectedEmoji, style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ИКОНКА БЛЮДА',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Выберите подходящий эмодзи для обложки',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Emoji Category Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _emojiCategories.map((cat) {
                final isSelected = _selectedEmojiCat == cat['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _selectedEmojiCat = cat['id']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        cat['label']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Emoji Grid
          SizedBox(
            height: 220,
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _displayedEmojis.map((em) {
                  final isSelected = _selectedEmoji == em;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _selectedEmoji = em),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(em, style: const TextStyle(fontSize: 20)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
