import 'package:equatable/equatable.dart';
import '../../data/models/currency_dto.dart';
import '../../data/models/wallet_dto.dart';

abstract class AddWalletState extends Equatable {
  const AddWalletState();

  @override
  List<Object?> get props => [];
}

class AddWalletInitial extends AddWalletState {
  const AddWalletInitial();
}

class AddWalletLoadingCurrencies extends AddWalletState {
  const AddWalletLoadingCurrencies();
}

class AddWalletReady extends AddWalletState {
  final List<CurrencyDto> currencies;

  const AddWalletReady({required this.currencies});

  @override
  List<Object?> get props => [currencies];
}

class AddWalletCurrenciesError extends AddWalletState {
  final String message;

  const AddWalletCurrenciesError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AddWalletSubmitting extends AddWalletState {
  const AddWalletSubmitting();
}

class AddWalletSuccess extends AddWalletState {
  final WalletDto wallet;

  const AddWalletSuccess({required this.wallet});

  @override
  List<Object?> get props => [wallet];
}

class AddWalletError extends AddWalletState {
  final String message;

  const AddWalletError({required this.message});

  @override
  List<Object?> get props => [message];
}
