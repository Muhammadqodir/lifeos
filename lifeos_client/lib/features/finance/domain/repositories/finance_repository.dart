import '../../data/models/wallet_dto.dart';
import '../../data/models/transaction_dto.dart';
import '../../data/models/finance_summary_dto.dart';
import '../../data/models/currency_dto.dart';
import '../../data/models/transaction_category_dto.dart';
import '../../data/models/create_transaction_dto.dart';

abstract class FinanceRepository {
  Future<List<WalletDto>> getWallets();
  Future<WalletDto> getWalletWithBalance(int walletId);
  Future<List<WalletDto>> getWalletsWithBalances();
  Future<TransactionListResponseDto> getTransactions({
    int page = 1,
    int perPage = 20,
    String? type,
    int? walletId,
    int? categoryId,
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
  Future<List<TransactionCategoryDto>> getTransactionCategories({
    String? type,
  });
  Future<TransactionDto> createTransaction(
    CreateTransactionRequestDto request,
  );
}
