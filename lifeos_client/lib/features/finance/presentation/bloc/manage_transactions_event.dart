import 'package:equatable/equatable.dart';

abstract class ManageTransactionsEvent extends Equatable {
  const ManageTransactionsEvent();

  @override
  List<Object?> get props => [];
}

class ManageTransactionsLoad extends ManageTransactionsEvent {
  final int? walletId;

  const ManageTransactionsLoad({this.walletId});

  @override
  List<Object?> get props => [walletId];
}

class ManageTransactionsRefresh extends ManageTransactionsEvent {
  const ManageTransactionsRefresh();
}

class ManageTransactionsLoadMore extends ManageTransactionsEvent {
  const ManageTransactionsLoadMore();
}

class ManageTransactionsDelete extends ManageTransactionsEvent {
  final int transactionId;

  const ManageTransactionsDelete({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}
