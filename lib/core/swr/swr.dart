import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'swr_cache.dart';
import 'swr_event_bus.dart';
import 'swr_provider.dart';
import 'swr_state.dart';

export 'swr_cache.dart';
export 'swr_event_bus.dart';
export 'swr_provider.dart';
export 'swr_screen_mixin.dart';
export 'swr_state.dart';

class Swr {
  Swr._();

  /// Initialize the SWR persistent cache (e.g. in main.dart)
  static Future<void> init() async {
    await SwrCache.instance.init();
  }

  /// Mutates SWR cache and triggers update for all active subscribers.
  ///
  /// - If [key] ends with `*` (e.g. `'planned-chores:*'`), clears all matching keys
  ///   from local storage and tells active subscribers to re-fetch in the background.
  /// - If [data] is provided: saves data into local storage immediately and
  ///   updates active subscribers with this data (optimistic UI).
  /// - If [data] is omitted: triggers background revalidation for active subscribers.
  static Future<void> mutate<T>(
    String key, [
    T? data,
    dynamic Function(T data)? encoder,
  ]) async {
    if (key.endsWith('*')) {
      final prefix = key.substring(0, key.length - 1);
      await SwrCache.instance.clearPrefix(prefix);
      SwrEventBus.instance.emit(key, data);
      return;
    }

    if (data != null) {
      final raw = encoder != null ? encoder(data) : data;
      await SwrCache.instance.set(key, raw);
    }

    SwrEventBus.instance.emit(key, data);
  }

  /// Wipes all cached SWR data and listeners (e.g. on user logout).
  static Future<void> clearAll() async {
    await SwrCache.instance.clearAll();
    SwrEventBus.instance.clear();
  }
}

/// Helper function to define a simple SWR provider
NotifierProvider<SwrNotifier<T>, SWRState<T>> createSwrProvider<T>({
  required String key,
  required SwrFetcher<T> fetcher,
  SwrDecoder<T>? decoder,
  SwrEncoder<T>? encoder,
}) {
  return NotifierProvider<SwrNotifier<T>, SWRState<T>>(
    () => SwrNotifier<T>(
      key: key,
      fetcher: fetcher,
      decoder: decoder,
      encoder: encoder,
    ),
  );
}

/// Helper class to define an SWR family provider parameterized by [Arg]
class SwrFamily<T, Arg> {
  final String Function(Arg arg) key;
  final SwrFamilyFetcher<T, Arg> fetcher;
  final SwrDecoder<T>? decoder;
  final SwrEncoder<T>? encoder;

  final Map<Arg, NotifierProvider<FamilySwrNotifier<T, Arg>, SWRState<T>>> _cache = {};

  SwrFamily({
    required this.key,
    required this.fetcher,
    this.decoder,
    this.encoder,
  });

  NotifierProvider<FamilySwrNotifier<T, Arg>, SWRState<T>> call(Arg arg) {
    return _cache.putIfAbsent(
      arg,
      () => NotifierProvider<FamilySwrNotifier<T, Arg>, SWRState<T>>(
        () => FamilySwrNotifier<T, Arg>(
          keyBuilder: key,
          fetcher: fetcher,
          decoder: decoder,
          encoder: encoder,
          arg: arg,
        ),
      ),
    );
  }
}

/// Factory function to create an [SwrFamily]
SwrFamily<T, Arg> createSwrFamily<T, Arg>({
  required String Function(Arg arg) key,
  required SwrFamilyFetcher<T, Arg> fetcher,
  SwrDecoder<T>? decoder,
  SwrEncoder<T>? encoder,
}) {
  return SwrFamily<T, Arg>(
    key: key,
    fetcher: fetcher,
    decoder: decoder,
    encoder: encoder,
  );
}
