import 'package:equatable/equatable.dart';
import '../../data/models/wallet_dto.dart';
import '../../data/models/transaction_category_dto.dart';
import '../../data/models/transaction_dto.dart';

abstract class AddTransactionState extends Equatable {
  const AddTransactionState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AddTransactionInitial extends AddTransactionState {
  const AddTransactionInitial();
}

/// Loading wallets and categories
class AddTransactionLoadingData extends AddTransactionState {
  const AddTransactionLoadingData();
}

/// Data load failed
class AddTransactionLoadError extends AddTransactionState {
  final String message;

  const AddTransactionLoadError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Ready to fill form
class AddTransactionReady extends AddTransactionState {
  final List<WalletDto> wallets;
  final List<TransactionCategoryDto> incomeCategories;
  final List<TransactionCategoryDto> expenseCategories;
  final TransactionType type;
  final int? walletId; // For income/expense
  final int? fromWalletId; // For transfer/exchange
  final int? toWalletId; // For transfer/exchange
  final String amount; // For income/expense/transfer
  final String fromAmount; // For exchange
  final String toAmount; // For exchange
  final String? rate; // For exchange
  final int? categoryId;
  final String description;
  final DateTime occurredAt;
  final bool isValid;

  const AddTransactionReady({
    required this.wallets,
    required this.incomeCategories,
    required this.expenseCategories,
    this.type = TransactionType.expense,
    this.walletId,
    this.fromWalletId,
    this.toWalletId,
    this.amount = '',
    this.fromAmount = '',
    this.toAmount = '',
    this.rate,
    this.categoryId,
    this.description = '',
    required this.occurredAt,
    this.isValid = false,
  });

  AddTransactionReady copyWith({
    List<WalletDto>? wallets,
    List<TransactionCategoryDto>? incomeCategories,
    List<TransactionCategoryDto>? expenseCategories,
    TransactionType? type,
    int? walletId,
    bool clearWalletId = false,
    int? fromWalletId,
    bool clearFromWalletId = false,
    int? toWalletId,
    bool clearToWalletId = false,
    String? amount,
    String? fromAmount,
    String? toAmount,
    String? rate,
    bool clearRate = false,
    int? categoryId,
    bool clearCategoryId = false,
    String? description,
    DateTime? occurredAt,
    bool? isValid,
  }) {
    return AddTransactionReady(
      wallets: wallets ?? this.wallets,
      incomeCategories: incomeCategories ?? this.incomeCategories,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      type: type ?? this.type,
      walletId: clearWalletId ? null : (walletId ?? this.walletId),
      fromWalletId: clearFromWalletId ? null : (fromWalletId ?? this.fromWalletId),
      toWalletId: clearToWalletId ? null : (toWalletId ?? this.toWalletId),
      amount: amount ?? this.amount,
      fromAmount: fromAmount ?? this.fromAmount,
      toAmount: toAmount ?? this.toAmount,
      rate: clearRate ? null : (rate ?? this.rate),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      description: description ?? this.description,
      occurredAt: occurredAt ?? this.occurredAt,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [
        wallets,
        incomeCategories,
        expenseCategories,
        type,
        walletId,
        fromWalletId,
        toWalletId,
        amount,
        fromAmount,
        toAmount,
        rate,
        categoryId,
        description,
        occurredAt,
        isValid,
      ];
}

/// Submitting transaction
class AddTransactionSubmitting extends AddTransactionState {
  const AddTransactionSubmitting();
}

/// Transaction created successfully
class AddTransactionSuccess extends AddTransactionState {
  final TransactionDto transaction;

  const AddTransactionSuccess({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

/// Submission failed
class AddTransactionError extends AddTransactionState {
  final String message;

  const AddTransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}
