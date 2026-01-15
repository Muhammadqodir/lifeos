import 'package:equatable/equatable.dart';

abstract class ManageWalletsEvent extends Equatable {
  const ManageWalletsEvent();

  @override
  List<Object?> get props => [];
}

class ManageWalletsLoad extends ManageWalletsEvent {
  const ManageWalletsLoad();
}

class ManageWalletsRefresh extends ManageWalletsEvent {
  const ManageWalletsRefresh();
}

class ManageWalletsDelete extends ManageWalletsEvent {
  final int walletId;

  const ManageWalletsDelete({required this.walletId});

  @override
  List<Object?> get props => [walletId];
}
