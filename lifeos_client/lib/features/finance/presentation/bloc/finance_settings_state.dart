import 'package:equatable/equatable.dart';
import '../../data/models/currency_dto.dart';
import '../../data/models/transaction_category_dto.dart';

abstract class FinanceSettingsState extends Equatable {
  const FinanceSettingsState();

  @override
  List<Object?> get props => [];
}

class FinanceSettingsInitial extends FinanceSettingsState {
  const FinanceSettingsInitial();
}

class FinanceSettingsLoading extends FinanceSettingsState {
  const FinanceSettingsLoading();
}

class FinanceSettingsLoaded extends FinanceSettingsState {
  final List<CurrencyDto> userCurrencies;
  final List<CurrencyDto> allCurrencies;
  final List<TransactionCategoryDto> categories;
  final int? defaultCurrencyId;

  const FinanceSettingsLoaded({
    required this.userCurrencies,
    required this.allCurrencies,
    required this.categories,
    this.defaultCurrencyId,
  });

  FinanceSettingsLoaded copyWith({
    List<CurrencyDto>? userCurrencies,
    List<CurrencyDto>? allCurrencies,
    List<TransactionCategoryDto>? categories,
    int? defaultCurrencyId,
  }) {
    return FinanceSettingsLoaded(
      userCurrencies: userCurrencies ?? this.userCurrencies,
      allCurrencies: allCurrencies ?? this.allCurrencies,
      categories: categories ?? this.categories,
      defaultCurrencyId: defaultCurrencyId ?? this.defaultCurrencyId,
    );
  }

  @override
  List<Object?> get props => [userCurrencies, allCurrencies, categories, defaultCurrencyId];
}

class FinanceSettingsError extends FinanceSettingsState {
  final String message;

  const FinanceSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class FinanceSettingsOperationSuccess extends FinanceSettingsState {
  final String message;
  final FinanceSettingsLoaded previousState;

  const FinanceSettingsOperationSuccess({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}
