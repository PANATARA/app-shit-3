import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Household'**
  String get appTitle;

  /// No description provided for @commonBack.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get commonSave;

  /// No description provided for @commonEdit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get commonEdit;

  /// No description provided for @commonCreate.
  ///
  /// In ru, this message translates to:
  /// **'Создать'**
  String get commonCreate;

  /// No description provided for @commonDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get commonDelete;

  /// No description provided for @commonLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка...'**
  String get commonLoading;

  /// No description provided for @commonConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get commonConfirm;

  /// No description provided for @commonDone.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get commonDone;

  /// No description provided for @commonClose.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get commonClose;

  /// No description provided for @commonSearch.
  ///
  /// In ru, this message translates to:
  /// **'Поиск...'**
  String get commonSearch;

  /// No description provided for @commonApply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get commonApply;

  /// No description provided for @commonRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get commonRetry;

  /// No description provided for @commonEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Ничего нет'**
  String get commonEmpty;

  /// No description provided for @commonError.
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка'**
  String get commonError;

  /// No description provided for @commonYou.
  ///
  /// In ru, this message translates to:
  /// **'ты'**
  String get commonYou;

  /// No description provided for @commonNone.
  ///
  /// In ru, this message translates to:
  /// **'Никому'**
  String get commonNone;

  /// No description provided for @commonXp.
  ///
  /// In ru, this message translates to:
  /// **'XP'**
  String get commonXp;

  /// No description provided for @dateToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get dateToday;

  /// No description provided for @dateTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Завтра'**
  String get dateTomorrow;

  /// No description provided for @dateDayAfterTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Послезавтра'**
  String get dateDayAfterTomorrow;

  /// No description provided for @dateYesterday.
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get dateYesterday;

  /// No description provided for @dateInDays.
  ///
  /// In ru, this message translates to:
  /// **'через {count} дн.'**
  String dateInDays(int count);

  /// No description provided for @dateDaysAgo.
  ///
  /// In ru, this message translates to:
  /// **'{count} дн. назад'**
  String dateDaysAgo(int count);

  /// No description provided for @navHome.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get navHome;

  /// No description provided for @navBoard.
  ///
  /// In ru, this message translates to:
  /// **'Доска'**
  String get navBoard;

  /// No description provided for @navMeals.
  ///
  /// In ru, this message translates to:
  /// **'Меню'**
  String get navMeals;

  /// No description provided for @navProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// No description provided for @authLoginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход в аккаунт'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите логин и пароль для входа'**
  String get authLoginSubtitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Создайте аккаунт для начала работы'**
  String get authRegisterSubtitle;

  /// No description provided for @authUsernameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Логин'**
  String get authUsernameLabel;

  /// No description provided for @authUsernamePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Введите ваш логин'**
  String get authUsernamePlaceholder;

  /// No description provided for @authPasswordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль (от 6 символов)'**
  String get authPasswordPlaceholder;

  /// No description provided for @authNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Ваше имя'**
  String get authNameLabel;

  /// No description provided for @authNamePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Как вас зовут? (например, Анна)'**
  String get authNamePlaceholder;

  /// No description provided for @authSignInBtn.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get authSignInBtn;

  /// No description provided for @authSignUpBtn.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get authSignUpBtn;

  /// No description provided for @authNoAccount.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта? Зарегистрироваться'**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт? Войти'**
  String get authHaveAccount;

  /// No description provided for @authFillRequired.
  ///
  /// In ru, this message translates to:
  /// **'Заполните логин и пароль'**
  String get authFillRequired;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен быть не менее 6 символов'**
  String get authPasswordTooShort;

  /// No description provided for @authServerSettings.
  ///
  /// In ru, this message translates to:
  /// **'Адрес сервера'**
  String get authServerSettings;

  /// No description provided for @authServerPrompt.
  ///
  /// In ru, this message translates to:
  /// **'Укажите URL бэкенда:'**
  String get authServerPrompt;

  /// No description provided for @authTestConnection.
  ///
  /// In ru, this message translates to:
  /// **'Проверить связь'**
  String get authTestConnection;

  /// No description provided for @authConnectionSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Связь успешна'**
  String get authConnectionSuccess;

  /// No description provided for @authConnectionFail.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка подключения'**
  String get authConnectionFail;

  /// No description provided for @onboardingFamilyCircle.
  ///
  /// In ru, this message translates to:
  /// **'Семейный круг'**
  String get onboardingFamilyCircle;

  /// No description provided for @onboardingChooseTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как начнём?'**
  String get onboardingChooseTitle;

  /// No description provided for @onboardingChooseSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Создайте новое семейное пространство или присоединитесь к уже существующему.'**
  String get onboardingChooseSubtitle;

  /// No description provided for @onboardingNewFamily.
  ///
  /// In ru, this message translates to:
  /// **'Новая семья'**
  String get onboardingNewFamily;

  /// No description provided for @onboardingCreateFamily.
  ///
  /// In ru, this message translates to:
  /// **'Создать семью'**
  String get onboardingCreateFamily;

  /// No description provided for @onboardingCreateFamilyDesc.
  ///
  /// In ru, this message translates to:
  /// **'Создайте пространство для семьи и пригласите близких.'**
  String get onboardingCreateFamilyDesc;

  /// No description provided for @onboardingStartCreating.
  ///
  /// In ru, this message translates to:
  /// **'Начать создание'**
  String get onboardingStartCreating;

  /// No description provided for @onboardingAlreadyHaveFamily.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть семья?'**
  String get onboardingAlreadyHaveFamily;

  /// No description provided for @onboardingJoinFamily.
  ///
  /// In ru, this message translates to:
  /// **'Присоединиться'**
  String get onboardingJoinFamily;

  /// No description provided for @onboardingJoinFamilyDesc.
  ///
  /// In ru, this message translates to:
  /// **'Войдите по коду-приглашению от администратора вашей семьи.'**
  String get onboardingJoinFamilyDesc;

  /// No description provided for @onboardingEnterCode.
  ///
  /// In ru, this message translates to:
  /// **'Ввести код'**
  String get onboardingEnterCode;

  /// No description provided for @onboardingStep1Of2.
  ///
  /// In ru, this message translates to:
  /// **'Шаг 1 из 2'**
  String get onboardingStep1Of2;

  /// No description provided for @onboardingStep2Of2.
  ///
  /// In ru, this message translates to:
  /// **'Шаг 2 из 2'**
  String get onboardingStep2Of2;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In ru, this message translates to:
  /// **'Название семьи'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Придумайте название для вашего семейного круга'**
  String get onboardingStep1Subtitle;

  /// No description provided for @onboardingFamilyNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название семьи'**
  String get onboardingFamilyNameLabel;

  /// No description provided for @onboardingFamilyPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Например: Семья Смирновых'**
  String get onboardingFamilyPlaceholder;

  /// No description provided for @onboardingFamilyNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Пожалуйста, введите название семьи'**
  String get onboardingFamilyNameRequired;

  /// No description provided for @onboardingSuggestions.
  ///
  /// In ru, this message translates to:
  /// **'Варианты:'**
  String get onboardingSuggestions;

  /// No description provided for @onboardingChooseAvatar.
  ///
  /// In ru, this message translates to:
  /// **'Иконка и цвет семьи'**
  String get onboardingChooseAvatar;

  /// No description provided for @onboardingCreateFamilyBtn.
  ///
  /// In ru, this message translates to:
  /// **'Создать семейный круг'**
  String get onboardingCreateFamilyBtn;

  /// No description provided for @onboardingCreatingFamily.
  ///
  /// In ru, this message translates to:
  /// **'Создаём семью...'**
  String get onboardingCreatingFamily;

  /// No description provided for @onboardingFamilyCreatedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Семья создана!'**
  String get onboardingFamilyCreatedTitle;

  /// No description provided for @onboardingAddInitialChoresTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте первые задачи'**
  String get onboardingAddInitialChoresTitle;

  /// No description provided for @onboardingAddInitialChoresSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Выберите типовые домашние дела, чтобы сразу начать пользоваться'**
  String get onboardingAddInitialChoresSubtitle;

  /// No description provided for @onboardingSelectedCount.
  ///
  /// In ru, this message translates to:
  /// **'Выбрано: {selected} из {total}'**
  String onboardingSelectedCount(int selected, int total);

  /// No description provided for @onboardingSelectAll.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать все'**
  String get onboardingSelectAll;

  /// No description provided for @onboardingDeselectAll.
  ///
  /// In ru, this message translates to:
  /// **'Снять все'**
  String get onboardingDeselectAll;

  /// No description provided for @onboardingAddSelectedChores.
  ///
  /// In ru, this message translates to:
  /// **'Добавить задачи ({count}) и войти'**
  String onboardingAddSelectedChores(int count);

  /// No description provided for @onboardingSkipChores.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить и войти'**
  String get onboardingSkipChores;

  /// No description provided for @onboardingJoinTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вступить в семью'**
  String get onboardingJoinTitle;

  /// No description provided for @onboardingJoinSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите 6-значный код приглашения вашей семьи'**
  String get onboardingJoinSubtitle;

  /// No description provided for @onboardingCodePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'ABC-123'**
  String get onboardingCodePlaceholder;

  /// No description provided for @onboardingPasteCode.
  ///
  /// In ru, this message translates to:
  /// **'Вставить'**
  String get onboardingPasteCode;

  /// No description provided for @onboardingJoinBtn.
  ///
  /// In ru, this message translates to:
  /// **'Присоединиться'**
  String get onboardingJoinBtn;

  /// No description provided for @onboardingJoining.
  ///
  /// In ru, this message translates to:
  /// **'Проверяем код...'**
  String get onboardingJoining;

  /// No description provided for @onboardingEnterFullCodeError.
  ///
  /// In ru, this message translates to:
  /// **'Введите полный 6-значный код (например, ABC-123)'**
  String get onboardingEnterFullCodeError;

  /// No description provided for @onboardingFamilyNotFoundError.
  ///
  /// In ru, this message translates to:
  /// **'Семья с таким кодом не найдена'**
  String get onboardingFamilyNotFoundError;

  /// No description provided for @onboardingJoinSuccessTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вы успешно вступили в семью!'**
  String get onboardingJoinSuccessTitle;

  /// No description provided for @onboardingEnterFamily.
  ///
  /// In ru, this message translates to:
  /// **'Войти в семейный круг'**
  String get onboardingEnterFamily;

  /// No description provided for @onboardingLogout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта'**
  String get onboardingLogout;

  /// No description provided for @statsGreetingMorning.
  ///
  /// In ru, this message translates to:
  /// **'Доброе утро'**
  String get statsGreetingMorning;

  /// No description provided for @statsGreetingDay.
  ///
  /// In ru, this message translates to:
  /// **'Добрый день'**
  String get statsGreetingDay;

  /// No description provided for @statsGreetingEvening.
  ///
  /// In ru, this message translates to:
  /// **'Добрый вечер'**
  String get statsGreetingEvening;

  /// No description provided for @statsGreetingNight.
  ///
  /// In ru, this message translates to:
  /// **'Доброй ночи'**
  String get statsGreetingNight;

  /// No description provided for @statsTotalCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Всего выполнено'**
  String get statsTotalCompleted;

  /// No description provided for @statsThisWeek.
  ///
  /// In ru, this message translates to:
  /// **'На этой неделе'**
  String get statsThisWeek;

  /// No description provided for @statsTodayMeals.
  ///
  /// In ru, this message translates to:
  /// **'ПЛАН ПИТАНИЯ НА СЕГОДНЯ'**
  String get statsTodayMeals;

  /// No description provided for @statsAllMenu.
  ///
  /// In ru, this message translates to:
  /// **'Всё меню'**
  String get statsAllMenu;

  /// No description provided for @statsTodayGrocery.
  ///
  /// In ru, this message translates to:
  /// **'СПИСОК ПОКУПОК'**
  String get statsTodayGrocery;

  /// No description provided for @statsGroceryAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get statsGroceryAdd;

  /// No description provided for @statsGroceryEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Список покупок пуст'**
  String get statsGroceryEmpty;

  /// No description provided for @statsGroceryEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите «Добавить», чтобы составить список продуктов'**
  String get statsGroceryEmptyHint;

  /// No description provided for @statsMoreGroceries.
  ///
  /// In ru, this message translates to:
  /// **'И ещё {count} {count, plural, one{покупка} few{покупки} other{покупок}}'**
  String statsMoreGroceries(int count);

  /// No description provided for @statsUpcomingEvents.
  ///
  /// In ru, this message translates to:
  /// **'БЛИЖАЙШИЕ СОБЫТИЯ'**
  String get statsUpcomingEvents;

  /// No description provided for @statsAllEvents.
  ///
  /// In ru, this message translates to:
  /// **'Все события'**
  String get statsAllEvents;

  /// No description provided for @statsAddEvent.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get statsAddEvent;

  /// No description provided for @statsNoEvents.
  ///
  /// In ru, this message translates to:
  /// **'Событий пока нет'**
  String get statsNoEvents;

  /// No description provided for @statsNoEventsHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите «Добавить», чтобы запланировать праздник или поездку'**
  String get statsNoEventsHint;

  /// No description provided for @statsMoreEvents.
  ///
  /// In ru, this message translates to:
  /// **'И ещё {count} {count, plural, one{событие} few{события} other{событий}}'**
  String statsMoreEvents(int count);

  /// No description provided for @statsWeeklyLeaders.
  ///
  /// In ru, this message translates to:
  /// **'ЛИДЕРЫ НЕДЕЛИ'**
  String get statsWeeklyLeaders;

  /// No description provided for @statsTasksCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} задача} few{{count} задачи} other{{count} задач}}'**
  String statsTasksCount(int count);

  /// No description provided for @eventsAllTitle.
  ///
  /// In ru, this message translates to:
  /// **'Все события'**
  String get eventsAllTitle;

  /// No description provided for @eventsCreateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новое событие'**
  String get eventsCreateTitle;

  /// No description provided for @eventsDeleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить событие?'**
  String get eventsDeleteTitle;

  /// No description provided for @eventsDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить это событие?'**
  String get eventsDeleteConfirm;

  /// No description provided for @eventsDeleteConfirmDesc.
  ///
  /// In ru, this message translates to:
  /// **'Это действие нельзя отменить.'**
  String get eventsDeleteConfirmDesc;

  /// No description provided for @eventsWhen.
  ///
  /// In ru, this message translates to:
  /// **'Когда'**
  String get eventsWhen;

  /// No description provided for @eventsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get eventsDescription;

  /// No description provided for @eventsDescriptionOptional.
  ///
  /// In ru, this message translates to:
  /// **'ОПИСАНИЕ (НЕОБЯЗАТЕЛЬНО)'**
  String get eventsDescriptionOptional;

  /// No description provided for @eventsRescheduleDate.
  ///
  /// In ru, this message translates to:
  /// **'Перенести дату'**
  String get eventsRescheduleDate;

  /// No description provided for @eventsNewDate.
  ///
  /// In ru, this message translates to:
  /// **'Новая дата'**
  String get eventsNewDate;

  /// No description provided for @eventsNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'НАЗВАНИЕ'**
  String get eventsNameLabel;

  /// No description provided for @eventsDateLabel.
  ///
  /// In ru, this message translates to:
  /// **'ДАТА'**
  String get eventsDateLabel;

  /// No description provided for @eventsNamePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Поездка, день рождения, праздник...'**
  String get eventsNamePlaceholder;

  /// No description provided for @eventsDescPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Дополнительные детали или заметки...'**
  String get eventsDescPlaceholder;

  /// No description provided for @eventsEnterNameError.
  ///
  /// In ru, this message translates to:
  /// **'Введите название события'**
  String get eventsEnterNameError;

  /// No description provided for @eventsCreateError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось создать событие: {error}'**
  String eventsCreateError(String error);

  /// No description provided for @eventsDeleteBtn.
  ///
  /// In ru, this message translates to:
  /// **'Удалить событие'**
  String get eventsDeleteBtn;

  /// No description provided for @slotBreakfast.
  ///
  /// In ru, this message translates to:
  /// **'Завтрак'**
  String get slotBreakfast;

  /// No description provided for @slotLunch.
  ///
  /// In ru, this message translates to:
  /// **'Обед'**
  String get slotLunch;

  /// No description provided for @slotDinner.
  ///
  /// In ru, this message translates to:
  /// **'Ужин'**
  String get slotDinner;

  /// No description provided for @slotSnack.
  ///
  /// In ru, this message translates to:
  /// **'Перекус'**
  String get slotSnack;

  /// No description provided for @boardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Доска'**
  String get boardTitle;

  /// No description provided for @boardSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Расписание и задачи семьи'**
  String get boardSubtitle;

  /// No description provided for @boardPlanChore.
  ///
  /// In ru, this message translates to:
  /// **'Запланировать'**
  String get boardPlanChore;

  /// No description provided for @boardNoChores.
  ///
  /// In ru, this message translates to:
  /// **'Нет задач на этот день'**
  String get boardNoChores;

  /// No description provided for @boardNoChoresHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите кнопку ниже, чтобы запланировать задачу'**
  String get boardNoChoresHint;

  /// No description provided for @boardFilterAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get boardFilterAll;

  /// No description provided for @boardFilterMine.
  ///
  /// In ru, this message translates to:
  /// **'Мои'**
  String get boardFilterMine;

  /// No description provided for @boardFilterDone.
  ///
  /// In ru, this message translates to:
  /// **'Выполненные'**
  String get boardFilterDone;

  /// No description provided for @boardFilterPending.
  ///
  /// In ru, this message translates to:
  /// **'В процессе'**
  String get boardFilterPending;

  /// No description provided for @chorePlanTitle.
  ///
  /// In ru, this message translates to:
  /// **'Запланировать задачу'**
  String get chorePlanTitle;

  /// No description provided for @choreQuickTask.
  ///
  /// In ru, this message translates to:
  /// **'Быстрая задача'**
  String get choreQuickTask;

  /// No description provided for @choreOrFromTemplates.
  ///
  /// In ru, this message translates to:
  /// **'или выберите из шаблонов'**
  String get choreOrFromTemplates;

  /// No description provided for @choreCreateCustom.
  ///
  /// In ru, this message translates to:
  /// **'Создать «{name}»'**
  String choreCreateCustom(String name);

  /// No description provided for @choreNothingFound.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get choreNothingFound;

  /// No description provided for @choreSectionName.
  ///
  /// In ru, this message translates to:
  /// **'НАЗВАНИЕ'**
  String get choreSectionName;

  /// No description provided for @choreSectionAssignee.
  ///
  /// In ru, this message translates to:
  /// **'КОМУ НАЗНАЧИТЬ'**
  String get choreSectionAssignee;

  /// No description provided for @choreSectionDetails.
  ///
  /// In ru, this message translates to:
  /// **'ДЕТАЛИ'**
  String get choreSectionDetails;

  /// No description provided for @choreSectionRepeat.
  ///
  /// In ru, this message translates to:
  /// **'ПОВТОРЕНИЕ'**
  String get choreSectionRepeat;

  /// No description provided for @choreNamePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Что нужно сделать?'**
  String get choreNamePlaceholder;

  /// No description provided for @choreNotePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Добавить заметку или чек-лист...'**
  String get choreNotePlaceholder;

  /// No description provided for @choreDateLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get choreDateLabel;

  /// No description provided for @choreAssignedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Назначено'**
  String get choreAssignedLabel;

  /// No description provided for @choreCompletedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено'**
  String get choreCompletedLabel;

  /// No description provided for @choreNotDoneYet.
  ///
  /// In ru, this message translates to:
  /// **'Ещё нет'**
  String get choreNotDoneYet;

  /// No description provided for @choreUnassigned.
  ///
  /// In ru, this message translates to:
  /// **'Никто'**
  String get choreUnassigned;

  /// No description provided for @choreSubtasksNotes.
  ///
  /// In ru, this message translates to:
  /// **'Подзадачи и заметки'**
  String get choreSubtasksNotes;

  /// No description provided for @choreSubtasksHint.
  ///
  /// In ru, this message translates to:
  /// **'Чек-лист: - [ ] пункт\nЗаметка: просто текст'**
  String get choreSubtasksHint;

  /// No description provided for @choreSubtasksEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет заметок. Нажмите «Изменить» чтобы добавить чек-лист или комментарий.'**
  String get choreSubtasksEmpty;

  /// No description provided for @choreMarkCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Отметить выполненным'**
  String get choreMarkCompleted;

  /// No description provided for @choreCancelCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Отменить выполнение'**
  String get choreCancelCompleted;

  /// No description provided for @choreRescheduleTo.
  ///
  /// In ru, this message translates to:
  /// **'Перенести на {date}'**
  String choreRescheduleTo(String date);

  /// No description provided for @choreDeleteTask.
  ///
  /// In ru, this message translates to:
  /// **'Удалить задачу'**
  String get choreDeleteTask;

  /// No description provided for @choreConfirmDeleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить задачу?'**
  String get choreConfirmDeleteTitle;

  /// No description provided for @choreConfirmDeleteDesc.
  ///
  /// In ru, this message translates to:
  /// **'Это действие нельзя отменить.'**
  String get choreConfirmDeleteDesc;

  /// No description provided for @choreRepeatSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки повторения'**
  String get choreRepeatSettings;

  /// No description provided for @choreDeleteRecurringTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удаление регулярной задачи'**
  String get choreDeleteRecurringTitle;

  /// No description provided for @choreDeleteRecurringDesc.
  ///
  /// In ru, this message translates to:
  /// **'Эта задача повторяется по расписанию. Что вы хотите удалить?'**
  String get choreDeleteRecurringDesc;

  /// No description provided for @choreDeleteOnlyThis.
  ///
  /// In ru, this message translates to:
  /// **'Только эту задачу'**
  String get choreDeleteOnlyThis;

  /// No description provided for @choreDeleteAllFuture.
  ///
  /// In ru, this message translates to:
  /// **'Эту и все будущие задачи'**
  String get choreDeleteAllFuture;

  /// No description provided for @choreEditScheduleTitle.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать расписание'**
  String get choreEditScheduleTitle;

  /// No description provided for @choreScheduleUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Расписание обновлено'**
  String get choreScheduleUpdated;

  /// No description provided for @choreScheduleDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Расписание удалено'**
  String get choreScheduleDeleted;

  /// No description provided for @mealsTitle.
  ///
  /// In ru, this message translates to:
  /// **'План питания'**
  String get mealsTitle;

  /// No description provided for @mealsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Планируйте меню и продукты для всей семьи'**
  String get mealsSubtitle;

  /// No description provided for @mealsTabPlanner.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get mealsTabPlanner;

  /// No description provided for @mealsTabRecipes.
  ///
  /// In ru, this message translates to:
  /// **'Книга рецептов'**
  String get mealsTabRecipes;

  /// No description provided for @mealsTabGroceries.
  ///
  /// In ru, this message translates to:
  /// **'Список покупок'**
  String get mealsTabGroceries;

  /// No description provided for @mealsAddDish.
  ///
  /// In ru, this message translates to:
  /// **'Добавить блюдо'**
  String get mealsAddDish;

  /// No description provided for @mealsAddRecipe.
  ///
  /// In ru, this message translates to:
  /// **'Свой рецепт'**
  String get mealsAddRecipe;

  /// No description provided for @mealsSearchRecipes.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по рецептам...'**
  String get mealsSearchRecipes;

  /// No description provided for @mealsPrepTime.
  ///
  /// In ru, this message translates to:
  /// **'{minutes} мин'**
  String mealsPrepTime(int minutes);

  /// No description provided for @mealsServings.
  ///
  /// In ru, this message translates to:
  /// **'{servings, plural, one{{servings} порция} few{{servings} порции} other{{servings} порций}}'**
  String mealsServings(int servings);

  /// No description provided for @mealsClearBought.
  ///
  /// In ru, this message translates to:
  /// **'Очистить купленные'**
  String get mealsClearBought;

  /// No description provided for @mealsAddProduct.
  ///
  /// In ru, this message translates to:
  /// **'Добавить продукт'**
  String get mealsAddProduct;

  /// No description provided for @groceryRemainingToBuy.
  ///
  /// In ru, this message translates to:
  /// **'Осталось купить: '**
  String get groceryRemainingToBuy;

  /// No description provided for @groceryPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Что нужно купить?...'**
  String get groceryPlaceholder;

  /// No description provided for @mealsSectionTime.
  ///
  /// In ru, this message translates to:
  /// **'ВРЕМЯ (МИН)'**
  String get mealsSectionTime;

  /// No description provided for @mealsSectionServings.
  ///
  /// In ru, this message translates to:
  /// **'ПОРЦИИ'**
  String get mealsSectionServings;

  /// No description provided for @mealsSectionCook.
  ///
  /// In ru, this message translates to:
  /// **'КТО ГОТОВИТ?'**
  String get mealsSectionCook;

  /// No description provided for @mealsSectionDishName.
  ///
  /// In ru, this message translates to:
  /// **'НАЗВАНИЕ БЛЮДА'**
  String get mealsSectionDishName;

  /// No description provided for @mealsSectionChooseRecipe.
  ///
  /// In ru, this message translates to:
  /// **'ВЫБЕРИТЕ РЕЦЕПТ'**
  String get mealsSectionChooseRecipe;

  /// No description provided for @mealsSectionMealSlot.
  ///
  /// In ru, this message translates to:
  /// **'ПРИЕМ ПИЩИ'**
  String get mealsSectionMealSlot;

  /// No description provided for @mealsTabRecipe.
  ///
  /// In ru, this message translates to:
  /// **'Из рецептов'**
  String get mealsTabRecipe;

  /// No description provided for @mealsTabManual.
  ///
  /// In ru, this message translates to:
  /// **'Быстрая запись'**
  String get mealsTabManual;

  /// No description provided for @mealsAddToMenu.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в меню'**
  String get mealsAddToMenu;

  /// No description provided for @mealsDishPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Название блюда, например: Борщ'**
  String get mealsDishPlaceholder;

  /// No description provided for @mealsCookTimeFormat.
  ///
  /// In ru, this message translates to:
  /// **'Время приготовления: {minutes} мин'**
  String mealsCookTimeFormat(int minutes);

  /// No description provided for @mealsNoMealsPlanned.
  ///
  /// In ru, this message translates to:
  /// **'Меню не запланировано'**
  String get mealsNoMealsPlanned;

  /// No description provided for @mealsPlannedCount.
  ///
  /// In ru, this message translates to:
  /// **'Запланировано блюд: {count}'**
  String mealsPlannedCount(int count);

  /// No description provided for @mealsRecipeBookEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Книга рецептов пуста'**
  String get mealsRecipeBookEmpty;

  /// No description provided for @mealsRecipeBookEmptyDesc.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте любимые семейные блюда, чтобы планировать меню в один клик'**
  String get mealsRecipeBookEmptyDesc;

  /// No description provided for @mealsAddFirstRecipe.
  ///
  /// In ru, this message translates to:
  /// **'Добавить первый рецепт'**
  String get mealsAddFirstRecipe;

  /// No description provided for @mealsFilterAll.
  ///
  /// In ru, this message translates to:
  /// **'Все блюда'**
  String get mealsFilterAll;

  /// No description provided for @mealsFilterQuick.
  ///
  /// In ru, this message translates to:
  /// **'Быстрые'**
  String get mealsFilterQuick;

  /// No description provided for @mealsFilterFavorites.
  ///
  /// In ru, this message translates to:
  /// **'Избранное'**
  String get mealsFilterFavorites;

  /// No description provided for @mealsFilterKids.
  ///
  /// In ru, this message translates to:
  /// **'Детям'**
  String get mealsFilterKids;

  /// No description provided for @mealsFilterDinner.
  ///
  /// In ru, this message translates to:
  /// **'Ужин'**
  String get mealsFilterDinner;

  /// No description provided for @mealsFilterDesserts.
  ///
  /// In ru, this message translates to:
  /// **'Десерты'**
  String get mealsFilterDesserts;

  /// No description provided for @mealsInMenu.
  ///
  /// In ru, this message translates to:
  /// **'В меню'**
  String get mealsInMenu;

  /// No description provided for @mealsSearchPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Поиск блюда или ингредиента...'**
  String get mealsSearchPlaceholder;

  /// No description provided for @mealsTryChangeSearch.
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте изменить запрос или сбросить фильтры'**
  String get mealsTryChangeSearch;

  /// No description provided for @mealsScheduleWeekly.
  ///
  /// In ru, this message translates to:
  /// **'Запланировать в меню недели'**
  String get mealsScheduleWeekly;

  /// No description provided for @mealsDayOfWeek.
  ///
  /// In ru, this message translates to:
  /// **'ДЕНЬ НЕДЕЛИ'**
  String get mealsDayOfWeek;

  /// No description provided for @mealsServingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Порции'**
  String get mealsServingsTitle;

  /// No description provided for @mealsIngredientsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ингредиенты'**
  String get mealsIngredientsTitle;

  /// No description provided for @mealsToList.
  ///
  /// In ru, this message translates to:
  /// **'В список'**
  String get mealsToList;

  /// No description provided for @mealsAddMissingToGroceries.
  ///
  /// In ru, this message translates to:
  /// **'Добавить недостающее в список покупок'**
  String get mealsAddMissingToGroceries;

  /// No description provided for @mealsInstructionsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Приготовление'**
  String get mealsInstructionsTitle;

  /// No description provided for @mealsTapToPlan.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите, чтобы запланировать {slot}'**
  String mealsTapToPlan(String slot);

  /// No description provided for @mealsRecipeBadge.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт'**
  String get mealsRecipeBadge;

  /// No description provided for @mealsDishAddedToast.
  ///
  /// In ru, this message translates to:
  /// **'Блюдо добавлено в меню'**
  String get mealsDishAddedToast;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профиль и семья'**
  String get settingsTitle;

  /// No description provided for @settingsProfileSection.
  ///
  /// In ru, this message translates to:
  /// **'МОЙ АККАУНТ'**
  String get settingsProfileSection;

  /// No description provided for @settingsEditProfile.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать профиль'**
  String get settingsEditProfile;

  /// No description provided for @settingsFamilySection.
  ///
  /// In ru, this message translates to:
  /// **'СЕМЕЙНЫЙ КРУГ'**
  String get settingsFamilySection;

  /// No description provided for @settingsFamilyMembers.
  ///
  /// In ru, this message translates to:
  /// **'Участники семьи'**
  String get settingsFamilyMembers;

  /// No description provided for @settingsInviteCode.
  ///
  /// In ru, this message translates to:
  /// **'Код приглашения'**
  String get settingsInviteCode;

  /// No description provided for @settingsCopyCode.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать'**
  String get settingsCopyCode;

  /// No description provided for @settingsCodeCopied.
  ///
  /// In ru, this message translates to:
  /// **'Код скопирован в буфер обмена'**
  String get settingsCodeCopied;

  /// No description provided for @settingsAdminBadge.
  ///
  /// In ru, this message translates to:
  /// **'Админ'**
  String get settingsAdminBadge;

  /// No description provided for @settingsChangeAdmin.
  ///
  /// In ru, this message translates to:
  /// **'Сделать админом'**
  String get settingsChangeAdmin;

  /// No description provided for @settingsKickMember.
  ///
  /// In ru, this message translates to:
  /// **'Удалить из семьи'**
  String get settingsKickMember;

  /// No description provided for @settingsLeaveFamily.
  ///
  /// In ru, this message translates to:
  /// **'Покинуть семью'**
  String get settingsLeaveFamily;

  /// No description provided for @settingsConfirmLeaveFamily.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите выйти из семьи?'**
  String get settingsConfirmLeaveFamily;

  /// No description provided for @settingsAppearanceSection.
  ///
  /// In ru, this message translates to:
  /// **'ИНТЕРФЕЙС И ОФОРМЛЕНИЕ'**
  String get settingsAppearanceSection;

  /// No description provided for @settingsTheme.
  ///
  /// In ru, this message translates to:
  /// **'Тема оформления'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Системная'**
  String get settingsThemeSystem;

  /// No description provided for @settingsLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык приложения'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageRu.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get settingsLanguageRu;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsTimezone.
  ///
  /// In ru, this message translates to:
  /// **'Часовой пояс'**
  String get settingsTimezone;

  /// No description provided for @settingsTimezoneAuto.
  ///
  /// In ru, this message translates to:
  /// **'Определен автоматически'**
  String get settingsTimezoneAuto;

  /// No description provided for @settingsServerSection.
  ///
  /// In ru, this message translates to:
  /// **'ПОДКЛЮЧЕНИЕ'**
  String get settingsServerSection;

  /// No description provided for @settingsServerUrl.
  ///
  /// In ru, this message translates to:
  /// **'Адрес сервера'**
  String get settingsServerUrl;

  /// No description provided for @settingsLogout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта'**
  String get settingsLogout;

  /// No description provided for @settingsConfirmLogout.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите выйти из аккаунта?'**
  String get settingsConfirmLogout;

  /// No description provided for @settingsInviteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пригласить участника'**
  String get settingsInviteTitle;

  /// No description provided for @settingsInviteDesc.
  ///
  /// In ru, this message translates to:
  /// **'Отправьте этот код человеку, которого хотите пригласить в семью. Код действует ограниченное время.'**
  String get settingsInviteDesc;

  /// No description provided for @settingsInviteTapToCopy.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите, чтобы скопировать'**
  String get settingsInviteTapToCopy;

  /// No description provided for @settingsInviteCopied.
  ///
  /// In ru, this message translates to:
  /// **'✓ Код скопирован'**
  String get settingsInviteCopied;

  /// No description provided for @settingsInviteExpiresIn.
  ///
  /// In ru, this message translates to:
  /// **'Код истекает через {time}'**
  String settingsInviteExpiresIn(String time);

  /// No description provided for @settingsKickConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Исключить из семьи?'**
  String get settingsKickConfirmTitle;

  /// No description provided for @settingsKickConfirmContent.
  ///
  /// In ru, this message translates to:
  /// **'Вы действительно хотите исключить {name} из семьи?'**
  String settingsKickConfirmContent(String name);

  /// No description provided for @settingsTransferAdminTitle.
  ///
  /// In ru, this message translates to:
  /// **'Передать права администратора?'**
  String get settingsTransferAdminTitle;

  /// No description provided for @settingsTransferAdminContent.
  ///
  /// In ru, this message translates to:
  /// **'Сделать {name} администратором семьи?'**
  String settingsTransferAdminContent(String name);

  /// No description provided for @settingsThemeSelectTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выбор темы оформления'**
  String get settingsThemeSelectTitle;

  /// No description provided for @settingsLangSelectTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выбор языка'**
  String get settingsLangSelectTitle;

  /// No description provided for @settingsLangSelectSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Выберите удобный язык для работы с приложением'**
  String get settingsLangSelectSubtitle;

  /// No description provided for @settingsTransferAdminBtn.
  ///
  /// In ru, this message translates to:
  /// **'Сделать администратором'**
  String get settingsTransferAdminBtn;

  /// No description provided for @settingsKickMemberBtn.
  ///
  /// In ru, this message translates to:
  /// **'Исключить из семьи'**
  String get settingsKickMemberBtn;

  /// No description provided for @settingsTransferAdminAction.
  ///
  /// In ru, this message translates to:
  /// **'Передать'**
  String get settingsTransferAdminAction;

  /// No description provided for @settingsKickAction.
  ///
  /// In ru, this message translates to:
  /// **'Исключить'**
  String get settingsKickAction;

  /// No description provided for @settingsFailedToGetCode.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить код'**
  String get settingsFailedToGetCode;

  /// No description provided for @settingsChoresSection.
  ///
  /// In ru, this message translates to:
  /// **'ОБЯЗАННОСТИ'**
  String get settingsChoresSection;

  /// No description provided for @settingsManageChores.
  ///
  /// In ru, this message translates to:
  /// **'Управление обязанностями'**
  String get settingsManageChores;

  /// No description provided for @settingsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Семья, профиль и настройки'**
  String get settingsSubtitle;

  /// No description provided for @themeWarmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тёплая'**
  String get themeWarmTitle;

  /// No description provided for @themeWarmName.
  ///
  /// In ru, this message translates to:
  /// **'Тёплый семейный уют'**
  String get themeWarmName;

  /// No description provided for @themeWarmDesc.
  ///
  /// In ru, this message translates to:
  /// **'Светлая, тёплая и домашняя атмосфера'**
  String get themeWarmDesc;

  /// No description provided for @themeSoftTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нежность'**
  String get themeSoftTitle;

  /// No description provided for @themeSoftName.
  ///
  /// In ru, this message translates to:
  /// **'Нежность и забота'**
  String get themeSoftName;

  /// No description provided for @themeSoftDesc.
  ///
  /// In ru, this message translates to:
  /// **'Пастельные пудровые оттенки и гармония'**
  String get themeSoftDesc;

  /// No description provided for @themeNightTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вечер'**
  String get themeNightTitle;

  /// No description provided for @themeNightName.
  ///
  /// In ru, this message translates to:
  /// **'Уютный вечер дома'**
  String get themeNightName;

  /// No description provided for @themeNightDesc.
  ///
  /// In ru, this message translates to:
  /// **'Мягкая тёмная тема для вечернего комфорта'**
  String get themeNightDesc;

  /// No description provided for @themeRoyalTitle.
  ///
  /// In ru, this message translates to:
  /// **'Свежесть'**
  String get themeRoyalTitle;

  /// No description provided for @themeRoyalName.
  ///
  /// In ru, this message translates to:
  /// **'Свежесть и гармония'**
  String get themeRoyalName;

  /// No description provided for @themeRoyalDesc.
  ///
  /// In ru, this message translates to:
  /// **'Чистая прохладная лазурная гамма'**
  String get themeRoyalDesc;

  /// No description provided for @themeSageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Лесной'**
  String get themeSageTitle;

  /// No description provided for @themeSageName.
  ///
  /// In ru, this message translates to:
  /// **'Лесной оазис'**
  String get themeSageName;

  /// No description provided for @themeSageDesc.
  ///
  /// In ru, this message translates to:
  /// **'Успокаивающие шалфейные и травяные тона'**
  String get themeSageDesc;

  /// No description provided for @themeMidnightTitle.
  ///
  /// In ru, this message translates to:
  /// **'Северный'**
  String get themeMidnightTitle;

  /// No description provided for @themeMidnightName.
  ///
  /// In ru, this message translates to:
  /// **'Северное сияние'**
  String get themeMidnightName;

  /// No description provided for @themeMidnightDesc.
  ///
  /// In ru, this message translates to:
  /// **'Глубокая ночная гамма с акцентом индиго'**
  String get themeMidnightDesc;

  /// No description provided for @themeAmberTitle.
  ///
  /// In ru, this message translates to:
  /// **'Медовый'**
  String get themeAmberTitle;

  /// No description provided for @themeAmberName.
  ///
  /// In ru, this message translates to:
  /// **'Медовый полдень'**
  String get themeAmberName;

  /// No description provided for @themeAmberDesc.
  ///
  /// In ru, this message translates to:
  /// **'Солнечная золотисто-янтарная гамма и тепло'**
  String get themeAmberDesc;

  /// No description provided for @settingsVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get settingsVersion;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
