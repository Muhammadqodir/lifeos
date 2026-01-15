import 'package:hive_flutter/hive_flutter.dart';

/// Base class for cache services with TTL support
abstract class CacheService<T> {
  final String boxName;
  final Duration ttl;
  Box<T>? _box;

  CacheService({
    required this.boxName,
    required this.ttl,
  });

  /// Initialize the Hive box
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<T>(boxName);
    }
  }

  /// Get the Hive box (ensures it's initialized)
  Future<Box<T>> get box async {
    await init();
    return _box!;
  }

  /// Get cached data by key
  Future<T?> get(String key) async {
    final b = await box;
    return b.get(key);
  }

  /// Set cached data by key
  Future<void> set(String key, T value) async {
    final b = await box;
    await b.put(key, value);
  }

  /// Delete cached data by key
  Future<void> delete(String key) async {
    final b = await box;
    await b.delete(key);
  }

  /// Clear all cached data
  Future<void> clear() async {
    final b = await box;
    await b.clear();
  }

  /// Get all keys in the cache
  Future<Iterable<String>> getKeys() async {
    final b = await box;
    return b.keys.cast<String>();
  }

  /// Get cache size (number of items)
  Future<int> size() async {
    final b = await box;
    return b.length;
  }

  /// Check if cache contains a key
  Future<bool> contains(String key) async {
    final b = await box;
    return b.containsKey(key);
  }

  /// Close the box
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}

/// Cache service for list data with TTL
class ListCacheService<T> extends CacheService<List<T>> {
  ListCacheService({
    required super.boxName,
    required super.ttl,
  });

  /// Get cached list with TTL validation
  Future<List<T>?> getList(String key) async {
    final cached = await get(key);
    if (cached == null) return null;
    return cached;
  }

  /// Set cached list
  Future<void> setList(String key, List<T> data) async {
    await set(key, data);
  }
}

/// Cache service for single items with TTL metadata
class ItemCacheService<T> extends CacheService<Map<String, dynamic>> {
  ItemCacheService({
    required super.boxName,
    required super.ttl,
  });

  /// Get item with TTL validation
  Future<CachedItem<T>?> getItem(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final cached = await get(key);
    if (cached == null) return null;

    final cachedAt = DateTime.parse(cached['cachedAt'] as String);
    final isValid = DateTime.now().difference(cachedAt) < ttl;

    return CachedItem(
      data: fromJson(cached['data'] as Map<String, dynamic>),
      cachedAt: cachedAt,
      isValid: isValid,
    );
  }

  /// Set item with timestamp
  Future<void> setItem(String key, Map<String, dynamic> data) async {
    await set(key, {
      'data': data,
      'cachedAt': DateTime.now().toIso8601String(),
    });
  }
}

/// Helper class for cached items
class CachedItem<T> {
  final T data;
  final DateTime cachedAt;
  final bool isValid;

  CachedItem({
    required this.data,
    required this.cachedAt,
    required this.isValid,
  });

  Duration get age => DateTime.now().difference(cachedAt);
}
