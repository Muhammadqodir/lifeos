import 'package:equatable/equatable.dart';

abstract class AddWalletEvent extends Equatable {
  const AddWalletEvent();

  @override
  List<Object?> get props => [];
}

class AddWalletLoadCurrencies extends AddWalletEvent {
  const AddWalletLoadCurrencies();
}

class AddWalletSubmitted extends AddWalletEvent {
  final String name;
  final int currencyId;
  final String type;
  final bool isActive;

  const AddWalletSubmitted({
    required this.name,
    required this.currencyId,
    required this.type,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [name, currencyId, type, isActive];
}
