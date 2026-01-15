/// Wrapper class for cached data with timestamp and TTL support
/// Note: This is a simple model without Hive annotations
/// Cache services handle timestamp storage directly
class CachedData<T> {
  final T data;
  final DateTime cachedAt;

  const CachedData({
    required this.data,
    required this.cachedAt,
  });

  /// Check if the cached data is still valid based on TTL
  bool isValid(Duration ttl) {
    return DateTime.now().difference(cachedAt) < ttl;
  }

  /// Check if the cached data is expired
  bool isExpired(Duration ttl) {
    return !isValid(ttl);
  }

  /// Get the age of the cached data
  Duration get age => DateTime.now().difference(cachedAt);

  /// Create a new CachedData with current timestamp
  static CachedData<T> now<T>(T data) {
    return CachedData(
      data: data,
      cachedAt: DateTime.now(),
    );
  }
}
