//TODO: increase loading speed, cache wallets and categories

import 'package:lifeos_client/features/finance/data/models/wallet_dto.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection.dart';
import '../../data/models/transaction_dto.dart';
import '../bloc/add_transaction_bloc.dart';
import '../bloc/add_transaction_event.dart';
import '../bloc/add_transaction_state.dart';
import '../widgets/transaction_type_selector.dart';
import '../widgets/wallet_selector.dart';
import '../widgets/amount_input_field.dart';
import '../widgets/category_selector.dart';
import '../widgets/fee_selector.dart';
import 'package:lifeos_client/core/ui/ui.dart';

class AddTransactionPage extends StatelessWidget {
  const AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AddTransactionBloc>()..add(const AddTransactionLoadData()),
      child: const _AddTransactionPageContent(),
    );
  }
}

class _AddTransactionPageContent extends StatelessWidget {
  const _AddTransactionPageContent();

  @override
  Widget build(BuildContext context) {
    final outerContext = context;

    return BlocListener<AddTransactionBloc, AddTransactionState>(
      listener: (context, state) {
        if (state is AddTransactionSuccess) {
          AppToast.success(context, 'Transaction created');

          Navigator.of(context).pop(true);
        } else if (state is AddTransactionError) {
          AppToast.error(
            context,
            'Something went wrong',
            message: state.message,
          );
        }
      },
      child: Scaffold(
        headers: [AppHeader(title: 'New transaction')],
        child: BlocBuilder<AddTransactionBloc, AddTransactionState>(
          builder: (context, state) {
            if (state is AddTransactionLoadingData) {
              return LoadingState(message: 'Loading wallets…');
            }

            if (state is AddTransactionLoadError) {
              return ErrorState(
                title: "Couldn't load wallets and categories",
                message: state.message,
                onRetry: () => context.read<AddTransactionBloc>().add(
                  const AddTransactionLoadData(),
                ),
              );
            }

            if (state is AddTransactionReady ||
                state is AddTransactionSubmitting ||
                state is AddTransactionError) {
              final isSubmitting = state is AddTransactionSubmitting;
              final formState = state is AddTransactionReady
                  ? state
                  : state is AddTransactionSubmitting
                  ? state.previousState
                  : (state as AddTransactionError).previousState;

              return _buildForm(
                outerContext,
                formState,
                isSubmitting: isSubmitting,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AddTransactionReady state, {
    required bool isSubmitting,
  }) {
    final occurredAt = state.occurredAt;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: ContentWidth(child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Transaction Type Selector
                TransactionTypeSelector(
                  selectedType: state.type,
                  onChanged: (type) {
                    context.read<AddTransactionBloc>().add(
                      AddTransactionTypeChanged(type),
                    );
                  },
                ),
                _buildTypeSpecificFields(context, state),
                const SizedBox(height: AppSpacing.lg),

                // Category (only for income/expense)
                if (state.type == TransactionType.income ||
                    state.type == TransactionType.expense) ...[
                  CategorySelector(
                    categories: state.type == TransactionType.income
                        ? state.incomeCategories
                        : state.expenseCategories,
                    selectedCategoryId: state.categoryId,
                    onChanged: (categoryId) {
                      context.read<AddTransactionBloc>().add(
                        AddTransactionCategoryChanged(categoryId),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                AppFormField(
                  label: 'Note',
                  optional: true,
                  child: TextField(
                    initialValue: state.description,
                    placeholder: const Text('Dinner with friends'),
                    maxLines: 3,
                    onChanged: (value) {
                      context.read<AddTransactionBloc>().add(
                        AddTransactionDescriptionChanged(value),
                      );
                    },
                  ),
                ),
                AppFormField(
                  label: 'Date',
                  child: DatePicker(
                    value: occurredAt,
                    mode: PromptMode.dialog,
                    dialogTitle: const Text('Transaction date'),
                    stateBuilder: (date) => date.isAfter(DateTime.now())
                        ? DateState.disabled
                        : DateState.enabled,
                    onChanged: (value) {
                      context.read<AddTransactionBloc>().add(
                        AddTransactionOccurredAtChanged(value!),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FormSubmitButton(
                  label: 'Add transaction',
                  loadingLabel: 'Saving…',
                  loading: isSubmitting,
                  onPressed: () {
                    if (!state.isValid) {
                      AppToast.error(
                        context,
                        'Check the form',
                        message: _getValidationError(state),
                      );
                      return;
                    }
                    context.read<AddTransactionBloc>().add(
                      const AddTransactionSubmitted(),
                    );
                  },
                ),
                const SizedBox(height: 24), // Space for bottom button
              ],
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSpecificFields(
    BuildContext context,
    AddTransactionReady state,
  ) {
    switch (state.type) {
      case TransactionType.income:
      case TransactionType.expense:
        return Column(
          children: [
            WalletSelector(
              label: 'Wallet',
              wallets: state.wallets,
              selectedWalletId: state.walletId,
              onChanged: (walletId) {
                if (walletId != null) {
                  context.read<AddTransactionBloc>().add(
                    AddTransactionWalletChanged(walletId),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            AmountInputField(
              label: 'Amount',
              value: state.amount,
              onChanged: (amount) {
                context.read<AddTransactionBloc>().add(
                  AddTransactionAmountChanged(amount),
                );
              },
              placeholder: '0.00',
            ),
          ],
        );

      case TransactionType.transfer:
        final fromWallet = state.wallets
            .where((w) => w.id == state.fromWalletId)
            .firstOrNull;
        final toWallet = state.wallets
            .where((w) => w.id == state.toWalletId)
            .firstOrNull;
        final isDifferentCurrency =
            fromWallet != null &&
            toWallet != null &&
            fromWallet.currencyId != toWallet.currencyId;

        return Column(
          children: [
            WalletSelector(
              label: 'From',
              wallets: state.wallets,
              selectedWalletId: state.fromWalletId,
              onChanged: (walletId) {
                if (walletId != null) {
                  context.read<AddTransactionBloc>().add(
                    AddTransactionFromWalletChanged(walletId),
                  );
                }
              },
              placeholder: 'Choose wallet',
            ),
            const SizedBox(height: 16),
            WalletSelector(
              label: 'To',
              wallets: state.wallets,
              selectedWalletId: state.toWalletId,
              onChanged: (walletId) {
                if (walletId != null) {
                  context.read<AddTransactionBloc>().add(
                    AddTransactionToWalletChanged(walletId),
                  );
                }
              },
              placeholder: 'Choose wallet',
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AmountInputField(
                  label: isDifferentCurrency
                      ? 'Amount (${fromWallet.currency.code})'
                      : 'Amount',
                  value: state.amount,
                  onChanged: (amount) {
                    context.read<AddTransactionBloc>().add(
                      AddTransactionAmountChanged(amount),
                    );
                  },
                  placeholder: '0.00',
                ),
                if (isDifferentCurrency) ...[
                  const SizedBox(height: 16),
                  AmountInputField(
                    label: 'Amount (${toWallet.currency.code})',
                    value: state.exchangeAmount,
                    onChanged: (amount) {
                      context.read<AddTransactionBloc>().add(
                        AddTransactionExchangeAmountChanged(amount),
                      );
                    },
                    placeholder: '0.00',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rate: ${_calculateExchangeRate(state, fromWallet, toWallet)}',
                    style: context.text.caption,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            FeeSelector(
              selectedFeeType: _getFeeTypeFromState(state),
              customFeeValue: state.customFeeValue,
              onFeeTypeChanged: (feeType) {
                context.read<AddTransactionBloc>().add(
                  AddTransactionFeePercentageChanged(feeType.percentage),
                );
              },
              onCustomFeeChanged: (value) {
                context.read<AddTransactionBloc>().add(
                  AddTransactionCustomFeeValueChanged(value),
                );
              },
            ),
          ],
        );

      case TransactionType.exchange:
        // Exchange type is deprecated
        return const SizedBox.shrink();
    }
  }

  String _calculateExchangeRate(
    AddTransactionReady state,
    WalletDto fromWallet,
    WalletDto toWallet,
  ) {
    String exchangeRate = '';

    if (state.amount.isNotEmpty && state.exchangeAmount.isNotEmpty) {
      final amount = double.tryParse(state.amount);
      final exchangeAmount = double.tryParse(state.exchangeAmount);
      if (amount != null &&
          amount > 0 &&
          exchangeAmount != null &&
          exchangeAmount > 0) {
        if (amount > exchangeAmount) {
          final rate = amount / exchangeAmount;
          exchangeRate =
              '1 ${toWallet.currency.code} = ${rate.toStringAsFixed(1)} ${fromWallet.currency.code}';
        } else {
          final rate = exchangeAmount / amount;
          exchangeRate =
              '1 ${fromWallet.currency.code} = ${rate.toStringAsFixed(1)} ${toWallet.currency.code}';
        }
      }
    }

    return exchangeRate;
  }

  FeeType _getFeeTypeFromState(AddTransactionReady state) {
    if (state.feePercentage == null) {
      if (state.customFeeValue.isNotEmpty) {
        return FeeType.custom;
      }
      return FeeType.none;
    }
    if (state.feePercentage == 0) return FeeType.none;
    if (state.feePercentage == 0.5) return FeeType.halfPercent;
    if (state.feePercentage == 1.0) return FeeType.onePercent;
    return FeeType.custom;
  }

  String _getValidationError(AddTransactionReady state) {
    switch (state.type) {
      case TransactionType.income:
      case TransactionType.expense:
        if (state.walletId == null) {
          return 'Choose a wallet.';
        }
        if (state.amount.isEmpty) {
          return 'Enter an amount.';
        }
        if (double.tryParse(state.amount) == null ||
            double.parse(state.amount) <= 0) {
          return 'Enter an amount greater than 0.';
        }
        if (state.categoryId == null) {
          return 'Choose a category.';
        }
        break;

      case TransactionType.transfer:
        if (state.fromWalletId == null) {
          return 'Choose the wallet to move money from.';
        }
        if (state.toWalletId == null) {
          return 'Choose the wallet to move money to.';
        }
        if (state.fromWalletId == state.toWalletId) {
          return 'Choose two different wallets.';
        }
        if (state.amount.isEmpty) {
          return 'Enter an amount.';
        }
        if (double.tryParse(state.amount) == null ||
            double.parse(state.amount) <= 0) {
          return 'Enter an amount greater than 0.';
        }
        // Check for exchange amount if currencies are different
        final fromWallet = state.wallets
            .where((w) => w.id == state.fromWalletId)
            .firstOrNull;
        final toWallet = state.wallets
            .where((w) => w.id == state.toWalletId)
            .firstOrNull;
        final isDifferentCurrency =
            fromWallet != null &&
            toWallet != null &&
            fromWallet.currencyId != toWallet.currencyId;

        if (isDifferentCurrency) {
          if (state.exchangeAmount.isEmpty) {
            return 'Enter the amount received.';
          }
          if (double.tryParse(state.exchangeAmount) == null ||
              double.parse(state.exchangeAmount) <= 0) {
            return 'Enter a received amount greater than 0.';
          }
        }
        if (state.feePercentage == null && state.customFeeValue.isNotEmpty) {
          final customFee = double.tryParse(state.customFeeValue);
          if (customFee == null || customFee < 0) {
            return 'Enter a valid fee percentage.';
          }
        }
        break;

      case TransactionType.exchange:
        return 'Exchange type is deprecated';
    }

    return 'Fill in the required fields.';
  }
}
