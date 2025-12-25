import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_api_client.dart';
import '../models/wallet_dto.dart';
import '../models/transaction_dto.dart';
import '../models/finance_summary_dto.dart';
import '../models/currency_dto.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceApiClient apiClient;

  FinanceRepositoryImpl({required this.apiClient});

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
    return await apiClient.getUserCurrencies();
  }

  @override
  Future<WalletDto> createWallet({
    required String name,
    required int currencyId,
    required String type,
    bool isActive = true,
  }) async {
    return await apiClient.createWallet(
      name: name,
      currencyId: currencyId,
      type: type,
      isActive: isActive,
    );
  }
}
