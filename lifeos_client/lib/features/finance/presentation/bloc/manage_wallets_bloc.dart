import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/finance_repository.dart';
import 'manage_wallets_event.dart';
import 'manage_wallets_state.dart';

class ManageWalletsBloc extends Bloc<ManageWalletsEvent, ManageWalletsState> {
  final FinanceRepository financeRepository;

  ManageWalletsBloc({required this.financeRepository})
      : super(const ManageWalletsInitial()) {
    on<ManageWalletsLoad>(_onLoad);
    on<ManageWalletsDelete>(_onDelete);
  }

  Future<void> _onLoad(
    ManageWalletsLoad event,
    Emitter<ManageWalletsState> emit,
  ) async {
    emit(const ManageWalletsLoading());
    try {
      final wallets = await financeRepository.getWalletsWithBalances();
      emit(ManageWalletsLoaded(wallets: wallets));
    } catch (e) {
      emit(ManageWalletsError(message: e.toString()));
    }
  }

  Future<void> _onDelete(
    ManageWalletsDelete event,
    Emitter<ManageWalletsState> emit,
  ) async {
    final currentState = state;
    if (currentState is ManageWalletsLoaded) {
      emit(ManageWalletsDeleting(
        walletId: event.walletId,
        wallets: currentState.wallets,
      ));

      try {
        await financeRepository.deleteWallet(event.walletId);
        
        // Reload wallets after deletion
        final wallets = await financeRepository.getWalletsWithBalances();
        emit(ManageWalletsDeleteSuccess(wallets: wallets));
        
        // Transition back to loaded state
        emit(ManageWalletsLoaded(wallets: wallets));
      } catch (e) {
        emit(ManageWalletsDeleteError(
          message: e.toString(),
          wallets: currentState.wallets,
        ));
        
        // Transition back to loaded state with original wallets
        emit(ManageWalletsLoaded(wallets: currentState.wallets));
      }
    }
  }
}
