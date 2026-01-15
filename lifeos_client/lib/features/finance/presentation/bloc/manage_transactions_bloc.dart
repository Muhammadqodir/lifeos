import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/finance_repository.dart';
import 'manage_transactions_event.dart';
import 'manage_transactions_state.dart';

class ManageTransactionsBloc
    extends Bloc<ManageTransactionsEvent, ManageTransactionsState> {
  final FinanceRepository financeRepository;
  static const int _perPage = 20;
  int _currentPage = 1;
  int? _currentWalletId;

  ManageTransactionsBloc({required this.financeRepository})
    : super(const ManageTransactionsInitial()) {
    on<ManageTransactionsLoad>(_onLoad);
    on<ManageTransactionsRefresh>(_onRefresh);
    on<ManageTransactionsLoadMore>(_onLoadMore);
    on<ManageTransactionsDelete>(_onDelete);
  }

  Future<void> _onLoad(
    ManageTransactionsLoad event,
    Emitter<ManageTransactionsState> emit,
  ) async {
    emit(const ManageTransactionsLoading());
    _currentPage = 1;
    _currentWalletId = event.walletId;
    await _loadData(emit);
  }

  Future<void> _onRefresh(
    ManageTransactionsRefresh event,
    Emitter<ManageTransactionsState> emit,
  ) async {
    _currentPage = 1;
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<ManageTransactionsState> emit) async {
    try {
      final response = await financeRepository.getTransactions(
        page: _currentPage,
        perPage: _perPage,
        walletId: _currentWalletId,
      );

      emit(
        ManageTransactionsLoaded(
          transactions: response.data,
          hasMore: response.data.length >= _perPage,
          walletId: _currentWalletId,
        ),
      );
    } catch (e) {
      emit(ManageTransactionsError(message: e.toString()));
    }
  }

  Future<void> _onLoadMore(
    ManageTransactionsLoadMore event,
    Emitter<ManageTransactionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is ManageTransactionsLoaded &&
        currentState.hasMore &&
        !currentState.isLoadingMore) {
      // Emit loading more state
      emit(currentState.copyWith(isLoadingMore: true));

      try {
        _currentPage++;
        final response = await financeRepository.getTransactions(
          page: _currentPage,
          perPage: _perPage,
          walletId: _currentWalletId,
        );

        final allTransactions = [
          ...currentState.transactions,
          ...response.data,
        ];

        emit(
          ManageTransactionsLoaded(
            transactions: allTransactions,
            hasMore: response.data.length >= _perPage,
            walletId: _currentWalletId,
          ),
        );
      } catch (e) {
        // Revert to previous state on error
        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> _onDelete(
    ManageTransactionsDelete event,
    Emitter<ManageTransactionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is ManageTransactionsLoaded) {
      emit(
        ManageTransactionsDeleting(
          transactionId: event.transactionId,
          transactions: currentState.transactions,
          hasMore: currentState.hasMore,
        ),
      );

      try {
        await financeRepository.deleteTransaction(event.transactionId);

        // Optimistically remove the transaction from the list
        final updatedTransactions = currentState.transactions
            .where((t) => t.id != event.transactionId)
            .toList();

        emit(
          ManageTransactionsDeleteSuccess(
            transactions: updatedTransactions,
            hasMore: currentState.hasMore,
          ),
        );

        // Transition back to loaded state
        emit(
          ManageTransactionsLoaded(
            transactions: updatedTransactions,
            hasMore: currentState.hasMore,
            walletId: _currentWalletId,
          ),
        );
      } catch (e) {
        emit(
          ManageTransactionsDeleteError(
            message: e.toString(),
            transactions: currentState.transactions,
            hasMore: currentState.hasMore,
          ),
        );

        // Transition back to loaded state with original data
        emit(
          ManageTransactionsLoaded(
            transactions: currentState.transactions,
            hasMore: currentState.hasMore,
            walletId: _currentWalletId,
          ),
        );
      }
    }
  }
}
