import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/finance_repository.dart';
import 'finance_home_event.dart';
import 'finance_home_state.dart';

class FinanceHomeBloc extends Bloc<FinanceHomeEvent, FinanceHomeState> {
  final FinanceRepository financeRepository;
  int _currentPage = 1;
  static const int _perPage = 20;

  FinanceHomeBloc({required this.financeRepository})
      : super(const FinanceHomeInitial()) {
    on<FinanceHomeStarted>(_onStarted);
    on<FinanceHomeRefreshed>(_onRefreshed);
    on<FinanceHomeRetried>(_onRetried);
    on<FinanceHomeLoadMoreHistory>(_onLoadMoreHistory);
  }

  Future<void> _onStarted(
    FinanceHomeStarted event,
    Emitter<FinanceHomeState> emit,
  ) async {
    emit(const FinanceHomeLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshed(
    FinanceHomeRefreshed event,
    Emitter<FinanceHomeState> emit,
  ) async {
    _currentPage = 1;
    await _loadData(emit);
  }

  Future<void> _onRetried(
    FinanceHomeRetried event,
    Emitter<FinanceHomeState> emit,
  ) async {
    emit(const FinanceHomeLoading());
    _currentPage = 1;
    await _loadData(emit);
  }

  Future<void> _onLoadMoreHistory(
    FinanceHomeLoadMoreHistory event,
    Emitter<FinanceHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FinanceHomeSuccess) return;
    if (currentState.isLoadingMore || !currentState.hasMoreTransactions) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      _currentPage++;
      final transactionsResponse = await financeRepository.getTransactions(
        page: _currentPage,
        perPage: _perPage,
      );

      final updatedTransactions = [
        ...currentState.transactions,
        ...transactionsResponse.data,
      ];

      emit(currentState.copyWith(
        transactions: updatedTransactions,
        hasMoreTransactions: transactionsResponse.meta.hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      // On error, just stop loading more but keep current state
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _loadData(Emitter<FinanceHomeState> emit) async {
    try {
      // Load all data in parallel
      final summary = await financeRepository.getFinanceSummary();
      final wallets = await financeRepository.getWalletsWithBalances();
      final transactionsResponse = await financeRepository.getTransactions(
        page: 1,
        perPage: _perPage,
      );

      // Check if there's any data
      final hasWallets = wallets.isNotEmpty;
      final hasTransactions = transactionsResponse.data.isNotEmpty;

      if (!hasWallets && !hasTransactions) {
        emit(const FinanceHomeEmpty());
        return;
      }

      emit(FinanceHomeSuccess(
        summary: summary,
        wallets: wallets,
        transactions: transactionsResponse.data,
        hasMoreTransactions: transactionsResponse.meta.hasMore,
      ));
    } catch (e) {
      emit(FinanceHomeFailure(message: e.toString()));
    }
  }
}
