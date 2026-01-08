import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../data/models/transaction_dto.dart';
import '../../data/models/create_transaction_dto.dart';
import 'add_transaction_event.dart';
import 'add_transaction_state.dart';

class AddTransactionBloc
    extends Bloc<AddTransactionEvent, AddTransactionState> {
  final FinanceRepository financeRepository;
  final Random _random = Random();

  AddTransactionBloc({required this.financeRepository})
      : super(const AddTransactionInitial()) {
    on<AddTransactionLoadData>(_onLoadData);
    on<AddTransactionTypeChanged>(_onTypeChanged);
    on<AddTransactionWalletChanged>(_onWalletChanged);
    on<AddTransactionFromWalletChanged>(_onFromWalletChanged);
    on<AddTransactionToWalletChanged>(_onToWalletChanged);
    on<AddTransactionAmountChanged>(_onAmountChanged);
    on<AddTransactionFeePercentageChanged>(_onFeePercentageChanged);
    on<AddTransactionCustomFeeValueChanged>(_onCustomFeeValueChanged);
    on<AddTransactionCategoryChanged>(_onCategoryChanged);
    on<AddTransactionDescriptionChanged>(_onDescriptionChanged);
    on<AddTransactionOccurredAtChanged>(_onOccurredAtChanged);
    on<AddTransactionSubmitted>(_onSubmitted);
  }

  Future<void> _onLoadData(
    AddTransactionLoadData event,
    Emitter<AddTransactionState> emit,
  ) async {
    emit(const AddTransactionLoadingData());
    try {
      final wallets = await financeRepository.getWallets();
      final incomeCategories =
          await financeRepository.getTransactionCategories(type: 'income');
      final expenseCategories =
          await financeRepository.getTransactionCategories(type: 'expense');

      // Pre-select first wallet if available
      final defaultWalletId = wallets.isNotEmpty ? wallets.first.id : null;

      emit(AddTransactionReady(
        wallets: wallets,
        incomeCategories: incomeCategories,
        expenseCategories: expenseCategories,
        occurredAt: DateTime.now(),
        walletId: defaultWalletId,
      ));
    } catch (e) {
      emit(AddTransactionLoadError(message: e.toString()));
    }
  }

  void _onTypeChanged(
    AddTransactionTypeChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    if (state is AddTransactionReady) {
      final currentState = state as AddTransactionReady;
      
      // When switching types, reset fields to avoid validation errors
      AddTransactionReady newState;
      
      if (event.type == TransactionType.income || event.type == TransactionType.expense) {
        // For income/expense: keep walletId and amount, clear category
        newState = currentState.copyWith(
          type: event.type,
          clearCategoryId: true, // Always clear category when switching type
          // Reset from/to fields used by transfer
          clearFromWalletId: true,
          clearToWalletId: true,
          clearFeePercentage: true,
          customFeeValue: '',
        );
      } else {
        // For transfer: clear category, reset fee fields
        newState = currentState.copyWith(
          type: event.type,
          clearCategoryId: true,
          // Move walletId to fromWalletId if it exists
          fromWalletId: currentState.walletId,
          clearToWalletId: true,
          clearWalletId: true,
          clearFeePercentage: true,
          customFeeValue: '',
        );
      }
      
      emit(_validateState(newState));
    }
  }

  void _onWalletChanged(
    AddTransactionWalletChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    if (state is AddTransactionReady) {
      final currentState = state as AddTransactionReady;
      emit(_validateState(currentState.copyWith(walletId: event.walletId)));
    }
  }

  void _onFromWalletChanged(
    AddTransactionFromWalletChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    if (state is AddTransactionReady) {
      final currentState = state as AddTransactionReady;
      emit(_validateState(
          currentState.copyWith(fromWalletId: event.walletId)));
    }
  }

  void _onToWalletChanged(
    AddTransactionToWalletChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    if (state is AddTransactionReady) {
      final currentState = state as AddTransactionReady;
      emit(_validateState(currentState.copyWith(toWalletId: event.walletId)));
    }
  }

  void _onAmountChanged(
    AddTransactionAmountChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    if (state is AddTransactionReady) {
      final currentState = state as AddTransactionReady;
      emit(_validateState(currentState.copyWith(amount: event.amount)));
    }
  }

  void _onFeePercentageChanged(
    AddTransactionFeePercentageChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    if (state is AddTransactionReady) {
      final currentState = state as AddTransactionReady;
      emit(_validateState(
          currentState.copyWith(feePercentage: event.feePercentage)));
    }
  }

  void _onCustomFeeValueChanged(
    AddTransactionCustomFeeValueChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    if (state is AddTransactionReady) {
      final currentState = state as AddTransactionReady;
      emit(_validateState(
          currentState.copyWith(customFeeValue: event.customFeeValue)));
    }
  }

  void _onCategoryChanged(
    AddTransactionCategoryChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    if (state is AddTransactionReady) {
      final currentState = state as AddTransactionReady;
      emit(_validateState(
          currentState.copyWith(categoryId: event.categoryId)));
    }
  }

  void _onDescriptionChanged(
    AddTransactionDescriptionChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    if (state is AddTransactionReady) {
      final currentState = state as AddTransactionReady;
      emit(_validateState(
          currentState.copyWith(description: event.description)));
    }
  }

  void _onOccurredAtChanged(
    AddTransactionOccurredAtChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    if (state is AddTransactionReady) {
      final currentState = state as AddTransactionReady;
      emit(_validateState(
          currentState.copyWith(occurredAt: event.occurredAt)));
    }
  }

  AddTransactionReady _validateState(AddTransactionReady state) {
    bool isValid = false;

    switch (state.type) {
      case TransactionType.income:
      case TransactionType.expense:
        isValid = state.walletId != null &&
            state.amount.isNotEmpty &&
            _isValidAmount(state.amount) &&
            state.categoryId != null;
        break;

      case TransactionType.transfer:
        isValid = state.fromWalletId != null &&
            state.toWalletId != null &&
            state.fromWalletId != state.toWalletId &&
            state.amount.isNotEmpty &&
            _isValidAmount(state.amount);
        
        // Validate custom fee if set
        if (isValid && state.feePercentage == null && state.customFeeValue.isNotEmpty) {
          final customFee = double.tryParse(state.customFeeValue);
          isValid = customFee != null && customFee >= 0;
        }
        break;

      case TransactionType.exchange:
        // Exchange type is deprecated
        isValid = false;
        break;
    }

    return state.copyWith(isValid: isValid);
  }

  bool _isValidAmount(String amount) {
    if (amount.isEmpty) return false;
    final parsed = double.tryParse(amount);
    return parsed != null && parsed > 0;
  }

  Future<void> _onSubmitted(
    AddTransactionSubmitted event,
    Emitter<AddTransactionState> emit,
  ) async {
    if (state is! AddTransactionReady) return;
    final currentState = state as AddTransactionReady;

    if (!currentState.isValid) return;

    emit(const AddTransactionSubmitting());

    try {
      final request = _buildRequest(currentState);
      final transaction = await financeRepository.createTransaction(request);
      emit(AddTransactionSuccess(transaction: transaction));
    } catch (e) {
      // Extract error message from Exception
      String errorMessage = 'An unexpected error occurred';
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }
      emit(AddTransactionError(message: errorMessage));
    }
  }

  CreateTransactionRequestDto _buildRequest(AddTransactionReady state) {
    final entries = <CreateTransactionEntryDto>[];

    switch (state.type) {
      case TransactionType.income:
        final wallet = state.wallets.firstWhere((w) => w.id == state.walletId);
        entries.add(CreateTransactionEntryDto(
          walletId: state.walletId!,
          amount: state.amount,
          currencyId: wallet.currencyId,
        ));
        break;

      case TransactionType.expense:
        final wallet = state.wallets.firstWhere((w) => w.id == state.walletId);
        entries.add(CreateTransactionEntryDto(
          walletId: state.walletId!,
          amount: '-${state.amount}',
          currencyId: wallet.currencyId,
        ));
        break;

      case TransactionType.transfer:
        final fromWallet =
            state.wallets.firstWhere((w) => w.id == state.fromWalletId);
        final toWallet =
            state.wallets.firstWhere((w) => w.id == state.toWalletId);

        entries.add(CreateTransactionEntryDto(
          walletId: state.fromWalletId!,
          amount: '-${state.amount}',
          currencyId: fromWallet.currencyId,
        ));

        entries.add(CreateTransactionEntryDto(
          walletId: state.toWalletId!,
          amount: state.amount,
          currencyId: toWallet.currencyId,
        ));

        // Add fee entry if applicable
        if (state.feePercentage != null && state.feePercentage! > 0) {
          final feeAmount = (double.parse(state.amount) * state.feePercentage! / 100).toStringAsFixed(2);
          entries.add(CreateTransactionEntryDto(
            walletId: state.fromWalletId!,
            amount: '-$feeAmount',
            currencyId: fromWallet.currencyId,
            note: 'Transfer fee (${state.feePercentage}%)',
          ));
        } else if (state.customFeeValue.isNotEmpty) {
          final customFee = double.tryParse(state.customFeeValue);
          if (customFee != null && customFee > 0) {
            final feeAmount = (double.parse(state.amount) * customFee / 100).toStringAsFixed(2);
            entries.add(CreateTransactionEntryDto(
              walletId: state.fromWalletId!,
              amount: '-$feeAmount',
              currencyId: fromWallet.currencyId,
              note: 'Transfer fee ($customFee%)',
            ));
          }
        }
        break;

      case TransactionType.exchange:
        // Exchange type is deprecated, should not reach here
        break;
    }

    return CreateTransactionRequestDto(
      clientId: _generateUuid(),
      type: state.type.toJson(),
      categoryId: state.categoryId,
      description:
          state.description.isEmpty ? null : state.description,
      occurredAt: state.occurredAt,
      entries: entries,
    );
  }

  /// Generate a simple UUID v4
  String _generateUuid() {
    final bytes = List<int>.generate(16, (i) => _random.nextInt(256));
    
    // Set version to 4
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    // Set variant to 10
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }
}
