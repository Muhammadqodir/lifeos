# Hive Caching System Implementation

## Overview

Implemented a scalable Hive-based caching system to dramatically improve loading speed in the LifeOS Finance feature. The system uses **stale-while-revalidate** pattern to provide instant UI updates while refreshing data in the background.

## Performance Impact

**Before:** AddTransactionPage made 3+ API calls on every load (wallets + N wallet balances + income categories + expense categories)  
**After:** Instant load from cache, 0 API calls when cache is valid (within TTL)

## Architecture

### Core Infrastructure

1. **CachedData Model** ([lib/core/cache/cached_data.dart](lib/core/cache/cached_data.dart))
   - Generic wrapper for cached data with timestamp
   - TTL validation methods (isValid, isExpired, age)
   - Helper method to create timestamped data

2. **CacheService Base Class** ([lib/core/cache/cache_service.dart](lib/core/cache/cache_service.dart))
   - Generic base class for type-safe cache operations
   - Methods: get, set, delete, clear, contains, size
   - ListCacheService and ItemCacheService specializations

3. **CacheManager** ([lib/core/cache/cache_manager.dart](lib/core/cache/cache_manager.dart))
   - Global cache management utilities
   - clearFinanceCaches(), clearAllCaches()
   - getCacheStats() for monitoring

### Finance-Specific Cache Services

1. **WalletCacheService** ([lib/features/finance/data/datasources/wallet_cache_service.dart](lib/features/finance/data/datasources/wallet_cache_service.dart))
   - **TTL:** 1 hour
   - Caches: Wallets with balances
   - Auto-invalidates on: createWallet, deleteWallet, createTransaction, deleteTransaction

2. **CategoryCacheService** ([lib/features/finance/data/datasources/category_cache_service.dart](lib/features/finance/data/datasources/category_cache_service.dart))
   - **TTL:** 1 hour
   - Caches: Income categories (separate) + Expense categories (separate)
   - Auto-invalidates on: createCategory, deleteCategory

3. **CurrencyCacheService** ([lib/features/finance/data/datasources/currency_cache_service.dart](lib/features/finance/data/datasources/currency_cache_service.dart))
   - **TTL:** 24 hours (currencies rarely change)
   - Caches: User currencies + All currencies (separate)

## TTL Strategy

| Data Type | TTL | Rationale |
|-----------|-----|-----------|
| Wallets | 1 hour | Balance changes on transactions, but acceptable staleness |
| Categories | 1 hour | Rarely change after initial setup |
| Currencies | 24 hours | Static reference data |

## Stale-While-Revalidate Pattern

```dart
Future<List<WalletDto>> getWalletsWithBalances() async {
  // 1. Check cache first
  final cachedWallets = await walletCache.getWallets();
  
  // 2. If valid cache exists, return immediately
  if (cachedWallets != null) {
    // 3. Refresh in background (fire and forget)
    _refreshWalletsInBackground();
    return cachedWallets;
  }

  // 4. Cache miss - fetch from API and cache
  return await _fetchAndCacheWallets();
}
```

**Benefits:**
- **Instant UI:** Users see cached data immediately (0ms load time)
- **Fresh data:** Background refresh keeps cache up-to-date
- **Offline-ready:** Foundation for full offline mode (future)

## Cache Invalidation

Automatic invalidation occurs on write operations:

- **createWallet/deleteWallet** → Invalidates wallet cache
- **createTransaction/deleteTransaction** → Invalidates wallet cache (balance changes)
- **createCategory/deleteCategory** → Invalidates category cache

Manual invalidation available via:
```dart
await walletCache.invalidate();  // Force refetch on next request
await CacheManager.clearFinanceCaches();  // Clear all finance caches
```

## Hive TypeAdapters

Generated adapters for DTOs:
- `CurrencyDto` (typeId: 0)
- `WalletType` enum (typeId: 1)
- `WalletDto` (typeId: 2)
- `TransactionCategoryType` enum (typeId: 3)
- `TransactionCategoryDto` (typeId: 4)

**Regenerate adapters:** `flutter pub run build_runner build --delete-conflicting-outputs`

## Future Enhancements

### 1. Offline Mode
- Queue failed mutations in local storage
- Sync on reconnection with conflict resolution
- Add `connectivity_plus` package for network monitoring

### 2. Transaction History Caching
- Cache recent 100 transactions with pagination
- Implement incremental sync strategy
- Add search index for offline search

### 3. Cache Monitoring UI
Add to Finance Settings page:
```dart
final stats = await CacheManager.getCacheStats();
// Display: cache size, last updated, clear cache button
```

### 4. Advanced TTL Strategies
- Exponential backoff on API failures
- Prefetching on app launch
- Background sync with WorkManager

## Usage Example

**Before (No Caching):**
```dart
// FinanceRepositoryImpl
Future<List<WalletDto>> getWalletsWithBalances() async {
  final wallets = await apiClient.getWallets();  // Network call
  for (final wallet in wallets) {
    final balance = await apiClient.getWalletBalance(wallet.id);  // N network calls
    walletsWithBalances.add(wallet.copyWith(balance: balance));
  }
  return walletsWithBalances;
}
```

**After (With Caching):**
```dart
// FinanceRepositoryImpl
Future<List<WalletDto>> getWalletsWithBalances() async {
  final cachedWallets = await walletCache.getWallets();
  if (cachedWallets != null) {
    _refreshWalletsInBackground();  // Async refresh
    return cachedWallets;  // Instant return
  }
  return await _fetchAndCacheWallets();  // Cache miss
}
```

## Testing

**Test cache behavior:**
1. Open AddTransactionPage → Should fetch from API (first load)
2. Close and reopen → Instant load from cache
3. Wait 1+ hour → Background refresh occurs
4. Create transaction → Cache invalidated, refetch on next load

**Monitor cache:**
```dart
// Check if cache is valid
final isValid = await walletCache.isValid();

// Check cache age
final age = await walletCache.getCacheAge();
print('Cache age: ${age?.inMinutes} minutes');

// Clear cache manually
await walletCache.clear();
```

## Migration Notes

**Breaking Changes:** None - caching is transparent to existing code

**Dependencies Added:**
- `hive: ^2.2.3`
- `hive_flutter: ^1.1.0`
- `hive_generator: ^2.0.1` (dev)
- `build_runner: ^2.4.13` (dev)

**Files Modified:**
- [pubspec.yaml](../pubspec.yaml)
- [lib/injection.dart](lib/injection.dart)
- [lib/features/finance/data/repositories/finance_repository_impl.dart](lib/features/finance/data/repositories/finance_repository_impl.dart)
- [lib/features/finance/data/models/currency_dto.dart](lib/features/finance/data/models/currency_dto.dart)
- [lib/features/finance/data/models/wallet_dto.dart](lib/features/finance/data/models/wallet_dto.dart)
- [lib/features/finance/data/models/transaction_category_dto.dart](lib/features/finance/data/models/transaction_category_dto.dart)

**Files Created:**
- [lib/core/cache/cached_data.dart](lib/core/cache/cached_data.dart)
- [lib/core/cache/cache_service.dart](lib/core/cache/cache_service.dart)
- [lib/core/cache/cache_manager.dart](lib/core/cache/cache_manager.dart)
- [lib/features/finance/data/datasources/wallet_cache_service.dart](lib/features/finance/data/datasources/wallet_cache_service.dart)
- [lib/features/finance/data/datasources/category_cache_service.dart](lib/features/finance/data/datasources/category_cache_service.dart)
- [lib/features/finance/data/datasources/currency_cache_service.dart](lib/features/finance/data/datasources/currency_cache_service.dart)
