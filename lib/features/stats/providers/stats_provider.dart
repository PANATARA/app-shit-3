import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/swr/swr.dart';
import '../../auth/models/user_model.dart';
import '../models/family_event_model.dart';
import '../models/family_leader_model.dart';
import '../repositories/stats_repository.dart';

// ─── SWR Endpoints ──────────────────────────────────────────────────────────

/// SWR endpoint for weekly family leaders
final familyLeadersSwr = createSwrProvider<WeeklyLeadersResponseModel>(
  key: 'family-leaders',
  fetcher: (ref) => ref.read(statsRepositoryProvider).getFamilyLeaders(),
  decoder: (json) => WeeklyLeadersResponseModel.fromJson(json as Map<String, dynamic>),
  encoder: (data) => data.toJson(),
);

/// SWR endpoint for upcoming family events
final upcomingEventsSwr = createSwrProvider<List<FamilyEventModel>>(
  key: 'family-events',
  fetcher: (ref) => ref.read(statsRepositoryProvider).getUpcomingEvents(),
  decoder: (json) => (json as List)
      .whereType<Map<String, dynamic>>()
      .map((e) => FamilyEventModel.fromJson(e))
      .toList(),
  encoder: (data) => data.map((e) => e.toJson()).toList(),
);

/// SWR endpoint for current user profile stats
final myProfileSwr = createSwrProvider<UserModel>(
  key: 'profile',
  fetcher: (ref) => ref.read(statsRepositoryProvider).getProfile(),
  decoder: (json) => UserModel.fromJson(json as Map<String, dynamic>),
  encoder: (data) => data.toJson(),
);

/// Cache invalidators
void invalidateHomeStats() {
  Swr.mutate('family-leaders*');
  Swr.mutate('family-events*');
  Swr.mutate('profile*');
}

// ─── Stats UI State ─────────────────────────────────────────────────────────

class HomeState {
  final bool isLoading;
  final bool isRevalidating;
  final UserModel? profile;
  final WeeklyLeadersResponseModel? leaders;
  final List<FamilyEventModel> events;
  final String? errorMessage;

  const HomeState({
    this.isLoading = false,
    this.isRevalidating = false,
    this.profile,
    this.leaders,
    this.events = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    bool? isLoading,
    bool? isRevalidating,
    UserModel? profile,
    WeeklyLeadersResponseModel? leaders,
    List<FamilyEventModel>? events,
    String? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isRevalidating: isRevalidating ?? this.isRevalidating,
      profile: profile ?? this.profile,
      leaders: leaders ?? this.leaders,
      events: events ?? this.events,
      errorMessage: errorMessage,
    );
  }
}

// ─── Stats Notifier ─────────────────────────────────────────────────────────

final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);

class HomeNotifier extends Notifier<HomeState> {
  StatsRepository get _repo => ref.read(statsRepositoryProvider);

  @override
  HomeState build() {
    final profileSwr = ref.watch(myProfileSwr);
    final leadersSwr = ref.watch(familyLeadersSwr);
    final eventsSwr = ref.watch(upcomingEventsSwr);

    final isLoading = (profileSwr.isLoading && profileSwr.data == null) ||
        (leadersSwr.isLoading && leadersSwr.data == null) ||
        (eventsSwr.isLoading && eventsSwr.data == null);

    final isRevalidating = profileSwr.isRevalidating ||
        leadersSwr.isRevalidating ||
        eventsSwr.isRevalidating;

    final error = profileSwr.error ??
        leadersSwr.error ??
        eventsSwr.error;

    return HomeState(
      isLoading: isLoading,
      isRevalidating: isRevalidating,
      profile: profileSwr.data,
      leaders: leadersSwr.data,
      events: eventsSwr.data ?? const [],
      errorMessage: error?.toString(),
    );
  }

  Future<void> refresh() async {
    await Future.wait<dynamic>([
      ref.read(myProfileSwr.notifier).revalidate(),
      ref.read(familyLeadersSwr.notifier).revalidate(),
      ref.read(upcomingEventsSwr.notifier).revalidate(),
    ]);
  }

  Future<void> deleteEvent(String id) async {
    final currentEvents = state.events;
    final updated = currentEvents.where((e) => e.id != id).toList();
    await ref.read(upcomingEventsSwr.notifier).mutate(updated);

    try {
      await _repo.deleteEvent(id);
      await ref.read(upcomingEventsSwr.notifier).revalidate();
    } catch (e) {
      await ref.read(upcomingEventsSwr.notifier).mutate(currentEvents);
      rethrow;
    }
  }

  Future<void> rescheduleEvent(String id, String newDate) async {
    final currentEvents = state.events;
    final updated = currentEvents.map((e) {
      if (e.id == id) {
        return FamilyEventModel(
          id: e.id,
          name: e.name,
          description: e.description,
          icon: e.icon,
          iconColor: e.iconColor,
          iconBg: e.iconBg,
          date: newDate,
        );
      }
      return e;
    }).toList();

    await ref.read(upcomingEventsSwr.notifier).mutate(updated);

    try {
      await _repo.updateEvent(id: id, date: newDate);
      await ref.read(upcomingEventsSwr.notifier).revalidate();
    } catch (e) {
      await ref.read(upcomingEventsSwr.notifier).mutate(currentEvents);
      rethrow;
    }
  }

  Future<void> createEvent({
    required String name,
    required String date,
    String? description,
    String icon = 'material-symbols:celebration-rounded',
    String iconColor = '#ffffff',
    String iconBg = 'linear-gradient(135deg, #8B5CF6 0%, #6366F1 100%)',
  }) async {
    await _repo.createEvent(
      name: name,
      date: date,
      description: description,
      icon: icon,
      iconColor: iconColor,
      iconBg: iconBg,
    );
    await ref.read(upcomingEventsSwr.notifier).revalidate();
  }
}
