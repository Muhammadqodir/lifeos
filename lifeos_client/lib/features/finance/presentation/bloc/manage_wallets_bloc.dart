import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../data/models/wallet_dto.dart';
import '../../data/models/finance_summary_dto.dart';
import '../../domain/repositories/finance_repository.dart';
import 'manage_wallets_event.dart';
import 'manage_wallets_state.dart';

class ManageWalletsBloc extends Bloc<ManageWalletsEvent, ManageWalletsState> {
  final FinanceRepository financeRepository;

  /// Asked to sync when the user refreshes; local changes reload the list
  /// by themselves.
  final SyncEngine? sync;
  StreamSubscription<void>? _changes;

  ManageWalletsBloc({required this.financeRepository, this.sync})
    : super(const ManageWalletsInitial()) {
    on<_FinanceDataChanged>((event, emit) => _loadData(emit));
    _changes = financeRepository.changes.listen((_) {
      if (state is! ManageWalletsInitial) add(_FinanceDataChanged());
    });
    on<ManageWalletsLoad>(_onLoad);
    on<ManageWalletsRefresh>(_onRefresh);
    on<ManageWalletsDelete>(_onDelete);
  }

  Future<void> _onLoad(
    ManageWalletsLoad event,
    Emitter<ManageWalletsState> emit,
  ) async {
    emit(const ManageWalletsLoading());
    await _loadData(emit);
  }

  Future<void> _onRefresh(
    ManageWalletsRefresh event,
    Emitter<ManageWalletsState> emit,
  ) async {
    unawaited(sync?.syncNow());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<ManageWalletsState> emit) async {
    try {
      // Fetch wallets and summary in parallel
      final results = await Future.wait([
        financeRepository.getWalletsWithBalances(),
        financeRepository.getFinanceSummary(),
      ]);

      final wallets = results[0] as List<WalletDto>;
      final summary = results[1] as FinanceSummaryDto;

      emit(ManageWalletsLoaded(wallets: wallets, summary: summary));
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
      emit(
        ManageWalletsDeleting(
          walletId: event.walletId,
          wallets: currentState.wallets,
          summary: currentState.summary,
        ),
      );

      try {
        await financeRepository.deleteWallet(event.walletId);

        // Reload wallets and summary after deletion
        final results = await Future.wait([
          financeRepository.getWalletsWithBalances(),
          financeRepository.getFinanceSummary(),
        ]);

        final wallets = results[0] as List<WalletDto>;
        final summary = results[1] as FinanceSummaryDto;

        emit(ManageWalletsDeleteSuccess(wallets: wallets, summary: summary));

        // Transition back to loaded state
        emit(ManageWalletsLoaded(wallets: wallets, summary: summary));
      } catch (e) {
        emit(
          ManageWalletsDeleteError(
            message: e.toString(),
            wallets: currentState.wallets,
            summary: currentState.summary,
          ),
        );

        // Transition back to loaded state with original data
        emit(
          ManageWalletsLoaded(
            wallets: currentState.wallets,
            summary: currentState.summary,
          ),
        );
      }
    }
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}

/// Wallets, categories or transactions changed on the device (internal).
class _FinanceDataChanged extends ManageWalletsEvent {}
