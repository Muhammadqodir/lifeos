import 'package:hive_flutter/hive_flutter.dart';

/// Cache manager for global cache operations
class CacheManager {
  /// Clear all finance-related caches
  static Future<void> clearFinanceCaches() async {
    await Future.wait([
      Hive.box('wallets_cache').clear().catchError((_) => 0),
      Hive.box('categories_cache').clear().catchError((_) => 0),
      Hive.box('currencies_cache').clear().catchError((_) => 0),
    ]);
  }

  /// Clear all caches in the app
  static Future<void> clearAllCaches() async {
    final boxes = [
      'wallets_cache',
      'categories_cache',
      'currencies_cache',
    ];
    await Future.wait(
      boxes.map((name) => 
        Hive.openBox(name).then((box) => box.clear()).catchError((_) => 0)
      ),
    );
  }

  /// Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    final stats = <String, dynamic>{};

    try {
      final walletsBox = Hive.box('wallets_cache');
      stats['wallets'] = {
        'size': walletsBox.length,
        'timestamp': walletsBox.get('wallets_timestamp'),
      };
    } catch (e) {
      stats['wallets'] = {'size': 0};
    }

    try {
      final categoriesBox = Hive.box('categories_cache');
      stats['categories'] = {
        'size': categoriesBox.length,
        'income_timestamp': categoriesBox.get('income_timestamp'),
        'expense_timestamp': categoriesBox.get('expense_timestamp'),
      };
    } catch (e) {
      stats['categories'] = {'size': 0};
    }

    try {
      final currenciesBox = Hive.box('currencies_cache');
      stats['currencies'] = {
        'size': currenciesBox.length,
        'user_timestamp': currenciesBox.get('user_timestamp'),
        'all_timestamp': currenciesBox.get('all_timestamp'),
      };
    } catch (e) {
      stats['currencies'] = {'size': 0};
    }

    return stats;
  }

  /// Delete all expired cache entries across all boxes
  static Future<void> clearExpiredCaches() async {
    // Note: Individual cache services handle TTL validation
    // This is a placeholder for future implementation
    // where we might want to actively delete expired entries
  }
}
