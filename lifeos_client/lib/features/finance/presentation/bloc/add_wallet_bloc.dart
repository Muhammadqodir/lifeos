import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/finance_repository.dart';
import 'add_wallet_event.dart';
import 'add_wallet_state.dart';

class AddWalletBloc extends Bloc<AddWalletEvent, AddWalletState> {
  final FinanceRepository financeRepository;

  AddWalletBloc({required this.financeRepository})
      : super(const AddWalletInitial()) {
    on<AddWalletLoadCurrencies>(_onLoadCurrencies);
    on<AddWalletSubmitted>(_onSubmitted);
  }

  Future<void> _onLoadCurrencies(
    AddWalletLoadCurrencies event,
    Emitter<AddWalletState> emit,
  ) async {
    emit(const AddWalletLoadingCurrencies());
    try {
      final currencies = await financeRepository.getUserCurrencies();
      emit(AddWalletReady(currencies: currencies));
    } catch (e) {
      emit(AddWalletCurrenciesError(message: e.toString()));
    }
  }

  Future<void> _onSubmitted(
    AddWalletSubmitted event,
    Emitter<AddWalletState> emit,
  ) async {
    emit(const AddWalletSubmitting());
    try {
      final wallet = await financeRepository.createWallet(
        name: event.name,
        currencyId: event.currencyId,
        type: event.type,
        isActive: event.isActive,
      );
      emit(AddWalletSuccess(wallet: wallet));
    } catch (e) {
      emit(AddWalletError(message: e.toString()));
    }
  }
}
