import 'package:hive_flutter/hive_flutter.dart';
import '../models/currency_dto.dart';

/// Cache service for currencies with 24-hour TTL (rarely change)
class CurrencyCacheService {
  static const String _boxName = 'currencies_cache';
  static const String _userCurrenciesKey = 'user_currencies';
  static const String _allCurrenciesKey = 'all_currencies';
  static const String _userTimestampKey = 'user_timestamp';
  static const String _allTimestampKey = 'all_timestamp';
  static const Duration _ttl = Duration(hours: 24);

  Box<dynamic>? _box;

  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
  }

  Future<Box<dynamic>> get _getBox async {
    await init();
    return _box!;
  }

  /// Get cached user currencies if still valid
  Future<List<CurrencyDto>?> getUserCurrencies() async {
    return _getCurrencies(_userCurrenciesKey, _userTimestampKey);
  }

  /// Get cached all currencies if still valid
  Future<List<CurrencyDto>?> getAllCurrencies() async {
    return _getCurrencies(_allCurrenciesKey, _allTimestampKey);
  }

  /// Generic method to get currencies
  Future<List<CurrencyDto>?> _getCurrencies(
    String dataKey,
    String timestampKey,
  ) async {
    final box = await _getBox;
    
    final timestamp = box.get(timestampKey) as String?;
    if (timestamp == null) return null;

    final cachedAt = DateTime.parse(timestamp);
    final isExpired = DateTime.now().difference(cachedAt) > _ttl;
    
    if (isExpired) {
      await box.delete(dataKey);
      await box.delete(timestampKey);
      return null;
    }

    final currenciesData = box.get(dataKey) as List<dynamic>?;
    if (currenciesData == null) return null;

    return currenciesData.cast<CurrencyDto>();
  }

  /// Cache user currencies
  Future<void> saveUserCurrencies(List<CurrencyDto> currencies) async {
    await _saveCurrencies(
      currencies,
      _userCurrenciesKey,
      _userTimestampKey,
    );
  }

  /// Cache all currencies
  Future<void> saveAllCurrencies(List<CurrencyDto> currencies) async {
    await _saveCurrencies(
      currencies,
      _allCurrenciesKey,
      _allTimestampKey,
    );
  }

  /// Generic method to save currencies
  Future<void> _saveCurrencies(
    List<CurrencyDto> currencies,
    String dataKey,
    String timestampKey,
  ) async {
    final box = await _getBox;
    await box.put(dataKey, currencies);
    await box.put(timestampKey, DateTime.now().toIso8601String());
  }

  /// Check if user currencies cache is valid
  Future<bool> isUserCurrenciesValid() async {
    return _isValid(_userTimestampKey);
  }

  /// Check if all currencies cache is valid
  Future<bool> isAllCurrenciesValid() async {
    return _isValid(_allTimestampKey);
  }

  /// Generic method to check validity
  Future<bool> _isValid(String timestampKey) async {
    final box = await _getBox;
    final timestamp = box.get(timestampKey) as String?;
    if (timestamp == null) return false;

    final cachedAt = DateTime.parse(timestamp);
    return DateTime.now().difference(cachedAt) <= _ttl;
  }

  /// Get currency by ID from cache
  Future<CurrencyDto?> getCurrencyById(int id) async {
    // Try user currencies first
    final userCurrencies = await getUserCurrencies();
    if (userCurrencies != null) {
      try {
        return userCurrencies.firstWhere((c) => c.id == id);
      } catch (e) {
        // Not found in user currencies, try all
      }
    }

    // Try all currencies
    final allCurrencies = await getAllCurrencies();
    if (allCurrencies != null) {
      try {
        return allCurrencies.firstWhere((c) => c.id == id);
      } catch (e) {
        // Not found
      }
    }

    return null;
  }

  /// Clear all currency caches
  Future<void> clear() async {
    final box = await _getBox;
    await box.clear();
  }

  /// Invalidate all caches
  Future<void> invalidate() async {
    await clear();
  }
}
