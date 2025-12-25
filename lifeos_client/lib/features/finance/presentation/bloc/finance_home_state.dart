import 'package:equatable/equatable.dart';
import '../../data/models/wallet_dto.dart';
import '../../data/models/transaction_dto.dart';
import '../../data/models/finance_summary_dto.dart';

abstract class FinanceHomeState extends Equatable {
  const FinanceHomeState();

  @override
  List<Object?> get props => [];
}

class FinanceHomeInitial extends FinanceHomeState {
  const FinanceHomeInitial();
}

class FinanceHomeLoading extends FinanceHomeState {
  const FinanceHomeLoading();
}

class FinanceHomeSuccess extends FinanceHomeState {
  final FinanceSummaryDto summary;
  final List<WalletDto> wallets;
  final List<TransactionDto> transactions;
  final bool hasMoreTransactions;
  final bool isLoadingMore;

  const FinanceHomeSuccess({
    required this.summary,
    required this.wallets,
    required this.transactions,
    required this.hasMoreTransactions,
    this.isLoadingMore = false,
  });

  FinanceHomeSuccess copyWith({
    FinanceSummaryDto? summary,
    List<WalletDto>? wallets,
    List<TransactionDto>? transactions,
    bool? hasMoreTransactions,
    bool? isLoadingMore,
  }) {
    return FinanceHomeSuccess(
      summary: summary ?? this.summary,
      wallets: wallets ?? this.wallets,
      transactions: transactions ?? this.transactions,
      hasMoreTransactions: hasMoreTransactions ?? this.hasMoreTransactions,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        summary,
        wallets,
        transactions,
        hasMoreTransactions,
        isLoadingMore,
      ];
}

class FinanceHomeEmpty extends FinanceHomeState {
  const FinanceHomeEmpty();
}

class FinanceHomeFailure extends FinanceHomeState {
  final String message;

  const FinanceHomeFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
