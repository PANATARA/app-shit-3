// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Household';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonDone => 'Done';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSearch => 'Search...';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonEmpty => 'Nothing here';

  @override
  String get commonError => 'An error occurred';

  @override
  String get commonYou => 'you';

  @override
  String get commonNone => 'None';

  @override
  String get commonXp => 'XP';

  @override
  String get dateToday => 'Today';

  @override
  String get dateTomorrow => 'Tomorrow';

  @override
  String get dateDayAfterTomorrow => 'In 2 days';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String dateInDays(int count) {
    return 'in $count d.';
  }

  @override
  String dateDaysAgo(int count) {
    return '$count d. ago';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navBoard => 'Board';

  @override
  String get navMeals => 'Meals';

  @override
  String get navProfile => 'Profile';

  @override
  String get authLoginTitle => 'Sign In';

  @override
  String get authLoginSubtitle => 'Enter username and password to sign in';

  @override
  String get authRegisterTitle => 'Create Account';

  @override
  String get authRegisterSubtitle => 'Create an account to get started';

  @override
  String get authUsernameLabel => 'Username';

  @override
  String get authUsernamePlaceholder => 'Enter your username';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordPlaceholder => 'Enter password (min 6 characters)';

  @override
  String get authNameLabel => 'Your Name';

  @override
  String get authNamePlaceholder => 'What is your name? (e.g. Anna)';

  @override
  String get authSignInBtn => 'Sign In';

  @override
  String get authSignUpBtn => 'Create Account';

  @override
  String get authNoAccount => 'Don\'t have an account? Sign Up';

  @override
  String get authHaveAccount => 'Already have an account? Sign In';

  @override
  String get authFillRequired => 'Please enter username and password';

  @override
  String get authPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get authServerSettings => 'Server URL';

  @override
  String get authServerPrompt => 'Specify backend URL:';

  @override
  String get authTestConnection => 'Test Connection';

  @override
  String get authConnectionSuccess => 'Connected successfully';

  @override
  String get authConnectionFail => 'Connection failed';

  @override
  String get onboardingFamilyCircle => 'Family Circle';

  @override
  String get onboardingChooseTitle => 'How shall we begin?';

  @override
  String get onboardingChooseSubtitle =>
      'Create a new family space or join an existing circle.';

  @override
  String get onboardingNewFamily => 'New Family';

  @override
  String get onboardingCreateFamily => 'Create Family';

  @override
  String get onboardingCreateFamilyDesc =>
      'Create a space for your family and invite your loved ones.';

  @override
  String get onboardingStartCreating => 'Start Creating';

  @override
  String get onboardingAlreadyHaveFamily => 'Already have a family?';

  @override
  String get onboardingJoinFamily => 'Join Family';

  @override
  String get onboardingJoinFamilyDesc =>
      'Join using an invite code from your family administrator.';

  @override
  String get onboardingEnterCode => 'Enter Code';

  @override
  String get onboardingStep1Of2 => 'Step 1 of 2';

  @override
  String get onboardingStep2Of2 => 'Step 2 of 2';

  @override
  String get onboardingStep1Title => 'Family Name';

  @override
  String get onboardingStep1Subtitle => 'Choose a name for your family circle';

  @override
  String get onboardingFamilyNameLabel => 'Family Name';

  @override
  String get onboardingFamilyPlaceholder => 'e.g. The Smith Family';

  @override
  String get onboardingFamilyNameRequired => 'Please enter family name';

  @override
  String get onboardingSuggestions => 'Suggestions:';

  @override
  String get onboardingChooseAvatar => 'Family Icon & Style';

  @override
  String get onboardingCreateFamilyBtn => 'Create Family Circle';

  @override
  String get onboardingCreatingFamily => 'Creating family...';

  @override
  String get onboardingFamilyCreatedTitle => 'Family Created!';

  @override
  String get onboardingAddInitialChoresTitle => 'Add First Tasks';

  @override
  String get onboardingAddInitialChoresSubtitle =>
      'Choose template chores to get started right away';

  @override
  String onboardingSelectedCount(int selected, int total) {
    return 'Selected: $selected of $total';
  }

  @override
  String get onboardingSelectAll => 'Select All';

  @override
  String get onboardingDeselectAll => 'Deselect All';

  @override
  String onboardingAddSelectedChores(int count) {
    return 'Add Chores ($count) and Enter';
  }

  @override
  String get onboardingSkipChores => 'Skip and Enter';

  @override
  String get onboardingJoinTitle => 'Join Family';

  @override
  String get onboardingJoinSubtitle => 'Enter the 6-digit family invite code';

  @override
  String get onboardingCodePlaceholder => 'ABC-123';

  @override
  String get onboardingPasteCode => 'Paste';

  @override
  String get onboardingJoinBtn => 'Join';

  @override
  String get onboardingJoining => 'Checking code...';

  @override
  String get onboardingEnterFullCodeError =>
      'Enter the full 6-digit code (e.g. ABC-123)';

  @override
  String get onboardingFamilyNotFoundError =>
      'Family with this code was not found';

  @override
  String get onboardingJoinSuccessTitle => 'Successfully joined the family!';

  @override
  String get onboardingEnterFamily => 'Enter Family Circle';

  @override
  String get onboardingLogout => 'Log Out';

  @override
  String get statsGreetingMorning => 'Good morning';

  @override
  String get statsGreetingDay => 'Good afternoon';

  @override
  String get statsGreetingEvening => 'Good evening';

  @override
  String get statsGreetingNight => 'Good night';

  @override
  String get statsTotalCompleted => 'Total Completed';

  @override
  String get statsThisWeek => 'This Week';

  @override
  String get statsTodayMeals => 'TODAY\'S MEAL PLAN';

  @override
  String get statsAllMenu => 'Full Menu';

  @override
  String get statsTodayGrocery => 'GROCERY LIST';

  @override
  String get statsGroceryAdd => 'Add';

  @override
  String get statsGroceryEmpty => 'Grocery list is empty';

  @override
  String get statsGroceryEmptyHint => 'Tap \'Add\' to build your grocery list';

  @override
  String statsMoreGroceries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return 'And $count more $_temp0';
  }

  @override
  String get statsUpcomingEvents => 'UPCOMING EVENTS';

  @override
  String get statsAllEvents => 'All Events';

  @override
  String get statsAddEvent => 'Add';

  @override
  String get statsNoEvents => 'No events yet';

  @override
  String get statsNoEventsHint =>
      'Tap \'Add\' to schedule a trip or celebration';

  @override
  String statsMoreEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'events',
      one: 'event',
    );
    return 'And $count more $_temp0';
  }

  @override
  String get statsWeeklyLeaders => 'WEEKLY LEADERS';

  @override
  String statsTasksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '$count task',
    );
    return '$_temp0';
  }

  @override
  String get eventsAllTitle => 'All Events';

  @override
  String get eventsCreateTitle => 'New Event';

  @override
  String get eventsDeleteTitle => 'Delete Event?';

  @override
  String get eventsDeleteConfirm =>
      'Are you sure you want to delete this event?';

  @override
  String get eventsDeleteConfirmDesc => 'This action cannot be undone.';

  @override
  String get eventsWhen => 'When';

  @override
  String get eventsDescription => 'Description';

  @override
  String get eventsDescriptionOptional => 'DESCRIPTION (OPTIONAL)';

  @override
  String get eventsRescheduleDate => 'Reschedule date';

  @override
  String get eventsNewDate => 'New date';

  @override
  String get eventsNameLabel => 'NAME';

  @override
  String get eventsDateLabel => 'DATE';

  @override
  String get eventsNamePlaceholder => 'Trip, birthday, celebration...';

  @override
  String get eventsDescPlaceholder => 'Additional details or notes...';

  @override
  String get eventsEnterNameError => 'Enter event name';

  @override
  String eventsCreateError(String error) {
    return 'Failed to create event: $error';
  }

  @override
  String get eventsDeleteBtn => 'Delete event';

  @override
  String get slotBreakfast => 'Breakfast';

  @override
  String get slotLunch => 'Lunch';

  @override
  String get slotDinner => 'Dinner';

  @override
  String get slotSnack => 'Snack';

  @override
  String get boardTitle => 'Board';

  @override
  String get boardSubtitle => 'Schedule and family chores';

  @override
  String get boardPlanChore => 'Schedule';

  @override
  String get boardNoChores => 'No tasks for this day';

  @override
  String get boardNoChoresHint => 'Tap the button below to schedule a task';

  @override
  String get boardFilterAll => 'All';

  @override
  String get boardFilterMine => 'Mine';

  @override
  String get boardFilterDone => 'Completed';

  @override
  String get boardFilterPending => 'In progress';

  @override
  String get chorePlanTitle => 'Schedule Task';

  @override
  String get choreQuickTask => 'Quick Task';

  @override
  String get choreOrFromTemplates => 'or choose from templates';

  @override
  String choreCreateCustom(String name) {
    return 'Create \"$name\"';
  }

  @override
  String get choreNothingFound => 'Nothing found';

  @override
  String get choreSectionName => 'NAME';

  @override
  String get choreSectionAssignee => 'ASSIGN TO';

  @override
  String get choreSectionDetails => 'DETAILS';

  @override
  String get choreSectionRepeat => 'REPEAT';

  @override
  String get choreNamePlaceholder => 'What needs to be done?';

  @override
  String get choreNotePlaceholder => 'Add note or checklist...';

  @override
  String get choreDateLabel => 'Date';

  @override
  String get choreAssignedLabel => 'Assigned to';

  @override
  String get choreCompletedLabel => 'Completed by';

  @override
  String get choreNotDoneYet => 'Not yet';

  @override
  String get choreUnassigned => 'No one';

  @override
  String get choreSubtasksNotes => 'Subtasks and Notes';

  @override
  String get choreSubtasksHint => 'Checklist: - [ ] item\nNote: plain text';

  @override
  String get choreSubtasksEmpty =>
      'No notes. Tap \'Edit\' to add a checklist or comment.';

  @override
  String get choreMarkCompleted => 'Mark as Completed';

  @override
  String get choreCancelCompleted => 'Undo Completion';

  @override
  String choreRescheduleTo(String date) {
    return 'Reschedule to $date';
  }

  @override
  String get choreDeleteTask => 'Delete Task';

  @override
  String get choreConfirmDeleteTitle => 'Delete task?';

  @override
  String get choreConfirmDeleteDesc => 'This action cannot be undone.';

  @override
  String get choreRepeatSettings => 'Repeat Settings';

  @override
  String get choreDeleteRecurringTitle => 'Delete recurring chore';

  @override
  String get choreDeleteRecurringDesc =>
      'This chore repeats on schedule. What would you like to delete?';

  @override
  String get choreDeleteOnlyThis => 'Only this task';

  @override
  String get choreDeleteAllFuture => 'This and all future tasks';

  @override
  String get choreEditScheduleTitle => 'Edit schedule';

  @override
  String get choreScheduleUpdated => 'Schedule updated';

  @override
  String get choreScheduleDeleted => 'Schedule deleted';

  @override
  String get mealsTitle => 'Meal Plan';

  @override
  String get mealsSubtitle =>
      'Plan weekly menu and groceries for the entire family';

  @override
  String get mealsTabPlanner => 'Planner';

  @override
  String get mealsTabRecipes => 'Recipe Book';

  @override
  String get mealsTabGroceries => 'Grocery List';

  @override
  String get mealsAddDish => 'Add Dish';

  @override
  String get mealsAddRecipe => 'Custom Recipe';

  @override
  String get mealsSearchRecipes => 'Search recipes...';

  @override
  String mealsPrepTime(int minutes) {
    return '$minutes min';
  }

  @override
  String mealsServings(int servings) {
    String _temp0 = intl.Intl.pluralLogic(
      servings,
      locale: localeName,
      other: '$servings servings',
      one: '$servings serving',
    );
    return '$_temp0';
  }

  @override
  String get mealsClearBought => 'Clear Bought';

  @override
  String get mealsAddProduct => 'Add Item';

  @override
  String get groceryRemainingToBuy => 'Remaining: ';

  @override
  String get groceryPlaceholder => 'What to buy?...';

  @override
  String get mealsSectionTime => 'TIME (MIN)';

  @override
  String get mealsSectionServings => 'SERVINGS';

  @override
  String get mealsSectionCook => 'WHO IS COOKING?';

  @override
  String get mealsSectionDishName => 'DISH NAME';

  @override
  String get mealsSectionChooseRecipe => 'CHOOSE RECIPE';

  @override
  String get mealsSectionMealSlot => 'MEAL TIME';

  @override
  String get mealsTabRecipe => 'From recipes';

  @override
  String get mealsTabManual => 'Quick entry';

  @override
  String get mealsAddToMenu => 'Add to menu';

  @override
  String get mealsDishPlaceholder => 'Dish name, e.g.: Soup';

  @override
  String mealsCookTimeFormat(int minutes) {
    return 'Cooking time: $minutes min';
  }

  @override
  String get mealsNoMealsPlanned => 'No meals planned';

  @override
  String mealsPlannedCount(int count) {
    return 'Planned meals: $count';
  }

  @override
  String get mealsRecipeBookEmpty => 'Recipe book is empty';

  @override
  String get mealsRecipeBookEmptyDesc =>
      'Add favorite family meals to plan menus in one click';

  @override
  String get mealsAddFirstRecipe => 'Add first recipe';

  @override
  String get mealsFilterAll => 'All meals';

  @override
  String get mealsFilterQuick => 'Quick';

  @override
  String get mealsFilterFavorites => 'Favorites';

  @override
  String get mealsFilterKids => 'Kids';

  @override
  String get mealsFilterDinner => 'Dinner';

  @override
  String get mealsFilterDesserts => 'Desserts';

  @override
  String get mealsInMenu => 'In menu';

  @override
  String get mealsSearchPlaceholder => 'Search meal or ingredient...';

  @override
  String get mealsTryChangeSearch =>
      'Try changing the search or resetting filters';

  @override
  String get mealsScheduleWeekly => 'Schedule for weekly menu';

  @override
  String get mealsDayOfWeek => 'DAY OF WEEK';

  @override
  String get mealsServingsTitle => 'Servings';

  @override
  String get mealsIngredientsTitle => 'Ingredients';

  @override
  String get mealsToList => 'To list';

  @override
  String get mealsAddMissingToGroceries => 'Add missing to grocery list';

  @override
  String get mealsInstructionsTitle => 'Instructions';

  @override
  String mealsTapToPlan(String slot) {
    return 'Tap to plan $slot';
  }

  @override
  String get mealsRecipeBadge => 'Recipe';

  @override
  String get mealsDishAddedToast => 'Dish added to menu';

  @override
  String get settingsTitle => 'Profile & Family';

  @override
  String get settingsProfileSection => 'MY ACCOUNT';

  @override
  String get settingsEditProfile => 'Edit Profile';

  @override
  String get settingsFamilySection => 'FAMILY CIRCLE';

  @override
  String get settingsFamilyMembers => 'Family Members';

  @override
  String get settingsInviteCode => 'Invite Code';

  @override
  String get settingsCopyCode => 'Copy';

  @override
  String get settingsCodeCopied => 'Code copied to clipboard';

  @override
  String get settingsAdminBadge => 'Admin';

  @override
  String get settingsChangeAdmin => 'Make Admin';

  @override
  String get settingsKickMember => 'Remove from Family';

  @override
  String get settingsLeaveFamily => 'Leave Family';

  @override
  String get settingsConfirmLeaveFamily =>
      'Are you sure you want to leave the family?';

  @override
  String get settingsAppearanceSection => 'APPEARANCE & INTERFACE';

  @override
  String get settingsTheme => 'App Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLanguage => 'App Language';

  @override
  String get settingsLanguageRu => 'Русский';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsTimezone => 'Timezone';

  @override
  String get settingsTimezoneAuto => 'Detected automatically';

  @override
  String get settingsServerSection => 'CONNECTION';

  @override
  String get settingsServerUrl => 'Server URL';

  @override
  String get settingsLogout => 'Log Out';

  @override
  String get settingsConfirmLogout => 'Are you sure you want to log out?';

  @override
  String get settingsInviteTitle => 'Invite Member';

  @override
  String get settingsInviteDesc =>
      'Send this code to the person you want to invite to your family circle. The code expires in limited time.';

  @override
  String get settingsInviteTapToCopy => 'Tap to copy';

  @override
  String get settingsInviteCopied => '✓ Code copied';

  @override
  String settingsInviteExpiresIn(String time) {
    return 'Code expires in $time';
  }

  @override
  String get settingsKickConfirmTitle => 'Remove from family?';

  @override
  String settingsKickConfirmContent(String name) {
    return 'Are you sure you want to remove $name from the family circle?';
  }

  @override
  String get settingsTransferAdminTitle => 'Transfer Admin Rights?';

  @override
  String settingsTransferAdminContent(String name) {
    return 'Make $name the administrator of this family?';
  }

  @override
  String get settingsThemeSelectTitle => 'Select Theme';

  @override
  String get settingsLangSelectTitle => 'Select Language';

  @override
  String get settingsLangSelectSubtitle =>
      'Choose a convenient language for using the app';

  @override
  String get settingsTransferAdminBtn => 'Make Administrator';

  @override
  String get settingsKickMemberBtn => 'Remove from Family';

  @override
  String get settingsTransferAdminAction => 'Transfer';

  @override
  String get settingsKickAction => 'Remove';

  @override
  String get settingsFailedToGetCode => 'Failed to get invite code';

  @override
  String get settingsChoresSection => 'RESPONSIBILITIES';

  @override
  String get settingsManageChores => 'Manage Responsibilities';

  @override
  String get settingsSubtitle => 'Family, profile & settings';

  @override
  String get themeWarmTitle => 'Warm';

  @override
  String get themeWarmName => 'Warm Family Comfort';

  @override
  String get themeWarmDesc => 'Light, warm, and cozy home atmosphere';

  @override
  String get themeSoftTitle => 'Soft';

  @override
  String get themeSoftName => 'Tenderness & Care';

  @override
  String get themeSoftDesc => 'Pastel powdery shades and harmony';

  @override
  String get themeNightTitle => 'Evening';

  @override
  String get themeNightName => 'Cozy Evening at Home';

  @override
  String get themeNightDesc => 'Soft dark theme for evening comfort';

  @override
  String get themeRoyalTitle => 'Fresh';

  @override
  String get themeRoyalName => 'Freshness & Harmony';

  @override
  String get themeRoyalDesc => 'Clean and cool azure palette';

  @override
  String get themeSageTitle => 'Sage';

  @override
  String get themeSageName => 'Forest Oasis';

  @override
  String get themeSageDesc => 'Soothing sage and herbal tones';

  @override
  String get themeMidnightTitle => 'Midnight';

  @override
  String get themeMidnightName => 'Northern Lights';

  @override
  String get themeMidnightDesc => 'Deep night palette with indigo accent';

  @override
  String get themeAmberTitle => 'Amber';

  @override
  String get themeAmberName => 'Honey Noon';

  @override
  String get themeAmberDesc => 'Sunny golden amber palette and warmth';

  @override
  String get settingsVersion => 'Version';
}
