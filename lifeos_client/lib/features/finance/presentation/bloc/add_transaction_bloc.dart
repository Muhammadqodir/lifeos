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
    on<AddTransactionFromAmountChanged>(_onFromAmountChanged);
    on<AddTransactionToAmountChanged>(_onToAmountChanged);
    on<AddTransactionRateChanged>(_onRateChanged);
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

      emit(AddTransactionReady(
        wallets: wallets,
        incomeCategories: incomeCategories,
        expenseCategories: expenseCategories,
        occurredAt: DateTime.now(),
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
          // Reset from/to fields used by transfer/exchange
          clearFromWalletId: true,
          clearToWalletId: true,
          fromAmount: '',
          toAmount: '',
          clearRate: true,
        );
      } else if (event.type == TransactionType.transfer) {
        // For transfer: clear category, reset exchange-specific fields
        newState = currentState.copyWith(
          type: event.type,
          clearCategoryId: true,
          // Move walletId to fromWalletId if it exists
          fromWalletId: currentState.walletId,
          clearToWalletId: true,
          clearWalletId: true,
          fromAmount: '',
          toAmount: '',
          clearRate: true,
        );
      } else {
        // For exchange: clear category, reset all exchange fields
        newState = currentState.copyWith(
          type: event.type,
          clearCategoryId: true,
          fromWalletId: currentState.walletId,
          clearToWalletId: true,
          clearWalletId: true,
          fromAmount: currentState.amount.isNotEmpty ? currentState.amount : '',
          toAmount: '',
          clearRate: true,
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

  void _onFromAmountChanged(
    AddTransactionFromAmountChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    if (state is AddTransactionReady) {
      final currentState = state as AddTransactionReady;
      emit(_validateState(currentState.copyWith(fromAmount: event.amount)));
    }
  }

  void _onToAmountChanged(
    AddTransactionToAmountChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    if (state is AddTransactionReady) {
      final currentState = state as AddTransactionReady;
      emit(_validateState(currentState.copyWith(toAmount: event.amount)));
    }
  }

  void _onRateChanged(
    AddTransactionRateChanged event,
    Emitter<AddTransactionState> emit,
  ) {
    if (state is AddTransactionReady) {
      final currentState = state as AddTransactionReady;
      emit(_validateState(currentState.copyWith(rate: event.rate)));
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
        break;

      case TransactionType.exchange:
        final fromWallet =
            state.wallets.where((w) => w.id == state.fromWalletId).firstOrNull;
        final toWallet =
            state.wallets.where((w) => w.id == state.toWalletId).firstOrNull;

        isValid = state.fromWalletId != null &&
            state.toWalletId != null &&
            state.fromWalletId != state.toWalletId &&
            fromWallet != null &&
            toWallet != null &&
            fromWallet.currencyId != toWallet.currencyId &&
            state.fromAmount.isNotEmpty &&
            _isValidAmount(state.fromAmount) &&
            state.toAmount.isNotEmpty &&
            _isValidAmount(state.toAmount) &&
            state.rate != null &&
            state.rate!.isNotEmpty &&
            _isValidAmount(state.rate!);
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
      emit(AddTransactionError(message: e.toString()));
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
        break;

      case TransactionType.exchange:
        final fromWallet =
            state.wallets.firstWhere((w) => w.id == state.fromWalletId);
        final toWallet =
            state.wallets.firstWhere((w) => w.id == state.toWalletId);

        entries.add(CreateTransactionEntryDto(
          walletId: state.fromWalletId!,
          amount: '-${state.fromAmount}',
          currencyId: fromWallet.currencyId,
          rate: state.rate,
        ));

        entries.add(CreateTransactionEntryDto(
          walletId: state.toWalletId!,
          amount: state.toAmount,
          currencyId: toWallet.currencyId,
          rate: state.rate,
        ));
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
