import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_category_dto.dart';

/// Cache service for transaction categories with 1-hour TTL
class CategoryCacheService {
  static const String _boxName = 'categories_cache';
  static const String _incomeCategoriesKey = 'income_categories';
  static const String _expenseCategoriesKey = 'expense_categories';
  static const String _incomeTimestampKey = 'income_timestamp';
  static const String _expenseTimestampKey = 'expense_timestamp';
  static const Duration _ttl = Duration(hours: 1);

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

  /// Get cached income categories if still valid
  Future<List<TransactionCategoryDto>?> getIncomeCategories() async {
    return _getCategories(_incomeCategoriesKey, _incomeTimestampKey);
  }

  /// Get cached expense categories if still valid
  Future<List<TransactionCategoryDto>?> getExpenseCategories() async {
    return _getCategories(_expenseCategoriesKey, _expenseTimestampKey);
  }

  /// Generic method to get categories
  Future<List<TransactionCategoryDto>?> _getCategories(
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

    final categoriesData = box.get(dataKey) as List<dynamic>?;
    if (categoriesData == null) return null;

    return categoriesData.cast<TransactionCategoryDto>();
  }

  /// Cache income categories
  Future<void> saveIncomeCategories(
    List<TransactionCategoryDto> categories,
  ) async {
    await _saveCategories(
      categories,
      _incomeCategoriesKey,
      _incomeTimestampKey,
    );
  }

  /// Cache expense categories
  Future<void> saveExpenseCategories(
    List<TransactionCategoryDto> categories,
  ) async {
    await _saveCategories(
      categories,
      _expenseCategoriesKey,
      _expenseTimestampKey,
    );
  }

  /// Generic method to save categories
  Future<void> _saveCategories(
    List<TransactionCategoryDto> categories,
    String dataKey,
    String timestampKey,
  ) async {
    final box = await _getBox;
    await box.put(dataKey, categories);
    await box.put(timestampKey, DateTime.now().toIso8601String());
  }

  /// Check if income categories cache is valid
  Future<bool> isIncomeValid() async {
    return _isValid(_incomeTimestampKey);
  }

  /// Check if expense categories cache is valid
  Future<bool> isExpenseValid() async {
    return _isValid(_expenseTimestampKey);
  }

  /// Generic method to check validity
  Future<bool> _isValid(String timestampKey) async {
    final box = await _getBox;
    final timestamp = box.get(timestampKey) as String?;
    if (timestamp == null) return false;

    final cachedAt = DateTime.parse(timestamp);
    return DateTime.now().difference(cachedAt) <= _ttl;
  }

  /// Get category by ID from cache
  Future<TransactionCategoryDto?> getCategoryById(int id) async {
    // Try income categories first
    final incomeCategories = await getIncomeCategories();
    if (incomeCategories != null) {
      try {
        return incomeCategories.firstWhere((c) => c.id == id);
      } catch (e) {
        // Not found in income, continue to expense
      }
    }

    // Try expense categories
    final expenseCategories = await getExpenseCategories();
    if (expenseCategories != null) {
      try {
        return expenseCategories.firstWhere((c) => c.id == id);
      } catch (e) {
        // Not found
      }
    }

    return null;
  }

  /// Clear all category caches
  Future<void> clear() async {
    final box = await _getBox;
    await box.clear();
  }

  /// Invalidate all caches
  Future<void> invalidate() async {
    await clear();
  }
}
