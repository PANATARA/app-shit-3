import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/swr/swr.dart';
import '../models/planned_chore_model.dart';
import '../models/user_short_model.dart';
import '../repositories/chores_repository.dart';

// ─── Selected Date Providers ───────────────────────────────────────────────

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

final selectedDateKeyProvider = Provider<String>((ref) {
  final date = ref.watch(selectedDateProvider);
  return DateFormat('yyyy-MM-dd').format(date);
});

// ─── SWR Endpoints Definition ───────────────────────────────────────────────

/// SWR family for planned chores on a date
final plannedChoresSwr = createSwrFamily<List<PlannedChoreModel>, String>(
  key: (dateKey) => 'planned-chores:$dateKey',
  fetcher: (ref, dateKey) => ref.read(choresRepositoryProvider).getPlannedChores(dateKey),
  decoder: (json) =>
      (json as List).map((e) => PlannedChoreModel.fromPlannedJson(e as Map<String, dynamic>)).toList(),
  encoder: (data) => data.map((e) => e.toJson()).toList(),
);

/// SWR family for quick planned chores on a date
final quickPlannedChoresSwr = createSwrFamily<List<PlannedChoreModel>, String>(
  key: (dateKey) => 'quick-planned-chores:$dateKey',
  fetcher: (ref, dateKey) => ref.read(choresRepositoryProvider).getQuickPlannedChores(dateKey),
  decoder: (json) =>
      (json as List).map((e) => PlannedChoreModel.fromQuickJson(e as Map<String, dynamic>)).toList(),
  encoder: (data) => data.map((e) => e.toJson()).toList(),
);

/// Active CancelToken for board fetching to abort in-flight requests on date change
CancelToken? _activeBoardCancelToken;

/// Combined SWR family for all board chores on a date (stale-while-revalidate)
final boardChoresSwr = createSwrFamily<List<PlannedChoreModel>, String>(
  key: (dateKey) => 'board-chores:$dateKey',
  fetcher: (ref, dateKey) {
    _activeBoardCancelToken?.cancel('Switched to new date');
    final cancelToken = CancelToken();
    _activeBoardCancelToken = cancelToken;
    return ref.read(choresRepositoryProvider).getBoardChores(dateKey, cancelToken: cancelToken);
  },
  decoder: (json) =>
      (json as List).map((e) => PlannedChoreModel.fromJson(e as Map<String, dynamic>)).toList(),
  encoder: (data) => data.map((e) => e.toJson()).toList(),
);

/// Invalidate board cache for a specific date or all dates
void invalidateBoard([String? dateKey]) {
  if (dateKey != null && dateKey.isNotEmpty) {
    Swr.mutate('planned-chores:$dateKey');
    Swr.mutate('quick-planned-chores:$dateKey');
    Swr.mutate('board-chores:$dateKey');
  } else {
    Swr.mutate('planned-chores:*');
    Swr.mutate('quick-planned-chores:*');
    Swr.mutate('board-chores:*');
  }
}

// ─── Board UI State ─────────────────────────────────────────────────────────

class BoardState {
  final bool isLoading;
  final bool isRevalidating;
  final List<PlannedChoreModel> chores;
  final Set<String> completingIds;
  final String? errorMessage;

  const BoardState({
    this.isLoading = false,
    this.isRevalidating = false,
    this.chores = const [],
    this.completingIds = const {},
    this.errorMessage,
  });

  List<PlannedChoreModel> get activeChores =>
      chores.where((c) => c.completedBy == null).toList();

  List<PlannedChoreModel> get completedChores =>
      chores.where((c) => c.completedBy != null).toList();

  int get totalCount => chores.length;

  BoardState copyWith({
    bool? isLoading,
    bool? isRevalidating,
    List<PlannedChoreModel>? chores,
    Set<String>? completingIds,
    String? errorMessage,
  }) {
    return BoardState(
      isLoading: isLoading ?? this.isLoading,
      isRevalidating: isRevalidating ?? this.isRevalidating,
      chores: chores ?? this.chores,
      completingIds: completingIds ?? this.completingIds,
      errorMessage: errorMessage,
    );
  }
}

// ─── Board Notifier ─────────────────────────────────────────────────────────

final boardNotifierProvider =
    NotifierProvider<BoardNotifier, BoardState>(BoardNotifier.new);

class BoardNotifier extends Notifier<BoardState> {
  ChoresRepository get _repo => ref.read(choresRepositoryProvider);
  String? _lastDateKey;

  @override
  BoardState build() {
    final dateKey = ref.watch(selectedDateKeyProvider);
    // Connect to SWR provider for this dateKey
    final swr = ref.watch(boardChoresSwr(dateKey));

    if (_lastDateKey != dateKey) {
      _lastDateKey = dateKey;
      Future.microtask(() {
        ref.read(boardChoresSwr(dateKey).notifier).revalidate();
      });
    }

    return BoardState(
      isLoading: swr.isLoading,
      isRevalidating: swr.isRevalidating,
      chores: swr.data ?? const [],
      errorMessage: swr.error?.toString(),
      completingIds: const {},
    );
  }

  Future<void> refresh() async {
    final dateKey = ref.read(selectedDateKeyProvider);
    await ref.read(boardChoresSwr(dateKey).notifier).revalidate();
  }

  Future<void> toggleChore(PlannedChoreModel chore) async {
    final isCompleted = chore.isDone;
    final dateKey = ref.read(selectedDateKeyProvider);
    final currentChores = state.chores;

    // Trigger completing animation if active
    if (!isCompleted) {
      state = state.copyWith(
        completingIds: {...state.completingIds, chore.id},
      );

      await Future.delayed(const Duration(milliseconds: 450));
    }

    // Optimistic SWR update
    final updatedChores = currentChores.map((c) {
      if (c.id == chore.id) {
        return c.copyWith(
          clearCompletedBy: isCompleted,
          completedBy: isCompleted
              ? null
              : (c.assignedTo ?? const UserShort(id: 'me', name: 'Вы')),
        );
      }
      return c;
    }).toList();

    // Instantly update UI and SWR local cache first
    await ref.read(boardChoresSwr(dateKey).notifier).mutate(updatedChores);

    // Clear completingId after the chore is already marked completed
    if (!isCompleted) {
      final updatedIds = Set<String>.from(state.completingIds)..remove(chore.id);
      state = state.copyWith(completingIds: updatedIds);
    }

    try {
      if (isCompleted) {
        await _repo.uncompleteChore(chore);
      } else {
        await _repo.completeChore(chore);
      }
      // Silently revalidate with server in background
      await ref.read(boardChoresSwr(dateKey).notifier).revalidate();
    } catch (e) {
      // Revert optimistic update on error
      await ref.read(boardChoresSwr(dateKey).notifier).mutate(currentChores);
      state = state.copyWith(
        errorMessage: 'Не удалось обновить статус задачи',
      );
    }
  }

  Future<void> updateSubtasks(PlannedChoreModel chore, String newMessage) async {
    final dateKey = ref.read(selectedDateKeyProvider);
    final currentChores = state.chores;

    // Optimistic update
    final updatedChores = currentChores.map((c) {
      if (c.id == chore.id) {
        return c.copyWith(message: newMessage);
      }
      return c;
    }).toList();

    await ref.read(boardChoresSwr(dateKey).notifier).mutate(updatedChores);

    try {
      await _repo.updateMessage(chore, newMessage);
    } catch (e) {
      // Revert on failure
      await ref.read(boardChoresSwr(dateKey).notifier).mutate(currentChores);
      state = state.copyWith(
        errorMessage: 'Не удалось обновить подзадачу',
      );
    }
  }
}
