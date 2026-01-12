import 'package:equatable/equatable.dart';
import '../../data/models/wallet_dto.dart';

abstract class ManageWalletsState extends Equatable {
  const ManageWalletsState();

  @override
  List<Object?> get props => [];
}

class ManageWalletsInitial extends ManageWalletsState {
  const ManageWalletsInitial();
}

class ManageWalletsLoading extends ManageWalletsState {
  const ManageWalletsLoading();
}

class ManageWalletsLoaded extends ManageWalletsState {
  final List<WalletDto> wallets;

  const ManageWalletsLoaded({required this.wallets});

  @override
  List<Object?> get props => [wallets];
}

class ManageWalletsError extends ManageWalletsState {
  final String message;

  const ManageWalletsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ManageWalletsDeleting extends ManageWalletsState {
  final int walletId;
  final List<WalletDto> wallets;

  const ManageWalletsDeleting({
    required this.walletId,
    required this.wallets,
  });

  @override
  List<Object?> get props => [walletId, wallets];
}

class ManageWalletsDeleteSuccess extends ManageWalletsState {
  final List<WalletDto> wallets;

  const ManageWalletsDeleteSuccess({required this.wallets});

  @override
  List<Object?> get props => [wallets];
}

class ManageWalletsDeleteError extends ManageWalletsState {
  final String message;
  final List<WalletDto> wallets;

  const ManageWalletsDeleteError({
    required this.message,
    required this.wallets,
  });

  @override
  List<Object?> get props => [message, wallets];
}
