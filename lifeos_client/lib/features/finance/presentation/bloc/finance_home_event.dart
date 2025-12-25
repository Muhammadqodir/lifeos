import 'package:equatable/equatable.dart';

abstract class FinanceHomeEvent extends Equatable {
  const FinanceHomeEvent();

  @override
  List<Object?> get props => [];
}

class FinanceHomeStarted extends FinanceHomeEvent {
  const FinanceHomeStarted();
}

class FinanceHomeRefreshed extends FinanceHomeEvent {
  const FinanceHomeRefreshed();
}

class FinanceHomeRetried extends FinanceHomeEvent {
  const FinanceHomeRetried();
}

class FinanceHomeLoadMoreHistory extends FinanceHomeEvent {
  const FinanceHomeLoadMoreHistory();
}
