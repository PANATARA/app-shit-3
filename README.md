# 📱 HOUSEHOLD — Flutter Client

Нативный мобильный клиент для семейного органайзера **HOUSEHOLD** на базе Flutter & Dart.

---

## 🏗 Архитектура проекта

Проект организован по принципам **Feature-First** модульной архитектуры:

```
lib/
├── core/                           # Общесистемные модули
│   ├── api/                        # Сетевой клиент Dio, перехватчики и авто-рефреш JWT
│   │   ├── api_client.dart
│   │   ├── api_endpoints.dart
│   │   └── auth_interceptor.dart
│   ├── constants/                  # Константы и URL эндпоинты
│   ├── routing/                    # Декларативная маршрутизация GoRouter
│   │   └── app_router.dart
│   ├── storage/                    # Безопасное хранилище токенов (flutter_secure_storage)
│   │   └── token_storage.dart
│   └── theme/                      # Цветовые токены HOUSEHOLD, типографика Inter
│       ├── app_colors.dart
│       └── app_theme.dart
├── features/                       # Бизнес-фичи приложения
│   ├── auth/                       # Авторизация, регистрация, профиль
│   │   ├── models/user_model.dart
│   │   ├── providers/auth_provider.dart
│   │   ├── repositories/auth_repository.dart
│   │   └── screens/auth_screen.dart
│   ├── chores/                     # Обязанности, задачи, расписания
│   │   └── screens/board_screen.dart
│   ├── stats/                      # Статистика, лидерборды
│   │   └── screens/stats_screen.dart
│   ├── meals/                      # План питания, книга рецептов
│   │   └── screens/meals_screen.dart
│   └── settings/                   # Настройки, семья, смена URL бэкенда
│       └── screens/settings_screen.dart
├── widgets/                        # Переиспользуемые UI компоненты
│   └── app_scaffold.dart           # Нативная нижняя навигационная панель
└── main.dart                       # Точка входа, ProviderScope
```

---

## 🚀 Используемые технологии

- **Flutter 3.44+ & Dart 3.12+**
- **State Management**: `flutter_riverpod 3.x`
- **Networking**: `dio 5.x` (с `QueuedInterceptor` для фонового автообновления access-токена при 401)
- **Navigation**: `go_router` (с поддержкой `StatefulShellRoute.indexedStack` для сохранения состояния вкладок)
- **Security & Storage**: `flutter_secure_storage` (Android Keystore / EncryptedSharedPreferences)
- **Typography & UI**: `google_fonts` (Inter), Material 3, адаптивные цвета Warm / Sunset

---

## ⚙️ Запуск и разработка

```bash
# 1. Перейти в директорию
cd HH-FLUTTER

# 2. Получить зависимости
flutter pub get

# 3. Запустить приложение (на подключенном устройстве или эмуляторе)
flutter run

# Сборка debug APK:
flutter build apk --debug
```

По умолчанию приложение настроено на бэкенд: `http://192.168.1.192:8000`.  
Его можно изменить как при сборке через `--dart-define=API_URL=http://...`, так и прямо в приложении на экране **Настройки** -> **Сервер бэкенда**.


так, ты мне раньше переносил мое svelte приложение на flutter. Сейчас тебе нужно будет продолжить, нужно перенести экран Питания c моего svelte приложения на flutter. Перенести все
  функции до одной, и также запросы к бекенду, всё должно быть максимально похоже на оригинал на svelte. и в конце
