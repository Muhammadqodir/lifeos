import 'package:equatable/equatable.dart';
import '../../data/models/transaction_dto.dart';

abstract class AddTransactionEvent extends Equatable {
  const AddTransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial data (wallets, categories)
class AddTransactionLoadData extends AddTransactionEvent {
  const AddTransactionLoadData();
}

/// Change transaction type
class AddTransactionTypeChanged extends AddTransactionEvent {
  final TransactionType type;

  const AddTransactionTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

/// Update wallet for income/expense
class AddTransactionWalletChanged extends AddTransactionEvent {
  final int walletId;

  const AddTransactionWalletChanged(this.walletId);

  @override
  List<Object?> get props => [walletId];
}

/// Update from wallet for transfer/exchange
class AddTransactionFromWalletChanged extends AddTransactionEvent {
  final int walletId;

  const AddTransactionFromWalletChanged(this.walletId);

  @override
  List<Object?> get props => [walletId];
}

/// Update to wallet for transfer/exchange
class AddTransactionToWalletChanged extends AddTransactionEvent {
  final int walletId;

  const AddTransactionToWalletChanged(this.walletId);

  @override
  List<Object?> get props => [walletId];
}

/// Update amount for income/expense/transfer
class AddTransactionAmountChanged extends AddTransactionEvent {
  final String amount;

  const AddTransactionAmountChanged(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// Update from amount for exchange
class AddTransactionFromAmountChanged extends AddTransactionEvent {
  final String amount;

  const AddTransactionFromAmountChanged(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// Update to amount for exchange
class AddTransactionToAmountChanged extends AddTransactionEvent {
  final String amount;

  const AddTransactionToAmountChanged(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// Update exchange rate
class AddTransactionRateChanged extends AddTransactionEvent {
  final String rate;

  const AddTransactionRateChanged(this.rate);

  @override
  List<Object?> get props => [rate];
}

/// Update category
class AddTransactionCategoryChanged extends AddTransactionEvent {
  final int? categoryId;

  const AddTransactionCategoryChanged(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Update description
class AddTransactionDescriptionChanged extends AddTransactionEvent {
  final String description;

  const AddTransactionDescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

/// Update occurred at date/time
class AddTransactionOccurredAtChanged extends AddTransactionEvent {
  final DateTime occurredAt;

  const AddTransactionOccurredAtChanged(this.occurredAt);

  @override
  List<Object?> get props => [occurredAt];
}

/// Submit transaction
class AddTransactionSubmitted extends AddTransactionEvent {
  const AddTransactionSubmitted();
}
