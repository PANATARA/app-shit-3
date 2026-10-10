import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/avatar_builder_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../../chores/models/chore_item_model.dart';
import '../../chores/repositories/chores_repository.dart';
import '../../chores/utils/color_helper.dart';
import '../../chores/utils/icon_mapper.dart';
import '../models/family_model.dart';
import '../repositories/onboarding_repository.dart';

enum _OnboardingStep {
  choose,
  createStep1,
  createStep2,
  choresSelection,
  join,
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _OnboardingStep _step = _OnboardingStep.choose;

  // Create Family Form
  final _nameController = TextEditingController();
  String _familyIcon = 'material-symbols:family-home-rounded';
  String _familyIconColor = '#FFFFFF';
  String _familyIconBg = 'linear-gradient(135deg, #F97316 0%, #FB7185 100%)';
  FamilyModel? _createdFamily;

  // Default Chores Selection
  List<ChoreItem> _defaultChores = [];
  Set<String> _selectedChoreIds = {};
  bool _loadingDefaultChores = false;
  bool _isAddingChores = false;

  // Join Family Form
  final _joinCodeController = TextEditingController();
  FamilyModel? _joinedFamily;

  // State
  bool _isLoading = false;
  String? _errorMessage;

  static const List<String> _suggestionsRu = [
    'Семья Смирновых',
    'Уютный дом',
    'Наш очаг',
    'Family Circle',
  ];

  static const List<String> _suggestionsEn = [
    'Smith Family',
    'Cozy Home',
    'Our Hearth',
    'Family Circle',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  void _formatJoinCode(String value) {
    final clean = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    final truncated = clean.length > 6 ? clean.substring(0, 6) : clean;
    final formatted = truncated.length > 3
        ? '${truncated.substring(0, 3)}-${truncated.substring(3)}'
        : truncated;

    if (_joinCodeController.text != formatted) {
      _joinCodeController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _pasteJoinCode() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null && data!.text!.isNotEmpty) {
        _formatJoinCode(data.text!);
        setState(() => _errorMessage = null);
      }
    } catch (_) {}
  }

  Future<void> _handleCreateFamily() async {
    final name = _nameController.text.trim();
    final l10n = AppLocalizations.of(context);
    if (name.isEmpty) {
      setState(() => _errorMessage = l10n?.onboardingFamilyNameRequired ?? 'Пожалуйста, введите название семьи');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(onboardingRepositoryProvider);
      final family = await repo.createFamily(
        name: name,
        icon: _familyIcon,
        iconColor: _familyIconColor,
        iconBg: _familyIconBg,
      );

      _createdFamily = family;
      _step = _OnboardingStep.choresSelection;
      _isLoading = false;
      setState(() {});

      _loadDefaultChores();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadDefaultChores() async {
    setState(() => _loadingDefaultChores = true);
    try {
      final choresRepo = ref.read(choresRepositoryProvider);
      final chores = await choresRepo.getDefaultChores();
      if (mounted) {
        setState(() {
          _defaultChores = chores;
          // Preselect first 4 chores for quick pleasant start
          _selectedChoreIds = chores.take(4).map((c) => c.id).toSet();
          _loadingDefaultChores = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingDefaultChores = false);
      }
    }
  }

  void _toggleChoreSelection(String choreId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedChoreIds.contains(choreId)) {
        _selectedChoreIds.remove(choreId);
      } else {
        _selectedChoreIds.add(choreId);
      }
    });
  }

  void _toggleSelectAll() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedChoreIds.length == _defaultChores.length) {
        _selectedChoreIds.clear();
      } else {
        _selectedChoreIds = _defaultChores.map((c) => c.id).toSet();
      }
    });
  }

  Future<void> _handleAddChoresAndEnter() async {
    if (_isAddingChores) return;
    HapticFeedback.mediumImpact();

    if (_selectedChoreIds.isNotEmpty) {
      setState(() => _isAddingChores = true);
      try {
        final choresRepo = ref.read(choresRepositoryProvider);
        final lang = ref.read(appLocaleProvider).languageCode;
        await choresRepo.addChoresFromDefault(
          defaultChoreIds: _selectedChoreIds.toList(),
          language: lang,
        );
      } catch (e) {
        debugPrint('[Onboarding] addChoresFromDefault error: $e');
      } finally {
        if (mounted) setState(() => _isAddingChores = false);
      }
    }

    // Refresh profile to trigger router transition to home
    await ref.read(authProvider.notifier).refreshProfile();
  }

  Future<void> _handleSkipChoresAndEnter() async {
    HapticFeedback.lightImpact();
    await ref.read(authProvider.notifier).refreshProfile();
  }

  Future<void> _handleJoinFamily() async {
    final clean = _joinCodeController.text.replaceAll('-', '').trim().toUpperCase();
    final l10n = AppLocalizations.of(context);
    if (clean.length < 6) {
      setState(() => _errorMessage = l10n?.onboardingEnterFullCodeError ?? 'Введите полный 6-значный код (например, ABC-123)');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(onboardingRepositoryProvider);
      final family = await repo.joinFamily(inviteCode: clean);
      if (mounted) {
        setState(() {
          _joinedFamily = family;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = l10n?.onboardingFamilyNotFoundError ?? 'Семья с таким кодом не найдена';
        });
      }
    }
  }

  Future<void> _handleEnterJoinedFamily() async {
    HapticFeedback.mediumImpact();
    await ref.read(authProvider.notifier).refreshProfile();
  }

  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.settingsLogout ?? 'Выйти из аккаунта?'),
        content: Text(l10n?.settingsConfirmLogout ?? 'Вы уверены, что хотите выйти из приложения?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.commonCancel ?? 'Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.commonConfirm ?? 'Выйти'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == _OnboardingStep.choose,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          setState(() {
            if (_step == _OnboardingStep.createStep1 || _step == _OnboardingStep.join) {
              _step = _OnboardingStep.choose;
            } else if (_step == _OnboardingStep.createStep2) {
              _step = _OnboardingStep.createStep1;
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _buildCurrentStep(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_step) {
      case _OnboardingStep.choose:
        return _buildChooseStep(context);
      case _OnboardingStep.createStep1:
        return _buildCreateStep1(context);
      case _OnboardingStep.createStep2:
        return _buildCreateStep2(context);
      case _OnboardingStep.choresSelection:
        return _buildChoresSelectionStep(context);
      case _OnboardingStep.join:
        return _buildJoinStep(context);
    }
  }

  // ─── 1. CHOOSE STEP ────────────────────────────────────────────────────────

  Widget _buildChooseStep(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      key: const ValueKey('choose_step'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          // Header with logout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.onboardingFamilyCircle ?? 'Семейный круг',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: -0.2,
                ),
              ),
              IconButton(
                onPressed: _handleLogout,
                icon: Icon(Icons.logout_rounded, size: 20, color: AppColors.textMuted),
                tooltip: l10n?.onboardingLogout ?? 'Выйти из аккаунта',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Intro Icon & Title
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.family_restroom_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.onboardingChooseTitle ?? 'Как начнём?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.onboardingChooseSubtitle ??
                'Создайте новое семейное пространство или присоединитесь к уже существующему.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 32),

          // Card 1: Create
          _buildChooseOptionCard(
            label: l10n?.onboardingNewFamily ?? 'Новая семья',
            title: l10n?.onboardingCreateFamily ?? 'Создать семью',
            desc: l10n?.onboardingCreateFamilyDesc ??
                'Создайте пространство для семьи и пригласите близких.',
            actionText: l10n?.onboardingStartCreating ?? 'Начать создание',
            icon: Icons.add_home_rounded,
            iconBg: AppColors.primary.withValues(alpha: 0.15),
            iconColor: AppColors.primary,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _step = _OnboardingStep.createStep1;
                _errorMessage = null;
              });
            },
          ),
          const SizedBox(height: 16),

          // Card 2: Join
          _buildChooseOptionCard(
            label: l10n?.onboardingAlreadyHaveFamily ?? 'Уже есть семья?',
            title: l10n?.onboardingJoinFamily ?? 'Присоединиться',
            desc: l10n?.onboardingJoinFamilyDesc ??
                'Войдите по коду-приглашению от администратора вашей семьи.',
            actionText: l10n?.onboardingEnterCode ?? 'Ввести код',
            icon: Icons.group_add_rounded,
            iconBg: const Color(0xFF6366F1).withValues(alpha: 0.15),
            iconColor: const Color(0xFF6366F1),
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _step = _OnboardingStep.join;
                _errorMessage = null;
              });
            },
          ),

          const Spacer(),

          // Bottom Hint
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 15, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Приватное пространство только для вашей семьи',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChooseOptionCard({
    required String label,
    required String title,
    required String desc,
    required String actionText,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderSubtle, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  actionText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── 2. CREATE STEP 1: NAME ────────────────────────────────────────────────

  Widget _buildCreateStep1(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(appLocaleProvider).languageCode;
    final suggestions = lang == 'ru' ? _suggestionsRu : _suggestionsEn;

    return Padding(
      key: const ValueKey('create_step1'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          // Top bar
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _step = _OnboardingStep.choose),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.onboardingStep1Of2 ?? 'Шаг 1 из 2',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    l10n?.onboardingCreateFamily ?? 'Создать семью',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            l10n?.onboardingStep1Title ?? 'Назовите вашу семью',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n?.onboardingStep1Subtitle ?? 'Придумайте название для вашего семейного круга',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),

          // Input field card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.onboardingFamilyNameLabel ?? 'Название семьи',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  autofocus: true,
                  maxLength: 60,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 4, right: 8),
                      child: Text('🏡', style: const TextStyle(fontSize: 22)),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 24),
                    hintText: l10n?.onboardingFamilyPlaceholder ?? 'Например: Семья Смирновых',
                    hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.6), fontSize: 15),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  onChanged: (_) {
                    if (_errorMessage != null) setState(() => _errorMessage = null);
                  },
                ),
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.error_outline_rounded, size: 16, color: AppColors.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // Suggestions
          Text(
            l10n?.onboardingSuggestions ?? 'Варианты:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((sugg) {
              final isSelected = _nameController.text == sugg;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _nameController.text = sugg;
                  if (_errorMessage != null) setState(() => _errorMessage = null);
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    sugg,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const Spacer(),

          // Continue button
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) {
                    setState(() => _errorMessage = l10n?.onboardingFamilyNameRequired ?? 'Пожалуйста, введите название семьи');
                    return;
                  }
                  HapticFeedback.lightImpact();
                  setState(() {
                    _step = _OnboardingStep.createStep2;
                    _errorMessage = null;
                  });
                },
                child: Text(
                  l10n?.commonConfirm ?? 'Продолжить',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 3. CREATE STEP 2: CREST & AVATAR ──────────────────────────────────────

  Widget _buildCreateStep2(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      key: const ValueKey('create_step2'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          // Top bar
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _step = _OnboardingStep.createStep1),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.onboardingStep2Of2 ?? 'Шаг 2 из 2',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    l10n?.onboardingChooseAvatar ?? 'Герб семьи',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Scrollable avatar constructor
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n?.onboardingChooseAvatar ?? 'Выберите герб семьи',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Иконка и цвет будут отображаться на главном экране',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),

                  AvatarBuilderWidget(
                    initialIcon: _familyIcon,
                    initialIconColor: _familyIconColor,
                    initialBg: _familyIconBg,
                    onChanged: (val) {
                      _familyIcon = val.icon;
                      _familyIconColor = val.iconColor;
                      _familyIconBg = val.iconBg;
                    },
                  ),
                  const SizedBox(height: 16),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded, size: 18, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          // Submit button
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _handleCreateFamily,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        l10n?.onboardingCreateFamilyBtn ?? 'Создать семейный круг',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 4. CHORES SELECTION STEP ──────────────────────────────────────────────

  Widget _buildChoresSelectionStep(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final family = _createdFamily;

    return Padding(
      key: const ValueKey('chores_selection_step'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Family success badge
          if (family != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle, width: 0.8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: ColorHelper.parseBgDecoration(family.iconBg, borderRadius: 14),
                    child: Center(
                      child: IconMapper.getEmoji(family.icon) != null
                          ? Text(IconMapper.getEmoji(family.icon)!, style: const TextStyle(fontSize: 20))
                          : Icon(
                              IconMapper.getIcon(family.icon),
                              size: 20,
                              color: ColorHelper.parseHexColor(family.iconColor),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '«${family.name}»',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              l10n?.onboardingFamilyCreatedTitle ?? 'Семья создана!',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),

          Text(
            l10n?.onboardingAddInitialChoresTitle ?? 'Добавьте первые задачи',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n?.onboardingAddInitialChoresSubtitle ??
                'Выберите типовые домашние дела, чтобы сразу начать пользоваться',
            style: TextStyle(fontSize: 13.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),

          // Toolbar: selected count + select/deselect all
          if (!_loadingDefaultChores && _defaultChores.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Выбрано: ${_selectedChoreIds.length} из ${_defaultChores.length}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                ),
                GestureDetector(
                  onTap: _toggleSelectAll,
                  child: Text(
                    _selectedChoreIds.length == _defaultChores.length
                        ? (l10n?.onboardingDeselectAll ?? 'Снять все')
                        : (l10n?.onboardingSelectAll ?? 'Выбрать все'),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),

          // Scrollable list of chores
          Expanded(
            child: _loadingDefaultChores
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    itemCount: _defaultChores.length,
                    itemBuilder: (context, index) {
                      final chore = _defaultChores[index];
                      final isSelected = _selectedChoreIds.contains(chore.id);

                      return GestureDetector(
                        onTap: () => _toggleChoreSelection(chore.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.surfaceAlt : AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                              width: isSelected ? 1.5 : 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Icon pill
                              Container(
                                width: 42,
                                height: 42,
                                decoration: ColorHelper.parseBgDecoration(chore.iconBg, borderRadius: 13),
                                child: Center(
                                  child: IconMapper.getEmoji(chore.icon) != null
                                      ? Text(IconMapper.getEmoji(chore.icon)!, style: const TextStyle(fontSize: 20))
                                      : Icon(
                                          IconMapper.getIcon(chore.icon),
                                          size: 20,
                                          color: ColorHelper.parseHexColor(chore.iconColor),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chore.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (chore.description != null && chore.description!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        chore.description!,
                                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    if (chore.valuation > 0) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '+${chore.valuation} XP',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Checkmark circle
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Actions
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            child: Column(
              children: [
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: _isAddingChores ? null : _handleAddChoresAndEnter,
                    child: _isAddingChores
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _selectedChoreIds.isNotEmpty
                                ? 'Добавить задачи (${_selectedChoreIds.length}) и войти'
                                : (l10n?.onboardingEnterFamily ?? 'Войти в семейный круг'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _isAddingChores ? null : _handleSkipChoresAndEnter,
                  child: Text(
                    l10n?.onboardingSkipChores ?? 'Пропустить и войти',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 5. JOIN STEP: INVITE CODE ─────────────────────────────────────────────

  Widget _buildJoinStep(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final joined = _joinedFamily;

    if (joined != null) {
      // Joined success card!
      return Padding(
        key: const ValueKey('join_success'),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: ColorHelper.parseBgDecoration(joined.iconBg, borderRadius: 26),
                    child: Center(
                      child: IconMapper.getEmoji(joined.icon) != null
                          ? Text(IconMapper.getEmoji(joined.icon)!, style: const TextStyle(fontSize: 36))
                          : Icon(
                              IconMapper.getIcon(joined.icon),
                              size: 36,
                              color: ColorHelper.parseHexColor(joined.iconColor),
                            ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n?.onboardingJoinSuccessTitle ?? 'Вы успешно вступили в семью!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '«${joined.name}»',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _handleEnterJoinedFamily,
                child: Text(
                  l10n?.onboardingEnterFamily ?? 'Войти в семейный круг',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      key: const ValueKey('join_form'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          // Top bar
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _step = _OnboardingStep.choose),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Присоединение',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    l10n?.onboardingJoinTitle ?? 'Вступить в семью',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.group_add_rounded, size: 30, color: Color(0xFF6366F1)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.onboardingJoinTitle ?? 'Вступить в семью',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n?.onboardingJoinSubtitle ?? 'Введите 6-значный код приглашения вашей семьи',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 28),

          // Code input card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Код приглашения',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                    GestureDetector(
                      onTap: _pasteJoinCode,
                      child: Row(
                        children: [
                          Icon(Icons.content_paste_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            l10n?.onboardingPasteCode ?? 'Вставить',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _joinCodeController,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'AAA-000',
                    hintStyle: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                      color: AppColors.textMuted.withValues(alpha: 0.3),
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    _formatJoinCode(val);
                    if (_errorMessage != null) setState(() => _errorMessage = null);
                  },
                ),
                const SizedBox(height: 8),

                Text(
                  'Формат: 6 символов, например ABC-123',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, size: 18, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Код можно узнать у администратора вашей семьи в настройках профиля',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Submit join button
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _handleJoinFamily,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        l10n?.onboardingJoinBtn ?? 'Присоединиться',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
