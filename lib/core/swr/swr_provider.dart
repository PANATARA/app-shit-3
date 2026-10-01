import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'swr_cache.dart';
import 'swr_event_bus.dart';
import 'swr_state.dart';

typedef SwrFetcher<T> = Future<T> Function(Ref ref);
typedef SwrDecoder<T> = T Function(dynamic json);
typedef SwrEncoder<T> = dynamic Function(T data);

class SwrNotifier<T> extends Notifier<SWRState<T>> {
  final String key;
  final SwrFetcher<T> fetcher;
  final SwrDecoder<T>? decoder;
  final SwrEncoder<T>? encoder;

  bool _isRevalidating = false;

  SwrNotifier({
    required this.key,
    required this.fetcher,
    this.decoder,
    this.encoder,
  });

  @override
  SWRState<T> build() {
    // 1. Try sync memory cache for 0ms initial render
    final syncRaw = SwrCache.instance.getSync(key);
    T? initialData;
    if (syncRaw != null) {
      try {
        initialData = decoder != null ? decoder!(syncRaw) : (syncRaw as T?);
      } catch (e) {
        debugPrint('[SWR] Memory decode error for key "$key": $e');
      }
    }

    final hasCached = initialData != null;
    final initialState = SWRState<T>(
      data: initialData,
      isLoading: !hasCached,
      isRevalidating: hasCached,
    );

    // 2. Subscribe to global mutate events
    void onMutate(dynamic fresh) {
      if (fresh != null) {
        try {
          final decoded = fresh is T ? fresh : (decoder != null ? decoder!(fresh) : fresh as T);
          state = state.copyWith(
            data: decoded,
            isLoading: false,
            isRevalidating: false,
            clearError: true,
          );
        } catch (_) {
          revalidate();
        }
      } else {
        revalidate();
      }
    }

    SwrEventBus.instance.addListener(key, onMutate);
    ref.onDispose(() {
      SwrEventBus.instance.removeListener(key, onMutate);
    });

    // 3. Read disk cache if memory was empty, and trigger revalidation
    Future.microtask(() async {
      if (state.data == null) {
        final diskRaw = await SwrCache.instance.get(key);
        if (diskRaw != null) {
          try {
            final diskData = decoder != null ? decoder!(diskRaw) : (diskRaw as T?);
            if (diskData != null && state.data == null) {
              state = state.copyWith(
                data: diskData,
                isLoading: false,
                isRevalidating: true,
              );
            }
          } catch (_) {}
        }
      }
      await revalidate();
    });

    return initialState;
  }

  Future<void> revalidate() async {
    if (_isRevalidating) return;
    _isRevalidating = true;
    state = state.copyWith(isRevalidating: true);
    debugPrint('[SWR] Revalidating "$key"...');

    try {
      final fresh = await fetcher(ref);
      final raw = encoder != null ? encoder!(fresh) : fresh;
      await SwrCache.instance.set(key, raw);
      state = state.copyWith(
        data: fresh,
        isLoading: false,
        isRevalidating: false,
        clearError: true,
      );
      debugPrint('[SWR] Successfully revalidated "$key"');
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        debugPrint('[SWR] Revalidation cancelled for "$key"');
        state = state.copyWith(isRevalidating: false);
        return;
      }
      debugPrint('[SWR] Error revalidating "$key": $e');
      state = state.copyWith(
        isLoading: false,
        isRevalidating: false,
        error: e,
      );
    } finally {
      _isRevalidating = false;
    }
  }

  Future<void> mutate([T? freshData]) async {
    if (freshData != null) {
      state = state.copyWith(
        data: freshData,
        isLoading: false,
        clearError: true,
      );
      final raw = encoder != null ? encoder!(freshData) : freshData;
      await SwrCache.instance.set(key, raw);
      SwrEventBus.instance.emit(key, freshData);
    } else {
      await revalidate();
    }
  }
}

typedef SwrFamilyFetcher<T, Arg> = Future<T> Function(Ref ref, Arg arg);

class FamilySwrNotifier<T, Arg> extends Notifier<SWRState<T>> {
  final String Function(Arg arg) keyBuilder;
  final SwrFamilyFetcher<T, Arg> fetcher;
  final SwrDecoder<T>? decoder;
  final SwrEncoder<T>? encoder;
  final Arg arg;

  bool _isRevalidating = false;

  FamilySwrNotifier({
    required this.keyBuilder,
    required this.fetcher,
    this.decoder,
    this.encoder,
    required this.arg,
  });

  String get key => keyBuilder(arg);

  @override
  SWRState<T> build() {
    final cacheKey = key;
    final syncRaw = SwrCache.instance.getSync(cacheKey);
    T? initialData;
    if (syncRaw != null) {
      try {
        initialData = decoder != null ? decoder!(syncRaw) : (syncRaw as T?);
      } catch (e) {
        debugPrint('[SWR] Memory decode error for key "$cacheKey": $e');
      }
    }

    final hasCached = initialData != null;
    final initialState = SWRState<T>(
      data: initialData,
      isLoading: !hasCached,
      isRevalidating: hasCached,
    );

    void onMutate(dynamic fresh) {
      if (fresh != null) {
        try {
          final decoded = fresh is T ? fresh : (decoder != null ? decoder!(fresh) : fresh as T);
          state = state.copyWith(
            data: decoded,
            isLoading: false,
            isRevalidating: false,
            clearError: true,
          );
        } catch (_) {
          revalidate();
        }
      } else {
        revalidate();
      }
    }

    SwrEventBus.instance.addListener(cacheKey, onMutate);
    ref.onDispose(() {
      SwrEventBus.instance.removeListener(cacheKey, onMutate);
    });

    Future.microtask(() async {
      if (state.data == null) {
        final diskRaw = await SwrCache.instance.get(cacheKey);
        if (diskRaw != null) {
          try {
            final diskData = decoder != null ? decoder!(diskRaw) : (diskRaw as T?);
            if (diskData != null && state.data == null) {
              state = state.copyWith(
                data: diskData,
                isLoading: false,
                isRevalidating: true,
              );
            }
          } catch (_) {}
        }
      }
      await revalidate();
    });

    return initialState;
  }

  Future<void> revalidate() async {
    if (_isRevalidating) return;
    _isRevalidating = true;
    state = state.copyWith(isRevalidating: true);
    debugPrint('[SWR] Revalidating "$key"...');

    try {
      final fresh = await fetcher(ref, arg);
      final raw = encoder != null ? encoder!(fresh) : fresh;
      await SwrCache.instance.set(key, raw);
      state = state.copyWith(
        data: fresh,
        isLoading: false,
        isRevalidating: false,
        clearError: true,
      );
      debugPrint('[SWR] Successfully revalidated "$key"');
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        debugPrint('[SWR] Revalidation cancelled for "$key"');
        state = state.copyWith(isRevalidating: false);
        return;
      }
      debugPrint('[SWR] Error revalidating "$key": $e');
      state = state.copyWith(
        isLoading: false,
        isRevalidating: false,
        error: e,
      );
    } finally {
      _isRevalidating = false;
    }
  }

  Future<void> mutate([T? freshData]) async {
    if (freshData != null) {
      state = state.copyWith(
        data: freshData,
        isLoading: false,
        clearError: true,
      );
      final raw = encoder != null ? encoder!(freshData) : freshData;
      await SwrCache.instance.set(key, raw);
      SwrEventBus.instance.emit(key, freshData);
    } else {
      await revalidate();
    }
  }
}
