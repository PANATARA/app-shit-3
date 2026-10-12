// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Household';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonCreate => 'Создать';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonLoading => 'Загрузка...';

  @override
  String get commonConfirm => 'Подтвердить';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonSearch => 'Поиск...';

  @override
  String get commonApply => 'Применить';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonEmpty => 'Ничего нет';

  @override
  String get commonError => 'Произошла ошибка';

  @override
  String get commonYou => 'ты';

  @override
  String get commonNone => 'Никому';

  @override
  String get commonXp => 'XP';

  @override
  String get dateToday => 'Сегодня';

  @override
  String get dateTomorrow => 'Завтра';

  @override
  String get dateDayAfterTomorrow => 'Послезавтра';

  @override
  String get dateYesterday => 'Вчера';

  @override
  String dateInDays(int count) {
    return 'через $count дн.';
  }

  @override
  String dateDaysAgo(int count) {
    return '$count дн. назад';
  }

  @override
  String get navHome => 'Главная';

  @override
  String get navBoard => 'Доска';

  @override
  String get navMeals => 'Меню';

  @override
  String get navProfile => 'Профиль';

  @override
  String get authLoginTitle => 'Вход в аккаунт';

  @override
  String get authLoginSubtitle => 'Введите логин и пароль для входа';

  @override
  String get authRegisterTitle => 'Регистрация';

  @override
  String get authRegisterSubtitle => 'Создайте аккаунт для начала работы';

  @override
  String get authUsernameLabel => 'Логин';

  @override
  String get authUsernamePlaceholder => 'Введите ваш логин';

  @override
  String get authPasswordLabel => 'Пароль';

  @override
  String get authPasswordPlaceholder => 'Введите пароль (от 6 символов)';

  @override
  String get authNameLabel => 'Ваше имя';

  @override
  String get authNamePlaceholder => 'Как вас зовут? (например, Анна)';

  @override
  String get authSignInBtn => 'Войти';

  @override
  String get authSignUpBtn => 'Зарегистрироваться';

  @override
  String get authNoAccount => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get authHaveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get authFillRequired => 'Заполните логин и пароль';

  @override
  String get authPasswordTooShort => 'Пароль должен быть не менее 6 символов';

  @override
  String get authServerSettings => 'Адрес сервера';

  @override
  String get authServerPrompt => 'Укажите URL бэкенда:';

  @override
  String get authTestConnection => 'Проверить связь';

  @override
  String get authConnectionSuccess => 'Связь успешна';

  @override
  String get authConnectionFail => 'Ошибка подключения';

  @override
  String get onboardingFamilyCircle => 'Семейный круг';

  @override
  String get onboardingChooseTitle => 'Как начнём?';

  @override
  String get onboardingChooseSubtitle =>
      'Создайте новое семейное пространство или присоединитесь к уже существующему.';

  @override
  String get onboardingNewFamily => 'Новая семья';

  @override
  String get onboardingCreateFamily => 'Создать семью';

  @override
  String get onboardingCreateFamilyDesc =>
      'Создайте пространство для семьи и пригласите близких.';

  @override
  String get onboardingStartCreating => 'Начать создание';

  @override
  String get onboardingAlreadyHaveFamily => 'Уже есть семья?';

  @override
  String get onboardingJoinFamily => 'Присоединиться';

  @override
  String get onboardingJoinFamilyDesc =>
      'Войдите по коду-приглашению от администратора вашей семьи.';

  @override
  String get onboardingEnterCode => 'Ввести код';

  @override
  String get onboardingStep1Of2 => 'Шаг 1 из 2';

  @override
  String get onboardingStep2Of2 => 'Шаг 2 из 2';

  @override
  String get onboardingStep1Title => 'Название семьи';

  @override
  String get onboardingStep1Subtitle =>
      'Придумайте название для вашего семейного круга';

  @override
  String get onboardingFamilyNameLabel => 'Название семьи';

  @override
  String get onboardingFamilyPlaceholder => 'Например: Семья Смирновых';

  @override
  String get onboardingFamilyNameRequired =>
      'Пожалуйста, введите название семьи';

  @override
  String get onboardingSuggestions => 'Варианты:';

  @override
  String get onboardingChooseAvatar => 'Иконка и цвет семьи';

  @override
  String get onboardingCreateFamilyBtn => 'Создать семейный круг';

  @override
  String get onboardingCreatingFamily => 'Создаём семью...';

  @override
  String get onboardingFamilyCreatedTitle => 'Семья создана!';

  @override
  String get onboardingAddInitialChoresTitle => 'Добавьте первые задачи';

  @override
  String get onboardingAddInitialChoresSubtitle =>
      'Выберите типовые домашние дела, чтобы сразу начать пользоваться';

  @override
  String onboardingSelectedCount(int selected, int total) {
    return 'Выбрано: $selected из $total';
  }

  @override
  String get onboardingSelectAll => 'Выбрать все';

  @override
  String get onboardingDeselectAll => 'Снять все';

  @override
  String onboardingAddSelectedChores(int count) {
    return 'Добавить задачи ($count) и войти';
  }

  @override
  String get onboardingSkipChores => 'Пропустить и войти';

  @override
  String get onboardingJoinTitle => 'Вступить в семью';

  @override
  String get onboardingJoinSubtitle =>
      'Введите 6-значный код приглашения вашей семьи';

  @override
  String get onboardingCodePlaceholder => 'ABC-123';

  @override
  String get onboardingPasteCode => 'Вставить';

  @override
  String get onboardingJoinBtn => 'Присоединиться';

  @override
  String get onboardingJoining => 'Проверяем код...';

  @override
  String get onboardingEnterFullCodeError =>
      'Введите полный 6-значный код (например, ABC-123)';

  @override
  String get onboardingFamilyNotFoundError => 'Семья с таким кодом не найдена';

  @override
  String get onboardingJoinSuccessTitle => 'Вы успешно вступили в семью!';

  @override
  String get onboardingEnterFamily => 'Войти в семейный круг';

  @override
  String get onboardingLogout => 'Выйти из аккаунта';

  @override
  String get statsGreetingMorning => 'Доброе утро';

  @override
  String get statsGreetingDay => 'Добрый день';

  @override
  String get statsGreetingEvening => 'Добрый вечер';

  @override
  String get statsGreetingNight => 'Доброй ночи';

  @override
  String get statsTotalCompleted => 'Всего выполнено';

  @override
  String get statsThisWeek => 'На этой неделе';

  @override
  String get statsTodayMeals => 'ПЛАН ПИТАНИЯ НА СЕГОДНЯ';

  @override
  String get statsAllMenu => 'Всё меню';

  @override
  String get statsTodayGrocery => 'СПИСОК ПОКУПОК';

  @override
  String get statsGroceryAdd => 'Добавить';

  @override
  String get statsGroceryEmpty => 'Список покупок пуст';

  @override
  String get statsGroceryEmptyHint =>
      'Нажмите «Добавить», чтобы составить список продуктов';

  @override
  String statsMoreGroceries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'покупок',
      few: 'покупки',
      one: 'покупка',
    );
    return 'И ещё $count $_temp0';
  }

  @override
  String get statsUpcomingEvents => 'БЛИЖАЙШИЕ СОБЫТИЯ';

  @override
  String get statsAllEvents => 'Все события';

  @override
  String get statsAddEvent => 'Добавить';

  @override
  String get statsNoEvents => 'Событий пока нет';

  @override
  String get statsNoEventsHint =>
      'Нажмите «Добавить», чтобы запланировать праздник или поездку';

  @override
  String statsMoreEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'событий',
      few: 'события',
      one: 'событие',
    );
    return 'И ещё $count $_temp0';
  }

  @override
  String get statsWeeklyLeaders => 'ЛИДЕРЫ НЕДЕЛИ';

  @override
  String statsTasksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count задач',
      few: '$count задачи',
      one: '$count задача',
    );
    return '$_temp0';
  }

  @override
  String get eventsAllTitle => 'Все события';

  @override
  String get eventsCreateTitle => 'Новое событие';

  @override
  String get eventsDeleteTitle => 'Удалить событие?';

  @override
  String get eventsDeleteConfirm =>
      'Вы уверены, что хотите удалить это событие?';

  @override
  String get eventsDeleteConfirmDesc => 'Это действие нельзя отменить.';

  @override
  String get eventsWhen => 'Когда';

  @override
  String get eventsDescription => 'Описание';

  @override
  String get eventsDescriptionOptional => 'ОПИСАНИЕ (НЕОБЯЗАТЕЛЬНО)';

  @override
  String get eventsRescheduleDate => 'Перенести дату';

  @override
  String get eventsNewDate => 'Новая дата';

  @override
  String get eventsNameLabel => 'НАЗВАНИЕ';

  @override
  String get eventsDateLabel => 'ДАТА';

  @override
  String get eventsNamePlaceholder => 'Поездка, день рождения, праздник...';

  @override
  String get eventsDescPlaceholder => 'Дополнительные детали или заметки...';

  @override
  String get eventsEnterNameError => 'Введите название события';

  @override
  String eventsCreateError(String error) {
    return 'Не удалось создать событие: $error';
  }

  @override
  String get eventsDeleteBtn => 'Удалить событие';

  @override
  String get slotBreakfast => 'Завтрак';

  @override
  String get slotLunch => 'Обед';

  @override
  String get slotDinner => 'Ужин';

  @override
  String get slotSnack => 'Перекус';

  @override
  String get boardTitle => 'Доска';

  @override
  String get boardSubtitle => 'Расписание и задачи семьи';

  @override
  String get boardPlanChore => 'Запланировать';

  @override
  String get boardNoChores => 'Нет задач на этот день';

  @override
  String get boardNoChoresHint =>
      'Нажмите кнопку ниже, чтобы запланировать задачу';

  @override
  String get boardFilterAll => 'Все';

  @override
  String get boardFilterMine => 'Мои';

  @override
  String get boardFilterDone => 'Выполненные';

  @override
  String get boardFilterPending => 'В процессе';

  @override
  String get chorePlanTitle => 'Запланировать задачу';

  @override
  String get choreQuickTask => 'Быстрая задача';

  @override
  String get choreOrFromTemplates => 'или выберите из шаблонов';

  @override
  String choreCreateCustom(String name) {
    return 'Создать «$name»';
  }

  @override
  String get choreNothingFound => 'Ничего не найдено';

  @override
  String get choreSectionName => 'НАЗВАНИЕ';

  @override
  String get choreSectionAssignee => 'КОМУ НАЗНАЧИТЬ';

  @override
  String get choreSectionDetails => 'ДЕТАЛИ';

  @override
  String get choreSectionRepeat => 'ПОВТОРЕНИЕ';

  @override
  String get choreNamePlaceholder => 'Что нужно сделать?';

  @override
  String get choreNotePlaceholder => 'Добавить заметку или чек-лист...';

  @override
  String get choreDateLabel => 'Дата';

  @override
  String get choreAssignedLabel => 'Назначено';

  @override
  String get choreCompletedLabel => 'Выполнено';

  @override
  String get choreNotDoneYet => 'Ещё нет';

  @override
  String get choreUnassigned => 'Никто';

  @override
  String get choreSubtasksNotes => 'Подзадачи и заметки';

  @override
  String get choreSubtasksHint =>
      'Чек-лист: - [ ] пункт\nЗаметка: просто текст';

  @override
  String get choreSubtasksEmpty =>
      'Нет заметок. Нажмите «Изменить» чтобы добавить чек-лист или комментарий.';

  @override
  String get choreMarkCompleted => 'Отметить выполненным';

  @override
  String get choreCancelCompleted => 'Отменить выполнение';

  @override
  String choreRescheduleTo(String date) {
    return 'Перенести на $date';
  }

  @override
  String get choreDeleteTask => 'Удалить задачу';

  @override
  String get choreConfirmDeleteTitle => 'Удалить задачу?';

  @override
  String get choreConfirmDeleteDesc => 'Это действие нельзя отменить.';

  @override
  String get choreRepeatSettings => 'Настройки повторения';

  @override
  String get choreDeleteRecurringTitle => 'Удаление регулярной задачи';

  @override
  String get choreDeleteRecurringDesc =>
      'Эта задача повторяется по расписанию. Что вы хотите удалить?';

  @override
  String get choreDeleteOnlyThis => 'Только эту задачу';

  @override
  String get choreDeleteAllFuture => 'Эту и все будущие задачи';

  @override
  String get choreEditScheduleTitle => 'Редактировать расписание';

  @override
  String get choreScheduleUpdated => 'Расписание обновлено';

  @override
  String get choreScheduleDeleted => 'Расписание удалено';

  @override
  String get mealsTitle => 'План питания';

  @override
  String get mealsSubtitle => 'Планируйте меню и продукты для всей семьи';

  @override
  String get mealsTabPlanner => 'Расписание';

  @override
  String get mealsTabRecipes => 'Книга рецептов';

  @override
  String get mealsTabGroceries => 'Список покупок';

  @override
  String get mealsAddDish => 'Добавить блюдо';

  @override
  String get mealsAddRecipe => 'Свой рецепт';

  @override
  String get mealsSearchRecipes => 'Поиск по рецептам...';

  @override
  String mealsPrepTime(int minutes) {
    return '$minutes мин';
  }

  @override
  String mealsServings(int servings) {
    String _temp0 = intl.Intl.pluralLogic(
      servings,
      locale: localeName,
      other: '$servings порций',
      few: '$servings порции',
      one: '$servings порция',
    );
    return '$_temp0';
  }

  @override
  String get mealsClearBought => 'Очистить купленные';

  @override
  String get mealsAddProduct => 'Добавить продукт';

  @override
  String get groceryRemainingToBuy => 'Осталось купить: ';

  @override
  String get groceryPlaceholder => 'Что нужно купить?...';

  @override
  String get mealsSectionTime => 'ВРЕМЯ (МИН)';

  @override
  String get mealsSectionServings => 'ПОРЦИИ';

  @override
  String get mealsSectionCook => 'КТО ГОТОВИТ?';

  @override
  String get mealsSectionDishName => 'НАЗВАНИЕ БЛЮДА';

  @override
  String get mealsSectionChooseRecipe => 'ВЫБЕРИТЕ РЕЦЕПТ';

  @override
  String get mealsSectionMealSlot => 'ПРИЕМ ПИЩИ';

  @override
  String get mealsTabRecipe => 'Из рецептов';

  @override
  String get mealsTabManual => 'Быстрая запись';

  @override
  String get mealsAddToMenu => 'Добавить в меню';

  @override
  String get mealsDishPlaceholder => 'Название блюда, например: Борщ';

  @override
  String mealsCookTimeFormat(int minutes) {
    return 'Время приготовления: $minutes мин';
  }

  @override
  String get mealsNoMealsPlanned => 'Меню не запланировано';

  @override
  String mealsPlannedCount(int count) {
    return 'Запланировано блюд: $count';
  }

  @override
  String get mealsRecipeBookEmpty => 'Книга рецептов пуста';

  @override
  String get mealsRecipeBookEmptyDesc =>
      'Добавьте любимые семейные блюда, чтобы планировать меню в один клик';

  @override
  String get mealsAddFirstRecipe => 'Добавить первый рецепт';

  @override
  String get mealsFilterAll => 'Все блюда';

  @override
  String get mealsFilterQuick => 'Быстрые';

  @override
  String get mealsFilterFavorites => 'Избранное';

  @override
  String get mealsFilterKids => 'Детям';

  @override
  String get mealsFilterDinner => 'Ужин';

  @override
  String get mealsFilterDesserts => 'Десерты';

  @override
  String get mealsInMenu => 'В меню';

  @override
  String get mealsSearchPlaceholder => 'Поиск блюда или ингредиента...';

  @override
  String get mealsTryChangeSearch =>
      'Попробуйте изменить запрос или сбросить фильтры';

  @override
  String get mealsScheduleWeekly => 'Запланировать в меню недели';

  @override
  String get mealsDayOfWeek => 'ДЕНЬ НЕДЕЛИ';

  @override
  String get mealsServingsTitle => 'Порции';

  @override
  String get mealsIngredientsTitle => 'Ингредиенты';

  @override
  String get mealsToList => 'В список';

  @override
  String get mealsAddMissingToGroceries =>
      'Добавить недостающее в список покупок';

  @override
  String get mealsInstructionsTitle => 'Приготовление';

  @override
  String mealsTapToPlan(String slot) {
    return 'Нажмите, чтобы запланировать $slot';
  }

  @override
  String get mealsRecipeBadge => 'Рецепт';

  @override
  String get mealsDishAddedToast => 'Блюдо добавлено в меню';

  @override
  String get settingsTitle => 'Профиль и семья';

  @override
  String get settingsProfileSection => 'МОЙ АККАУНТ';

  @override
  String get settingsEditProfile => 'Редактировать профиль';

  @override
  String get settingsFamilySection => 'СЕМЕЙНЫЙ КРУГ';

  @override
  String get settingsFamilyMembers => 'Участники семьи';

  @override
  String get settingsInviteCode => 'Код приглашения';

  @override
  String get settingsCopyCode => 'Скопировать';

  @override
  String get settingsCodeCopied => 'Код скопирован в буфер обмена';

  @override
  String get settingsAdminBadge => 'Админ';

  @override
  String get settingsChangeAdmin => 'Сделать админом';

  @override
  String get settingsKickMember => 'Удалить из семьи';

  @override
  String get settingsLeaveFamily => 'Покинуть семью';

  @override
  String get settingsConfirmLeaveFamily =>
      'Вы уверены, что хотите выйти из семьи?';

  @override
  String get settingsAppearanceSection => 'ИНТЕРФЕЙС И ОФОРМЛЕНИЕ';

  @override
  String get settingsTheme => 'Тема оформления';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsLanguage => 'Язык приложения';

  @override
  String get settingsLanguageRu => 'Русский';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsServerSection => 'ПОДКЛЮЧЕНИЕ';

  @override
  String get settingsServerUrl => 'Адрес сервера';

  @override
  String get settingsLogout => 'Выйти из аккаунта';

  @override
  String get settingsConfirmLogout =>
      'Вы уверены, что хотите выйти из аккаунта?';

  @override
  String get settingsInviteTitle => 'Пригласить участника';

  @override
  String get settingsInviteDesc =>
      'Отправьте этот код человеку, которого хотите пригласить в семью. Код действует ограниченное время.';

  @override
  String get settingsInviteTapToCopy => 'Нажмите, чтобы скопировать';

  @override
  String get settingsInviteCopied => '✓ Код скопирован';

  @override
  String settingsInviteExpiresIn(String time) {
    return 'Код истекает через $time';
  }

  @override
  String get settingsKickConfirmTitle => 'Исключить из семьи?';

  @override
  String settingsKickConfirmContent(String name) {
    return 'Вы действительно хотите исключить $name из семьи?';
  }

  @override
  String get settingsTransferAdminTitle => 'Передать права администратора?';

  @override
  String settingsTransferAdminContent(String name) {
    return 'Сделать $name администратором семьи?';
  }

  @override
  String get settingsThemeSelectTitle => 'Выбор темы оформления';

  @override
  String get settingsLangSelectTitle => 'Выбор языка';

  @override
  String get settingsLangSelectSubtitle =>
      'Выберите удобный язык для работы с приложением';

  @override
  String get settingsTransferAdminBtn => 'Сделать администратором';

  @override
  String get settingsKickMemberBtn => 'Исключить из семьи';

  @override
  String get settingsTransferAdminAction => 'Передать';

  @override
  String get settingsKickAction => 'Исключить';

  @override
  String get settingsFailedToGetCode => 'Не удалось получить код';

  @override
  String get settingsChoresSection => 'ОБЯЗАННОСТИ';

  @override
  String get settingsManageChores => 'Управление обязанностями';

  @override
  String get settingsSubtitle => 'Семья, профиль и настройки';

  @override
  String get themeWarmTitle => 'Тёплая';

  @override
  String get themeWarmName => 'Тёплый семейный уют';

  @override
  String get themeWarmDesc => 'Светлая, тёплая и домашняя атмосфера';

  @override
  String get themeSoftTitle => 'Нежность';

  @override
  String get themeSoftName => 'Нежность и забота';

  @override
  String get themeSoftDesc => 'Пастельные пудровые оттенки и гармония';

  @override
  String get themeNightTitle => 'Вечер';

  @override
  String get themeNightName => 'Уютный вечер дома';

  @override
  String get themeNightDesc => 'Мягкая тёмная тема для вечернего комфорта';

  @override
  String get themeRoyalTitle => 'Свежесть';

  @override
  String get themeRoyalName => 'Свежесть и гармония';

  @override
  String get themeRoyalDesc => 'Чистая прохладная лазурная гамма';

  @override
  String get themeSageTitle => 'Лесной';

  @override
  String get themeSageName => 'Лесной оазис';

  @override
  String get themeSageDesc => 'Успокаивающие шалфейные и травяные тона';

  @override
  String get themeMidnightTitle => 'Северный';

  @override
  String get themeMidnightName => 'Северное сияние';

  @override
  String get themeMidnightDesc => 'Глубокая ночная гамма с акцентом индиго';

  @override
  String get themeAmberTitle => 'Медовый';

  @override
  String get themeAmberName => 'Медовый полдень';

  @override
  String get themeAmberDesc => 'Солнечная золотисто-янтарная гамма и тепло';

  @override
  String get settingsVersion => 'Версия';
}
