import 'package:equatable/equatable.dart';
import '../../data/models/wallet_dto.dart';
import '../../data/models/finance_summary_dto.dart';

abstract class ManageWalletsState extends Equatable {
  const ManageWalletsState();

  @override
  List<Object?> get props => [];
}

class ManageWalletsWithData extends ManageWalletsState {
  final List<WalletDto> wallets;
  final FinanceSummaryDto summary;

  const ManageWalletsWithData({
    required this.wallets,
    required this.summary,
  });
}

class ManageWalletsInitial extends ManageWalletsState {
  const ManageWalletsInitial();
}

class ManageWalletsLoading extends ManageWalletsState {
  const ManageWalletsLoading();
}

class ManageWalletsLoaded extends ManageWalletsWithData {
  const ManageWalletsLoaded({
    required super.wallets,
    required super.summary,
  });

  @override
  List<Object?> get props => [wallets, summary];
}

class ManageWalletsError extends ManageWalletsState {
  final String message;

  const ManageWalletsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ManageWalletsDeleting extends ManageWalletsWithData {
  final int walletId;

  const ManageWalletsDeleting({
    required this.walletId,
    required super.wallets,
    required super.summary,
  });

  @override
  List<Object?> get props => [walletId, wallets, summary];
}

class ManageWalletsDeleteSuccess extends ManageWalletsWithData {
  const ManageWalletsDeleteSuccess({
    required super.wallets,
    required super.summary,
  });

  @override
  List<Object?> get props => [wallets, summary];
}

class ManageWalletsDeleteError extends ManageWalletsWithData {
  final String message;

  const ManageWalletsDeleteError({
    required this.message,
    required super.wallets,
    required super.summary,
  });

  @override
  List<Object?> get props => [message, wallets, summary];
}
