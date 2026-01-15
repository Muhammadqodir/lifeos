import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_api_client.dart';
import '../datasources/wallet_cache_service.dart';
import '../datasources/category_cache_service.dart';
import '../datasources/currency_cache_service.dart';
import '../models/wallet_dto.dart';
import '../models/transaction_dto.dart';
import '../models/finance_summary_dto.dart';
import '../models/currency_dto.dart';
import '../models/transaction_category_dto.dart';
import '../models/create_transaction_dto.dart';
import '../models/analytics_summary_dto.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceApiClient apiClient;
  final WalletCacheService walletCache;
  final CategoryCacheService categoryCache;
  final CurrencyCacheService currencyCache;

  FinanceRepositoryImpl({
    required this.apiClient,
    required this.walletCache,
    required this.categoryCache,
    required this.currencyCache,
  });

  @override
  Future<List<WalletDto>> getWallets() async {
    return await apiClient.getWallets();
  }

  @override
  Future<WalletDto> getWalletWithBalance(int walletId) async {
    final wallets = await apiClient.getWallets();
    final wallet = wallets.firstWhere((w) => w.id == walletId);
    final balance = await apiClient.getWalletBalance(walletId);
    return wallet.copyWith(balance: balance);
  }

  @override
  Future<List<WalletDto>> getWalletsWithBalances() async {
    // Try to get from cache first
    final cachedWallets = await walletCache.getWallets();
    
    // If cache is valid, return immediately and refresh in background
    if (cachedWallets != null) {
      // Refresh in background (fire and forget)
      _refreshWalletsInBackground();
      return cachedWallets;
    }

    // Cache miss - fetch from API and cache
    return await _fetchAndCacheWallets();
  }

  Future<void> _refreshWalletsInBackground() async {
    try {
      await _fetchAndCacheWallets();
    } catch (e) {
      // Silent fail - user already has cached data
    }
  }

  Future<List<WalletDto>> _fetchAndCacheWallets() async {
    final wallets = await apiClient.getWallets();
    final walletsWithBalances = <WalletDto>[];

    for (final wallet in wallets) {
      try {
        final balance = await apiClient.getWalletBalance(wallet.id);
        walletsWithBalances.add(wallet.copyWith(balance: balance));
      } catch (e) {
        // If balance fetch fails, add wallet with null balance
        walletsWithBalances.add(wallet);
      }
    }

    // Cache the result
    await walletCache.saveWallets(walletsWithBalances);

    return walletsWithBalances;
  }

  @override
  Future<TransactionListResponseDto> getTransactions({
    int page = 1,
    int perPage = 20,
    String? type,
    int? walletId,
    int? categoryId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? searchQuery,
  }) async {
    return await apiClient.getTransactions(
      page: page,
      perPage: perPage,
      type: type,
      walletId: walletId,
      categoryId: categoryId,
      dateFrom: dateFrom,
      dateTo: dateTo,
      searchQuery: searchQuery,
    );
  }

  @override
  Future<FinanceSummaryDto> getFinanceSummary() async {
    return await apiClient.getFinanceSummary();
  }

  @override
  Future<List<CurrencyDto>> getUserCurrencies() async {
    // Try to get from cache first
    final cachedCurrencies = await currencyCache.getUserCurrencies();
    
    // If cache is valid, return immediately and refresh in background
    if (cachedCurrencies != null) {
      // Refresh in background (fire and forget)
      _refreshUserCurrenciesInBackground();
      return cachedCurrencies;
    }

    // Cache miss - fetch from API and cache
    return await _fetchAndCacheUserCurrencies();
  }

  Future<void> _refreshUserCurrenciesInBackground() async {
    try {
      await _fetchAndCacheUserCurrencies();
    } catch (e) {
      // Silent fail - user already has cached data
    }
  }

  Future<List<CurrencyDto>> _fetchAndCacheUserCurrencies() async {
    final currencies = await apiClient.getUserCurrencies();
    await currencyCache.saveUserCurrencies(currencies);
    return currencies;
  }

  @override
  Future<WalletDto> createWallet({
    required String name,
    required int currencyId,
    required String type,
    bool isActive = true,
  }) async {
    final wallet = await apiClient.createWallet(
      name: name,
      currencyId: currencyId,
      type: type,
      isActive: isActive,
    );
    
    // Invalidate wallet cache after creating new wallet
    await walletCache.invalidate();
    
    return wallet;
  }

  @override
  Future<void> deleteWallet(int walletId) async {
    await apiClient.deleteWallet(walletId);
    
    // Invalidate wallet cache after deleting
    await walletCache.invalidate();
  }

  @override
  Future<List<TransactionCategoryDto>> getTransactionCategories({
    String? type,
  }) async {
    // Determine which cache to use based on type
    if (type == 'income') {
      final cachedCategories = await categoryCache.getIncomeCategories();
      if (cachedCategories != null) {
        _refreshIncomeCategoriesInBackground();
        return cachedCategories;
      }
      return await _fetchAndCacheIncomeCategories();
    } else if (type == 'expense') {
      final cachedCategories = await categoryCache.getExpenseCategories();
      if (cachedCategories != null) {
        _refreshExpenseCategoriesInBackground();
        return cachedCategories;
      }
      return await _fetchAndCacheExpenseCategories();
    }

    // If no type specified, fetch from API (don't cache mixed results)
    return await apiClient.getTransactionCategories(type: type);
  }

  Future<void> _refreshIncomeCategoriesInBackground() async {
    try {
      await _fetchAndCacheIncomeCategories();
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _refreshExpenseCategoriesInBackground() async {
    try {
      await _fetchAndCacheExpenseCategories();
    } catch (e) {
      // Silent fail
    }
  }

  Future<List<TransactionCategoryDto>> _fetchAndCacheIncomeCategories() async {
    final categories = await apiClient.getTransactionCategories(type: 'income');
    await categoryCache.saveIncomeCategories(categories);
    return categories;
  }

  Future<List<TransactionCategoryDto>> _fetchAndCacheExpenseCategories() async {
    final categories = await apiClient.getTransactionCategories(type: 'expense');
    await categoryCache.saveExpenseCategories(categories);
    return categories;
  }

  @override
  Future<TransactionDto> createTransaction(
    CreateTransactionRequestDto request,
  ) async {
    final transaction = await apiClient.createTransaction(request);
    
    // Invalidate wallet cache after creating transaction (balance changes)
    await walletCache.invalidate();
    
    return transaction;
  }

  @override
  Future<void> deleteTransaction(int transactionId) async {
    await apiClient.deleteTransaction(transactionId);
    
    // Invalidate wallet cache after deleting transaction (balance changes)
    await walletCache.invalidate();
  }

  @override
  Future<AnalyticsSummaryDto> getAnalytics({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? currencyId,
  }) async {
    return await apiClient.getAnalytics(
      dateFrom: dateFrom,
      dateTo: dateTo,
      currencyId: currencyId,
    );
  }

  @override
  Future<Map<String, dynamic>> getFinanceSettings() async {
    return await apiClient.getFinanceSettings();
  }

  @override
  Future<Map<String, dynamic>> updateFinanceSettings({
    required int baseCurrencyId,
  }) async {
    return await apiClient.updateFinanceSettings(baseCurrencyId: baseCurrencyId);
  }

  @override
  Future<List<CurrencyDto>> getAllCurrencies() async {
    // Try to get from cache first
    final cachedCurrencies = await currencyCache.getAllCurrencies();
    
    // If cache is valid, return immediately and refresh in background
    if (cachedCurrencies != null) {
      // Refresh in background (fire and forget)
      _refreshAllCurrenciesInBackground();
      return cachedCurrencies;
    }

    // Cache miss - fetch from API and cache
    return await _fetchAndCacheAllCurrencies();
  }

  Future<void> _refreshAllCurrenciesInBackground() async {
    try {
      await _fetchAndCacheAllCurrencies();
    } catch (e) {
      // Silent fail - user already has cached data
    }
  }

  Future<List<CurrencyDto>> _fetchAndCacheAllCurrencies() async {
    final currencies = await apiClient.getAllCurrencies();
    await currencyCache.saveAllCurrencies(currencies);
    return currencies;
  }



  @override
  Future<TransactionCategoryDto> createCategory({
    required String title,
    required String type,
    required String icon,
    required String color,
  }) async {
    final category = await apiClient.createCategory(
      title: title,
      type: type,
      icon: icon,
      color: color,
    );
    
    // Invalidate category cache after creating new category
    await categoryCache.invalidate();
    
    return category;
  }

  @override
  Future<void> deleteCategory(int categoryId) async {
    await apiClient.deleteCategory(categoryId);
    
    // Invalidate category cache after deleting
    await categoryCache.invalidate();
  }
}
