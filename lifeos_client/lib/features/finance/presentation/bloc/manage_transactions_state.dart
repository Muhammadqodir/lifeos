import 'package:equatable/equatable.dart';
import '../../data/models/transaction_dto.dart';

abstract class ManageTransactionsState extends Equatable {
  const ManageTransactionsState();

  @override
  List<Object?> get props => [];
}

class ManageTransactionsWithData extends ManageTransactionsState {
  final List<TransactionDto> transactions;
  final bool hasMore;

  const ManageTransactionsWithData({
    required this.transactions,
    required this.hasMore,
  });
}

class ManageTransactionsInitial extends ManageTransactionsState {
  const ManageTransactionsInitial();
}

class ManageTransactionsLoading extends ManageTransactionsState {
  const ManageTransactionsLoading();
}

class ManageTransactionsLoaded extends ManageTransactionsWithData {
  final bool isLoadingMore;
  final int? walletId;

  const ManageTransactionsLoaded({
    required super.transactions,
    required super.hasMore,
    this.isLoadingMore = false,
    this.walletId,
  });

  ManageTransactionsLoaded copyWith({
    List<TransactionDto>? transactions,
    bool? hasMore,
    bool? isLoadingMore,
    int? walletId,
  }) {
    return ManageTransactionsLoaded(
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      walletId: walletId ?? this.walletId,
    );
  }

  @override
  List<Object?> get props => [transactions, hasMore, isLoadingMore, walletId];
}

class ManageTransactionsError extends ManageTransactionsState {
  final String message;

  const ManageTransactionsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ManageTransactionsDeleting extends ManageTransactionsWithData {
  final int transactionId;

  const ManageTransactionsDeleting({
    required this.transactionId,
    required super.transactions,
    required super.hasMore,
  });

  @override
  List<Object?> get props => [transactionId, transactions, hasMore];
}

class ManageTransactionsDeleteSuccess extends ManageTransactionsWithData {
  const ManageTransactionsDeleteSuccess({
    required super.transactions,
    required super.hasMore,
  });

  @override
  List<Object?> get props => [transactions, hasMore];
}

class ManageTransactionsDeleteError extends ManageTransactionsWithData {
  final String message;

  const ManageTransactionsDeleteError({
    required this.message,
    required super.transactions,
    required super.hasMore,
  });

  @override
  List<Object?> get props => [message, transactions, hasMore];
}
