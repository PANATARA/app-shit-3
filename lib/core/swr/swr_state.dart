class SWRState<T> {
  /// The current data (from cache or latest network response).
  final T? data;

  /// True only during the very first fetch when NO cached data is available yet.
  /// Use this to show a skeleton loader.
  final bool isLoading;

  /// True when fetching fresh data in the background while displaying stale cached data.
  final bool isRevalidating;

  /// Error from the latest network attempt, if any.
  final Object? error;

  const SWRState({
    this.data,
    this.isLoading = false,
    this.isRevalidating = false,
    this.error,
  });

  bool get hasData => data != null;

  SWRState<T> copyWith({
    T? data,
    bool? isLoading,
    bool? isRevalidating,
    Object? error,
    bool clearError = false,
  }) {
    return SWRState<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isRevalidating: isRevalidating ?? this.isRevalidating,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  String toString() =>
      'SWRState<$T>(data: $data, isLoading: $isLoading, isRevalidating: $isRevalidating, error: $error)';
}
