import 'package:equatable/equatable.dart';

abstract class FinanceSettingsEvent extends Equatable {
  const FinanceSettingsEvent();

  @override
  List<Object?> get props => [];
}

class FinanceSettingsLoadData extends FinanceSettingsEvent {
  const FinanceSettingsLoadData();
}

class FinanceSettingsUpdateDefaultCurrency extends FinanceSettingsEvent {
  final int currencyId;

  const FinanceSettingsUpdateDefaultCurrency(this.currencyId);

  @override
  List<Object?> get props => [currencyId];
}

class FinanceSettingsAddCategory extends FinanceSettingsEvent {
  final String title;
  final String type;
  final String icon;
  final String color;

  const FinanceSettingsAddCategory({
    required this.title,
    required this.type,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [title, type, icon, color];
}

class FinanceSettingsRemoveCategory extends FinanceSettingsEvent {
  final int categoryId;

  const FinanceSettingsRemoveCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
