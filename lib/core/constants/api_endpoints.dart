class ApiEndpoints {
  ApiEndpoints._();

  static const String defaultBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.1.192:8000',
  );

  // Auth
  static const String login = '/api/auth/login';
  static const String refresh = '/api/auth/refresh';
  static const String register = '/api/auth/register';
  static const String googleAuth = '/api/auth/google';

  // Profile & User
  static const String profile = '/api/users/me/profile';
  static const String settings = '/api/users/me/settings';
  static String userById(String id) => '/api/users/$id';

  // Chores
  static const String chores = '/api/chores';
  static const String defaultChores = '/api/chores/default';
  static const String choresFromDefaults = '/api/chores/from-defaults';
  static const String plannedChores = '/api/chores/planned';
  static const String quickChores = '/api/chores/quick';
  static const String schedules = '/api/schedules';

  // Family
  static const String family = '/api/families';
  static const String familyMembers = '/api/families/members';
  static const String familyLeader = '/api/families/members/leader';
  static const String familyStats = '/api/families/stats';
  static const String events = '/api/families/events';
  static const String upcomingEvents = '/api/families/events/upcoming';
  static const String familyInvite = '/api/families/invite';
  static const String familyJoin = '/api/families/join';
  static const String familyLogout = '/api/families/logout';
  static String familyKick(String id) => '/api/families/kick/$id';
  static String familyChangeAdmin(String id) => '/api/families/change_admin/$id';

  // Notifications
  static const String notificationTest = '/api/notifications/test';

  // Meals
  static const String recipes = '/api/meals/recipes';
  static String recipeById(String id) => '/api/meals/recipes/$id';
  static String recipeFavorite(String id) => '/api/meals/recipes/$id/favorite';
  static const String plannedMeals = '/api/meals/planner';
  static String plannedMealById(String id) => '/api/meals/planner/$id';
  static String plannedMealToggle(String id) => '/api/meals/planner/$id/toggle';
  static const String groceryItems = '/api/meals/groceries';
  static String groceryItemById(String id) => '/api/meals/groceries/$id';
  static const String groceryBatch = '/api/meals/groceries/batch';
}
