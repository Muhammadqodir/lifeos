//TODO: increase loading speed, cache wallets and categories

import 'package:lifeos_client/core/widgets/loading_state.dart';
import 'package:lifeos_client/features/finance/data/models/wallet_dto.dart';
import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../injection.dart';
import '../../../navigation/presentation/widgets/custom_app_bar.dart';
import '../../data/models/transaction_dto.dart';
import '../bloc/add_transaction_bloc.dart';
import '../bloc/add_transaction_event.dart';
import '../bloc/add_transaction_state.dart';
import '../widgets/transaction_type_selector.dart';
import '../widgets/wallet_selector.dart';
import '../widgets/amount_input_field.dart';
import '../widgets/category_selector.dart';
import '../widgets/fee_selector.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AddTransactionBloc, AddTransactionState>(
      listener: (context, state) {
        if (state is AddTransactionSuccess) {
          showToast(
            context: context,
            builder: (ctx, overlay) {
              return Utils.buildToast(
                ctx,
                overlay,
                'Success',
                'Transaction created successfully',
              );
            },
            location: ToastLocation.topCenter,
          );

          Navigator.of(context).pop(true);
        } else if (state is AddTransactionError) {
          showToast(
            context: context,
            builder: (context, overlay) {
              return Utils.buildToast(context, overlay, 'Error', state.message);
            },
            location: ToastLocation.topCenter,
          );
        }
      },
      child: Scaffold(
        headers: [
          CustomAppBar(
            title: 'Add Transaction',
            leftActions: [
              AppBarAction(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                tooltip: 'Back',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
        child: BlocBuilder<AddTransactionBloc, AddTransactionState>(
          builder: (context, state) {
            if (state is AddTransactionLoadingData) {
              return LoadingState(message: 'Loading...');
            }

            if (state is AddTransactionLoadError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedAlert02,
                      size: 48,
                      color: colorScheme.destructive,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load data',
                      style: Theme.of(context).typography.normal.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        style: Theme.of(context).typography.small.copyWith(
                          color: colorScheme.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      onPressed: () {
                        context.read<AddTransactionBloc>().add(
                          const AddTransactionLoadData(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
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
    DateTime _value = state.occurredAt;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
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
                const SizedBox(height: 20),

                // Dynamic form based on transaction type
                _buildTypeSpecificFields(context, state),

                const SizedBox(height: 20),

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
                  const SizedBox(height: 20),
                ],

                // Description
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description (optional)',
                      style: Theme.of(context).typography.small.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      initialValue: state.description,
                      placeholder: const Text('Add a note...'),
                      maxLines: 3,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      onChanged: (value) {
                        context.read<AddTransactionBloc>().add(
                          AddTransactionDescriptionChanged(value),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Text(
                  'Date & Time',
                  style: Theme.of(context).typography.small.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                // Date/Time
                DatePicker(
                  value: _value,
                  mode: PromptMode.dialog,
                  // Title shown at the top of the dialog variant.
                  dialogTitle: const Text('Select Date'),
                  stateBuilder: (date) {
                    if (date.isAfter(DateTime.now())) {
                      return DateState.disabled;
                    }
                    return DateState.enabled;
                  },
                  onChanged: (value) {
                    context.read<AddTransactionBloc>().add(
                      AddTransactionOccurredAtChanged(value!),
                    );
                  },
                ),

                const SizedBox(height: 24), // Space for bottom button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: PrimaryButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            // Check if form is valid
                            if (!state.isValid) {
                              // Show validation error
                              String errorMessage = _getValidationError(state);
                              showToast(
                                context: context,
                                builder: (context, overlay) {
                                  return Utils.buildToast(
                                    context,
                                    overlay,
                                    'Validation Error',
                                    errorMessage,
                                  );
                                },
                                location: ToastLocation.topCenter,
                              );
                              return;
                            }

                            context.read<AddTransactionBloc>().add(
                              const AddTransactionSubmitted(),
                            );
                          },
                    child: isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Creating...'),
                            ],
                          )
                        : const Text('Create Transaction'),
                  ),
                ),

                const SizedBox(height: 24), // Space for bottom button
              ],
            ),
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
              label: 'From Wallet',
              wallets: state.wallets,
              selectedWalletId: state.fromWalletId,
              onChanged: (walletId) {
                if (walletId != null) {
                  context.read<AddTransactionBloc>().add(
                    AddTransactionFromWalletChanged(walletId),
                  );
                }
              },
              placeholder: 'Select source wallet',
            ),
            const SizedBox(height: 16),
            WalletSelector(
              label: 'To Wallet',
              wallets: state.wallets,
              selectedWalletId: state.toWalletId,
              onChanged: (walletId) {
                if (walletId != null) {
                  context.read<AddTransactionBloc>().add(
                    AddTransactionToWalletChanged(walletId),
                  );
                }
              },
              placeholder: 'Select destination wallet',
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
                    'Exchange Rate: ${_calculateExchangeRate(state, fromWallet, toWallet)}',
                    style: Theme.of(context).typography.xSmall.copyWith(
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
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
          return 'Please select a wallet';
        }
        if (state.amount.isEmpty) {
          return 'Please enter an amount';
        }
        if (double.tryParse(state.amount) == null ||
            double.parse(state.amount) <= 0) {
          return 'Please enter a valid amount greater than 0';
        }
        if (state.categoryId == null) {
          return 'Please select a category';
        }
        break;

      case TransactionType.transfer:
        if (state.fromWalletId == null) {
          return 'Please select a source wallet';
        }
        if (state.toWalletId == null) {
          return 'Please select a destination wallet';
        }
        if (state.fromWalletId == state.toWalletId) {
          return 'Source and destination wallets must be different';
        }
        if (state.amount.isEmpty) {
          return 'Please enter an amount';
        }
        if (double.tryParse(state.amount) == null ||
            double.parse(state.amount) <= 0) {
          return 'Please enter a valid amount greater than 0';
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
            return 'Please enter the exchange amount';
          }
          if (double.tryParse(state.exchangeAmount) == null ||
              double.parse(state.exchangeAmount) <= 0) {
            return 'Please enter a valid exchange amount greater than 0';
          }
        }
        if (state.feePercentage == null && state.customFeeValue.isNotEmpty) {
          final customFee = double.tryParse(state.customFeeValue);
          if (customFee == null || customFee < 0) {
            return 'Please enter a valid fee percentage';
          }
        }
        break;

      case TransactionType.exchange:
        return 'Exchange type is deprecated';
    }

    return 'Please fill in all required fields';
  }
}
