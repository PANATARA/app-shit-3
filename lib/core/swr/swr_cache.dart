import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwrCache {
  static const String _keyPrefix = 'swr:';
  static const int defaultTtlMs = 7 * 24 * 60 * 60 * 1000; // 7 days

  static final SwrCache instance = SwrCache._internal();
  SwrCache._internal();

  SharedPreferences? _prefs;
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, int> _memoryTs = {};

  Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      _warmMemoryCache();
    } catch (e) {
      debugPrint('[SwrCache] init error: $e');
    }
  }

  void _warmMemoryCache() {
    if (_prefs == null) return;
    final keys = _prefs!.getKeys();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final fullKey in keys) {
      if (fullKey.startsWith(_keyPrefix)) {
        final key = fullKey.substring(_keyPrefix.length);
        final raw = _prefs!.getString(fullKey);
        if (raw != null) {
          try {
            final entry = jsonDecode(raw) as Map<String, dynamic>;
            final ts = (entry['ts'] as num?)?.toInt() ?? 0;
            if (now - ts <= defaultTtlMs) {
              _memoryCache[key] = entry['data'];
              _memoryTs[key] = ts;
            } else {
              _prefs!.remove(fullKey);
            }
          } catch (_) {
            _prefs!.remove(fullKey);
          }
        }
      }
    }
  }

  dynamic getSync(String key) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final ts = _memoryTs[key];
    if (ts != null && now - ts <= defaultTtlMs) {
      return _memoryCache[key];
    }
    return null;
  }

  Future<dynamic> get(String key) async {
    final syncData = getSync(key);
    if (syncData != null) return syncData;

    try {
      _prefs ??= await SharedPreferences.getInstance();
      final fullKey = '$_keyPrefix$key';
      final raw = _prefs!.getString(fullKey);
      if (raw == null) return null;

      final entry = jsonDecode(raw) as Map<String, dynamic>;
      final ts = (entry['ts'] as num?)?.toInt() ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - ts > defaultTtlMs) {
        await _prefs!.remove(fullKey);
        _memoryCache.remove(key);
        _memoryTs.remove(key);
        return null;
      }

      final data = entry['data'];
      _memoryCache[key] = data;
      _memoryTs[key] = ts;
      return data;
    } catch (e) {
      debugPrint('[SwrCache] get error: $e');
      return null;
    }
  }

  Future<void> set(String key, dynamic data) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    _memoryCache[key] = data;
    _memoryTs[key] = now;

    try {
      _prefs ??= await SharedPreferences.getInstance();
      final fullKey = '$_keyPrefix$key';
      final payload = jsonEncode({'data': data, 'ts': now});
      await _prefs!.setString(fullKey, payload);
    } catch (e) {
      debugPrint('[SwrCache] set error: $e');
    }
  }

  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    _memoryTs.remove(key);

    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.remove('$_keyPrefix$key');
    } catch (e) {
      debugPrint('[SwrCache] remove error: $e');
    }
  }

  Future<void> clearPrefix(String prefix) async {
    final cleanPrefix = prefix.endsWith('*') ? prefix.substring(0, prefix.length - 1) : prefix;

    _memoryCache.removeWhere((k, _) => k.startsWith(cleanPrefix));
    _memoryTs.removeWhere((k, _) => k.startsWith(cleanPrefix));

    try {
      _prefs ??= await SharedPreferences.getInstance();
      final keys = _prefs!.getKeys();
      final fullPrefix = '$_keyPrefix$cleanPrefix';

      for (final k in keys) {
        if (k.startsWith(fullPrefix)) {
          await _prefs!.remove(k);
        }
      }
    } catch (e) {
      debugPrint('[SwrCache] clearPrefix error: $e');
    }
  }

  Future<void> clearAll() async {
    _memoryCache.clear();
    _memoryTs.clear();

    try {
      _prefs ??= await SharedPreferences.getInstance();
      final keys = _prefs!.getKeys().where((k) => k.startsWith(_keyPrefix)).toList();
      for (final k in keys) {
        await _prefs!.remove(k);
      }
    } catch (e) {
      debugPrint('[SwrCache] clearAll error: $e');
    }
  }
}
