typedef SwrListener = void Function(dynamic freshData);

class SwrEventBus {
  static final SwrEventBus instance = SwrEventBus._internal();
  SwrEventBus._internal();

  final Map<String, Set<SwrListener>> _listeners = {};

  void addListener(String key, SwrListener listener) {
    _listeners.putIfAbsent(key, () => <SwrListener>{}).add(listener);
  }

  void removeListener(String key, SwrListener listener) {
    final set = _listeners[key];
    if (set != null) {
      set.deleteOrRemove(listener);
      if (set.isEmpty) {
        _listeners.remove(key);
      }
    }
  }

  void emit(String key, [dynamic freshData]) {
    if (key.endsWith('*')) {
      final prefix = key.substring(0, key.length - 1);
      final entries = _listeners.entries.where((e) => e.key.startsWith(prefix)).toList();
      for (final entry in entries) {
        final activeListeners = List<SwrListener>.from(entry.value);
        for (final listener in activeListeners) {
          listener(freshData);
        }
      }
      return;
    }

    final set = _listeners[key];
    if (set != null && set.isNotEmpty) {
      final activeListeners = List<SwrListener>.from(set);
      for (final listener in activeListeners) {
        listener(freshData);
      }
    }
  }

  void clear() {
    _listeners.clear();
  }
}

extension _SetRemoveExt<E> on Set<E> {
  void deleteOrRemove(E value) => remove(value);
}
