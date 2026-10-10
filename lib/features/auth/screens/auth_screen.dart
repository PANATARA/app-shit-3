import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isRegister = false;
  String? _errorText;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final l10n = AppLocalizations.of(context);

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorText = l10n?.authFillRequired ?? 'Заполните логин и пароль');
      return;
    }

    setState(() => _errorText = null);

    final authNotifier = ref.read(authProvider.notifier);
    bool success;

    if (_isRegister) {
      success = await authNotifier.register(
        username: username,
        password: password,
        name: name,
      );
    } else {
      success = await authNotifier.login(
        username: username,
        password: password,
      );
    }

    if (!mounted) return;

    if (!success) {
      final error = ref.read(authProvider).errorMessage;
      setState(() {
        _errorText = error ?? 'Ошибка соединения с бэкендом';
      });
    }
  }

  void _showServerSettingsDialog(BuildContext context, String currentUrl) {
    final controller = TextEditingController(text: currentUrl);
    String? testResult;
    bool isTesting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.dns_rounded, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text('Адрес сервера', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Укажите URL бэкенда (например, http://192.168.1.192:8000):',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autocorrect: false,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: 'http://192.168.1.192:8000',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.restore, size: 18),
                    tooltip: 'Сбросить по умолчанию',
                    onPressed: () {
                      controller.text = ApiEndpoints.defaultBaseUrl;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (testResult != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: testResult!.startsWith('✓')
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    testResult!,
                    style: TextStyle(
                      fontSize: 12,
                      color: testResult!.startsWith('✓') ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: isTesting
                    ? null
                    : () async {
                        setDialogState(() {
                          isTesting = true;
                          testResult = null;
                        });
                        try {
                          final testDio = Dio(
                            BaseOptions(
                              connectTimeout: const Duration(seconds: 4),
                              receiveTimeout: const Duration(seconds: 4),
                            ),
                          );
                          final target = controller.text.trim().replaceAll(RegExp(r'/+$'), '');
                          final response = await testDio.get('$target/openapi.json');
                          if (response.statusCode == 200) {
                            setDialogState(() {
                              testResult = '✓ Сервер доступен и отвечает!';
                              isTesting = false;
                            });
                          } else {
                            setDialogState(() {
                              testResult = 'Ответ: ${response.statusCode}';
                              isTesting = false;
                            });
                          }
                        } catch (e) {
                          setDialogState(() {
                            testResult = '✗ Ошибка соединения: $e';
                            isTesting = false;
                          });
                        }
                      },
                icon: isTesting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_tethering, size: 16),
                label: const Text('Проверить доступность'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final newUrl = controller.text.trim();
                if (newUrl.isNotEmpty) {
                  ref.read(baseUrlProvider.notifier).setUrl(newUrl);
                }
                Navigator.of(dialogCtx).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentBaseUrl = ref.watch(baseUrlProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Header
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.home_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'HOUSEHOLD',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isRegister
                      ? (l10n?.authRegisterSubtitle ?? 'Создание семейного аккаунта')
                      : (l10n?.authLoginSubtitle ?? 'Добро пожаловать домой'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Error message
                if (_errorText != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Input fields
                if (_isRegister) ...[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: l10n?.authNamePlaceholder ?? 'Ваше имя',
                      prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _usernameController,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: l10n?.authUsernamePlaceholder ?? 'Логин',
                    prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: l10n?.authPasswordPlaceholder ?? 'Пароль',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _submit,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isRegister
                          ? (l10n?.authSignUpBtn ?? 'Зарегистрироваться')
                          : (l10n?.authSignInBtn ?? 'Войти')),
                ),
                const SizedBox(height: 12),

                // Mode switch
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegister = !_isRegister;
                      _errorText = null;
                    });
                  },
                  child: Text(
                    _isRegister
                        ? (l10n?.authHaveAccount ?? 'Уже есть аккаунт? Войти')
                        : (l10n?.authNoAccount ?? 'Нет аккаунта? Зарегистрироваться'),
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),

                const SizedBox(height: 16),

                // Server URL indicator and settings button
                InkWell(
                  onTap: () => _showServerSettingsDialog(context, currentBaseUrl),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.dns_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            currentBaseUrl,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.underline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
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
