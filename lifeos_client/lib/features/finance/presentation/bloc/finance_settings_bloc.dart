import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/finance_repository.dart';
import 'finance_settings_event.dart';
import 'finance_settings_state.dart';

class FinanceSettingsBloc extends Bloc<FinanceSettingsEvent, FinanceSettingsState> {
  final FinanceRepository financeRepository;

  FinanceSettingsBloc({required this.financeRepository}) : super(const FinanceSettingsInitial()) {
    on<FinanceSettingsLoadData>(_onLoadData);
    on<FinanceSettingsUpdateDefaultCurrency>(_onUpdateDefaultCurrency);
    on<FinanceSettingsAddCategory>(_onAddCategory);
    on<FinanceSettingsRemoveCategory>(_onRemoveCategory);
  }

  Future<void> _onLoadData(
    FinanceSettingsLoadData event,
    Emitter<FinanceSettingsState> emit,
  ) async {
    emit(const FinanceSettingsLoading());

    try {
      final userCurrencies = await financeRepository.getUserCurrencies();
      final allCurrencies = await financeRepository.getAllCurrencies();
      final categories = await financeRepository.getTransactionCategories();
      final settings = await financeRepository.getFinanceSettings();
      final defaultCurrencyId = settings['base_currency_id'] as int?;

      emit(FinanceSettingsLoaded(
        userCurrencies: userCurrencies,
        allCurrencies: allCurrencies,
        categories: categories,
        defaultCurrencyId: defaultCurrencyId,
      ));
    } catch (e) {
      emit(FinanceSettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateDefaultCurrency(
    FinanceSettingsUpdateDefaultCurrency event,
    Emitter<FinanceSettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FinanceSettingsLoaded) return;

    try {
      await financeRepository.updateFinanceSettings(baseCurrencyId: event.currencyId);

      final updatedState = currentState.copyWith(defaultCurrencyId: event.currencyId);
      
      emit(FinanceSettingsOperationSuccess(
        message: 'Default currency updated successfully',
        previousState: updatedState,
      ));
      
      emit(updatedState);
    } catch (e) {
      emit(FinanceSettingsError(e.toString()));
      emit(currentState);
    }
  }

  Future<void> _onAddCategory(
    FinanceSettingsAddCategory event,
    Emitter<FinanceSettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FinanceSettingsLoaded) return;

    try {
      final category = await financeRepository.createCategory(
        title: event.title,
        type: event.type,
        icon: event.icon,
        color: event.color,
      );
      
      final updatedCategories = [...currentState.categories, category];
      final updatedState = currentState.copyWith(categories: updatedCategories);
      
      emit(FinanceSettingsOperationSuccess(
        message: 'Category added successfully',
        previousState: updatedState,
      ));
      
      emit(updatedState);
    } catch (e) {
      emit(FinanceSettingsError(e.toString()));
      emit(currentState);
    }
  }

  Future<void> _onRemoveCategory(
    FinanceSettingsRemoveCategory event,
    Emitter<FinanceSettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FinanceSettingsLoaded) return;

    try {
      await financeRepository.deleteCategory(event.categoryId);
      
      final updatedCategories = currentState.categories
          .where((c) => c.id != event.categoryId)
          .toList();
      final updatedState = currentState.copyWith(categories: updatedCategories);
      
      emit(FinanceSettingsOperationSuccess(
        message: 'Category removed successfully',
        previousState: updatedState,
      ));
      
      emit(updatedState);
    } catch (e) {
      emit(FinanceSettingsError(e.toString()));
      emit(currentState);
    }
  }
}
