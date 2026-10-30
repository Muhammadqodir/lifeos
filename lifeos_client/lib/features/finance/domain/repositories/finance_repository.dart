import '../../data/models/analytics_summary_dto.dart';
import '../../data/models/create_transaction_dto.dart';
import '../../data/models/currency_dto.dart';
import '../../data/models/finance_summary_dto.dart';
import '../../data/models/transaction_category_dto.dart';
import '../../data/models/transaction_dto.dart';
import '../../data/models/wallet_dto.dart';

/// Wallets, categories and transactions are read from and written to the
/// device (local-first); balances are computed locally. Currencies,
/// settings and FX rates are cached from the server; analytics is online.
abstract class FinanceRepository {
  /// Fires after any local change to finance data, so lists can re-read.
  Stream<void> get changes;

  Future<List<WalletDto>> getWallets();
  Future<WalletDto> getWalletWithBalance(String walletId);
  Future<List<WalletDto>> getWalletsWithBalances();
  Future<TransactionListResponseDto> getTransactions({
    int page = 1,
    int perPage = 20,
    String? type,
    String? walletId,
    String? categoryId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? searchQuery,
  });
  Future<FinanceSummaryDto> getFinanceSummary();
  Future<List<CurrencyDto>> getUserCurrencies();
  Future<WalletDto> createWallet({
    required String name,
    required int currencyId,
    required String type,
    bool isActive = true,
  });
  Future<void> deleteWallet(String walletId);
  Future<List<TransactionCategoryDto>> getTransactionCategories({
    String? type,
  });
  Future<TransactionDto> createTransaction(
    CreateTransactionRequestDto request,
  );
  Future<void> deleteTransaction(String transactionId);
  Future<AnalyticsSummaryDto> getAnalytics({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? currencyId,
  });
  Future<Map<String, dynamic>> getFinanceSettings();
  Future<Map<String, dynamic>> updateFinanceSettings({
    required int baseCurrencyId,
  });
  Future<List<CurrencyDto>> getAllCurrencies();
  Future<TransactionCategoryDto> createCategory({
    required String title,
    required String type,
    required String icon,
    required String color,
  });
  Future<void> deleteCategory(String categoryId);
}
