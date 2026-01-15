import 'package:hive_flutter/hive_flutter.dart';
import '../models/wallet_dto.dart';

/// Cache service for wallets with 1-hour TTL
class WalletCacheService {
  static const String _boxName = 'wallets_cache';
  static const String _walletsKey = 'wallets_list';
  static const String _timestampKey = 'wallets_timestamp';
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

  /// Get cached wallets if still valid
  Future<List<WalletDto>?> getWallets() async {
    final box = await _getBox;
    
    final timestamp = box.get(_timestampKey) as String?;
    if (timestamp == null) return null;

    final cachedAt = DateTime.parse(timestamp);
    final isExpired = DateTime.now().difference(cachedAt) > _ttl;
    
    if (isExpired) {
      await clear();
      return null;
    }

    final walletsData = box.get(_walletsKey) as List<dynamic>?;
    if (walletsData == null) return null;

    return walletsData.cast<WalletDto>();
  }

  /// Cache wallets list
  Future<void> saveWallets(List<WalletDto> wallets) async {
    final box = await _getBox;
    await box.put(_walletsKey, wallets);
    await box.put(_timestampKey, DateTime.now().toIso8601String());
  }

  /// Get cached wallet by ID
  Future<WalletDto?> getWalletById(int id) async {
    final wallets = await getWallets();
    if (wallets == null) return null;
    
    try {
      return wallets.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if cache is valid
  Future<bool> isValid() async {
    final box = await _getBox;
    final timestamp = box.get(_timestampKey) as String?;
    if (timestamp == null) return false;

    final cachedAt = DateTime.parse(timestamp);
    return DateTime.now().difference(cachedAt) <= _ttl;
  }

  /// Get cache age
  Future<Duration?> getCacheAge() async {
    final box = await _getBox;
    final timestamp = box.get(_timestampKey) as String?;
    if (timestamp == null) return null;

    final cachedAt = DateTime.parse(timestamp);
    return DateTime.now().difference(cachedAt);
  }

  /// Clear wallet cache
  Future<void> clear() async {
    final box = await _getBox;
    await box.clear();
  }

  /// Invalidate cache (forces refetch on next request)
  Future<void> invalidate() async {
    await clear();
  }
}
